const functions = require("firebase-functions");
const admin = require("firebase-admin");
// Se o seu projeto não inicializa o Admin automaticamente, descomente a linha abaixo UMA única vez no entrypoint:
// admin.initializeApp();

const db = admin.firestore();

/**
 * Helper: adiciona duração a uma data (UTC).
 */
function addDuration(baseDate, type) {
  const d = new Date(baseDate);
  switch (String(type).toLowerCase()) {
    case "day":
      d.setDate(d.getDate() + 1);
      break;
    case "week":
      d.setDate(d.getDate() + 7);
      break;
    case "month":
      d.setMonth(d.getMonth() + 1);
      break;
    case "year":
      d.setFullYear(d.getFullYear() + 1);
      break;
    default:
      break; // "No pass" ou desconhecido
  }
  return d;
}

/**
 * Normaliza entrada "users": aceita string (uid), objeto { id/uid }, ou array de ambos.
 */
function normalizeUsersArg(usersArg) {
  if (!usersArg) return [];
  const arr = Array.isArray(usersArg) ? usersArg : [usersArg];
  return arr
    .map((u) => (typeof u === "string" ? { id: u } : u))
    .map((u) => ({ id: u.id || u.uid, ...u }))
    .filter((u) => !!u.id);
}

exports.passeUpdate = functions.https.onCall(async (data, context) => {
  // Segurança básica (exija auth se quiser)
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Faça login para atualizar passes.",
    );
  }

  const inputUsers = normalizeUsersArg(data && data.users);
  if (!inputUsers.length) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      'Envie "users" como uid (string), objeto {id|uid}, ou array.',
    );
  }

  const nowTs = admin.firestore.Timestamp.now();
  const now = nowTs.toDate();
  const results = [];

  // Processa em paralelo, mas com limites razoáveis se necessário
  await Promise.all(
    inputUsers.map(async ({ id: userId }) => {
      const ref = db.collection("users").doc(userId);
      const snap = await ref.get();
      if (!snap.exists) {
        results.push({ userId, status: "not-found" });
        return;
      }

      const user = snap.data() || {};
      const rawType = user.passe || "No pass";
      const type = String(rawType).toLowerCase();
      const startedAt = user.passeStartedAt;
      const expiresAt = user.passeExpiresAt;

      // Tipos válidos com ciclo
      const hasCycle = ["day", "week", "month", "year"].includes(type);

      // Caso "No pass" ou tipo desconhecido → garante estado limpo
      if (!hasCycle) {
        // Se já está limpo, só retorna
        if (rawType === "No pass" && !startedAt && !expiresAt) {
          results.push({ userId, status: "none", passe: "No pass" });
          return;
        }
        await ref.update({
          passe: "No pass",
          passeStartedAt: admin.firestore.FieldValue.delete(),
          passeExpiresAt: admin.firestore.FieldValue.delete(),
        });
        results.push({ userId, status: "set-no-pass", passe: "No pass" });
        return;
      }

      // Se tem ciclo, precisamos ter startedAt e expiresAt
      let finalStartedAt = startedAt || nowTs;
      let finalExpiresAt = expiresAt;

      if (!finalExpiresAt) {
        // Se não tinha expiração, calcula e salva
        const base = startedAt?.toDate?.() || now;
        const calc = addDuration(base, type);
        finalExpiresAt = admin.firestore.Timestamp.fromDate(calc);
        await ref.update({
          passeStartedAt: startedAt || nowTs,
          passeExpiresAt: finalExpiresAt,
        });
      }

      // Verifica expiração
      const expired = finalExpiresAt.toMillis() <= nowTs.toMillis();

      if (expired) {
        await ref.update({
          passe: "No pass",
          passeStartedAt: admin.firestore.FieldValue.delete(),
          passeExpiresAt: admin.firestore.FieldValue.delete(),
          passeLastExpiredAt: nowTs,
        });
        results.push({
          userId,
          status: "expired->no-pass",
          passe: "No pass",
          expiredAt: now.toISOString(),
        });
      } else {
        results.push({
          userId,
          status: "active",
          passe: type,
          startedAt: finalStartedAt.toDate().toISOString(),
          expiresAt: finalExpiresAt.toDate().toISOString(),
        });
      }
    }),
  );

  return { ok: true, count: results.length, results };
});
