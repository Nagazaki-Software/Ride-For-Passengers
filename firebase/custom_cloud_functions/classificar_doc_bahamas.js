/* eslint-disable no-console */
const { onRequest } = require("firebase-functions/v2/https");
const { OpenAI } = require("openai");

// =====================
// OpenRouter config
// =====================
const OPENROUTER_BASE_URL = "https://openrouter.ai/api/v1";
const client = new OpenAI({
  baseURL: OPENROUTER_BASE_URL,
  apiKey:
    "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", // defina via Secret/ambiente
});

// =====================
// Utilitários
// =====================
function applyCors(req, res) {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST,OPTIONS,GET");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return true;
  }
  return false;
}
function isHttpUrl(str) {
  try {
    const u = new URL(String(str));
    return u.protocol === "http:" || u.protocol === "https:";
  } catch {
    return false;
  }
}
function looksLikeImageRef(img) {
  if (!img) return false;
  if (typeof img === "string") return isHttpUrl(img) || img.startsWith("data:");
  if (typeof img === "object") {
    if (img.base64 && img.mimeType) return true;
    if (img.inlineData && img.inlineData.data && img.inlineData.mimeType)
      return true;
    if (img.bytes && img.mimeType) return true;
    if (img.url && isHttpUrl(img.url)) return true;
  }
  return false;
}
function toDataUrlFromObj(imgObj) {
  if (imgObj.base64 && imgObj.mimeType)
    return `data:${imgObj.mimeType};base64,${imgObj.base64}`;
  if (imgObj.inlineData?.data && imgObj.inlineData?.mimeType)
    return `data:${imgObj.inlineData.mimeType};base64,${imgObj.inlineData.data}`;
  if (imgObj.bytes && imgObj.mimeType) {
    const b64 = Buffer.from(imgObj.bytes).toString("base64");
    return `data:${imgObj.mimeType};base64,${b64}`;
  }
  if (imgObj.url && isHttpUrl(imgObj.url)) return imgObj.url;
  throw new Error("Formato de imagem não suportado.");
}
function coerceImageToUrlOrDataUrl(img) {
  return typeof img === "string" ? img : toDataUrlFromObj(img);
}
function tryParseJson(text) {
  if (!text) return null;
  const m = text.match(/\{[\s\S]*\}/);
  if (!m) return null;
  try {
    return JSON.parse(m[0]);
  } catch {
    return null;
  }
}

// =====================
// Classificador Vision (FREE)
// =====================
async function classifySingleImage(imgRef, model) {
  const image = coerceImageToUrlOrDataUrl(imgRef);

  // Modelo multimodal GRATUITO no OpenRouter
  // https://openrouter.ai/meta-llama/llama-3.2-11b-vision-instruct:free
  const chosenModel = model || "meta-llama/llama-3.2-11b-vision-instruct:free";

  const system = [
    "Você é um classificador de documentos de identidade.",
    "Responda APENAS em JSON válido com o formato:",
    `{
      "type": "passport" | "id_card" | "driver_license" | "other",
      "countryLikely": "Bahamas" | "Other" | "Unknown",
      "confidence": number,
      "reasons": string[]
    }`,
    "Se não houver evidência suficiente, use type='other' e countryLikely='Unknown' com confidence baixa.",
  ].join(" ");

  const userText = "Classifique o documento na imagem. Retorne somente o JSON.";

  const completion = await client.chat.completions.create({
    model: chosenModel,
    temperature: 0,
    messages: [
      { role: "system", content: system },
      {
        role: "user",
        content: [
          { type: "text", text: userText },
          { type: "image_url", image_url: { url: image } },
        ],
      },
    ],
  });

  const raw = completion.choices?.[0]?.message?.content || "";
  const json = tryParseJson(raw) || {
    type: "other",
    countryLikely: "Unknown",
    confidence: 0.0,
    reasons: ["Falha ao analisar JSON do modelo."],
  };

  // Normalização
  if (!["passport", "id_card", "driver_license", "other"].includes(json.type))
    json.type = "other";
  if (!["Bahamas", "Other", "Unknown"].includes(json.countryLikely))
    json.countryLikely = "Unknown";
  if (typeof json.confidence !== "number") json.confidence = 0.0;
  if (!Array.isArray(json.reasons)) json.reasons = [];

  return json;
}

// Gen 2: HTTP onRequest
exports.classificarDocBahamas = onRequest({
  region: "us-central1",
  timeoutSeconds: 60,
  memory: "256MiB",
}, async (req, res) => {
  if (applyCors(req, res)) return;

  if (req.method === "GET") {
    return res.status(200).json({ ok: true, msg: "classificarDocBahamas up" });
  }
  if (req.method !== "POST") {
    res.set("Allow", "POST,OPTIONS,GET");
    return res.status(405).send("Method Not Allowed");
  }

  try {
    let body = req.body;
    if (typeof body === "string") {
      try {
        body = JSON.parse(body);
      } catch {}
    }
    const data = body && typeof body === "object" ? (body.data ?? body) : {};

    const img = data?.image;
    const minConfidence =
      typeof data?.minConfidence === "number" ? data.minConfidence : 0.7;
    const model =
      data?.model || "meta-llama/llama-3.2-11b-vision-instruct:free";

    if (!looksLikeImageRef(img)) {
      return res.status(400).json({
        ok: false,
        errors: [
          "Campo 'image' ausente ou inválido. Envie https, dataURL, {base64,mimeType}, {inlineData:{data,mimeType}} ou {bytes,mimeType}.",
        ],
      });
    }

    const out = await classifySingleImage(img, model);
    const isBahamasDoc =
      out.type !== "other" && out.countryLikely === "Bahamas";
    const meetsConfidence = out.confidence >= minConfidence;
    const accepted = isBahamasDoc && meetsConfidence;

    return res.status(accepted ? 200 : 422).json({
      ok: accepted,
      accepted,
      minConfidence,
      result: out,
    });
  } catch (e) {
    console.error(e);
    return res
      .status(500)
      .json({
        ok: false,
        errors: [`Falha ao classificar: ${e.message || String(e)}`],
      });
  }
});
