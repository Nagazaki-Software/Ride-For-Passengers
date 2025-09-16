const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const braintree = require("braintree");

// Test credentials
const kTestMerchantId = "brg8dhjg5tqpw496";
const kTestPublicKey = "syt9g3c79t58wk82";
const kTestPrivateKey = "0fa7de713fa2bbb810f183f628f51d86d";

// Prod credentials
const kProdMerchantId = "";
const kProdPublicKey = "";
const kProdPrivateKey = "";

const merchantId = (isProd) => (isProd ? kProdMerchantId : kTestMerchantId);
const publicKey = (isProd) => (isProd ? kProdPublicKey : kTestPublicKey);
const privateKey = (isProd) => (isProd ? kProdPrivateKey : kTestPrivateKey);

/**
 * Charge using either a payment nonce or a vaulted payment method token.
 */
exports.processBraintreePayment = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      return "Unauthenticated calls are not allowed.";
    }
    const amount = data.amount;
    const paymentNonce = data.paymentNonce;
    const paymentMethodToken = data.paymentMethodToken;
    const deviceData = data.deviceData;
    return await processTransaction({
      amount,
      paymentNonce,
      paymentMethodToken,
      deviceData,
      isProd: true,
    });
  },
);

/**
 * Test environment variant.
 */
exports.processBraintreeTestPayment = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      return "Unauthenticated calls are not allowed.";
    }
    const amount = data.amount;
    const paymentNonce = data.paymentNonce;
    const paymentMethodToken = data.paymentMethodToken;
    const deviceData = data.deviceData;
    return await processTransaction({
      amount,
      paymentNonce,
      paymentMethodToken,
      deviceData,
      isProd: false,
    });
  },
);

async function processTransaction({ amount, paymentNonce, paymentMethodToken, deviceData, isProd }) {
  const gateway = new braintree.BraintreeGateway({
    environment: isProd
      ? braintree.Environment.Production
      : braintree.Environment.Sandbox,
    merchantId: merchantId(isProd),
    publicKey: publicKey(isProd),
    privateKey: privateKey(isProd),
  });
  return await gateway.transaction
    .sale({
      amount,
      // Prefer token when provided, otherwise use nonce.
      ...(paymentMethodToken
        ? { paymentMethodToken }
        : { paymentMethodNonce: paymentNonce }),
      deviceData,
      options: {
        submitForSettlement: true,
      },
    })
    .then(
      (result) => {
        return result.success
          ? { transactionId: result.transaction.id }
          : { error: "Error processing payment." };
      },
      async (error) => {
        console.log(`Error: ${error}`);
        return { error: userFacingMessage(error) };
      },
    );
}

/**
 * Sanitize the error message for the user.
 */
function userFacingMessage(error) {
  return error.type
    ? error.message
    : "An error occurred, developers have been alerted";
}
exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("users/" + user.uid);
  await firestore.collection("users").doc(user.uid).delete();
});

/**
 * Save payment method (Vault) given a nonce. Returns token, last4, and cardholder name.
 */
exports.savePaymentMethodTest = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    return "Unauthenticated calls are not allowed.";
  }
  const nonce = data.nonce;
  if (!nonce || typeof nonce !== 'string' || nonce.trim().length === 0) {
    return { error: 'Missing nonce.' };
  }
  const customerId = data.customerId || `u_${context.auth.uid}`;
  return await savePaymentMethod({ nonce, customerId, isProd: false });
});

exports.savePaymentMethod = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    return "Unauthenticated calls are not allowed.";
  }
  const nonce = data.nonce;
  if (!nonce || typeof nonce !== 'string' || nonce.trim().length === 0) {
    return { error: 'Missing nonce.' };
  }
  const customerId = data.customerId || `u_${context.auth.uid}`;
  return await savePaymentMethod({ nonce, customerId, isProd: true });
});

async function savePaymentMethod({ nonce, customerId, isProd }) {
  const gateway = new braintree.BraintreeGateway({
    environment: isProd
      ? braintree.Environment.Production
      : braintree.Environment.Sandbox,
    merchantId: merchantId(isProd),
    publicKey: publicKey(isProd),
    privateKey: privateKey(isProd),
  });

  // Ensure customer exists; if not, create it with the provided nonce.
  try {
    // Try to find customer first
    const existing = await gateway.customer.find(customerId);
    // If found, attach new payment method to this customer
    const pm = await gateway.paymentMethod.create({
      customerId,
      paymentMethodNonce: nonce,
      options: { verifyCard: true },
    });
    if (pm.success) {
      const paymentMethod = pm.paymentMethod || pm.creditCard;
      return normalizePaymentMethod(paymentMethod);
    }
    return { error: userFacingMessage(pm) };
  } catch (e) {
    // Not found or first time: create customer with this payment method
    try {
      const created = await gateway.customer.create({
        id: customerId,
        paymentMethodNonce: nonce,
      });
      if (created.success) {
        const methods = created.customer && created.customer.paymentMethods;
        const pm = methods && methods.length > 0 ? methods[0] : null;
        return normalizePaymentMethod(pm);
      }
      return { error: userFacingMessage(created) };
    } catch (err) {
      console.log(`savePaymentMethod error: ${err}`);
      return { error: userFacingMessage(err) };
    }
  }
}

function normalizePaymentMethod(pm) {
  if (!pm) return { error: 'No payment method returned.' };
  const token = pm.token;
  const details = pm.cardType ? pm : (pm.details || {});
  const last4 = details.last4 || pm.last4 || '';
  const name = pm.cardholderName || details.cardholderName || '';
  return { token, last4, name };
}
