import '../cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

final isProdPayments = false;

// Test Braintree Credentials
const kTestBraintreeTokenizationKey = 'sandbox_ck9vkcgg_brg8dhjg5tqpw496';
const kTestGoogleMerchantId = 'com.quicky.ridebahamas';
const kTestAppleMerchantId = 'com.quicky.ridebahamas';

// Production Braintree Credentials
const kProdBraintreeTokenizationKey = '';
const kProdGoogleMerchantId = '';
const kProdAppleMerchantId = '';

String braintreeClientToken() => isProdPayments
    ? kProdBraintreeTokenizationKey
    : kTestBraintreeTokenizationKey;
String googleMerchantId() =>
    isProdPayments ? kProdGoogleMerchantId : kTestGoogleMerchantId;
String appleMerchantId() =>
    isProdPayments ? kProdAppleMerchantId : kTestAppleMerchantId;

class PaymentResponse {
  const PaymentResponse({this.transactionId, this.errorMessage, this.paymentMethodMeta});
  final String? transactionId;
  final String? errorMessage;
  // Optional metadata returned by cloud function (e.g., token/brand/last4)
  final Map<String, dynamic>? paymentMethodMeta;
}

Future<PaymentResponse> processBraintreePayment(
  double amount,
  String paymentNonce, [
  String? deviceData,
]) async {
  // Align with Firebase Functions names in firebase/functions/index.js
  final response = await makeCloudCall(
    'payAndReturnPaymentMethod',
    {
      'amount': amount,
      'paymentNonce': paymentNonce,
      if (deviceData != null) 'deviceData': deviceData,
      'isProd': isProdPayments,
    },
  );
  final ok = response['success'] == true || response['ok'] == true;
  final pmMeta = response['paymentMethod'];
  if (ok && response['transactionId'] != null) {
    return PaymentResponse(
      transactionId: response['transactionId'],
      paymentMethodMeta: pmMeta is Map ? Map<String, dynamic>.from(pmMeta as Map) : null,
    );
  }
  if (response['error'] != null) {
    return PaymentResponse(
      errorMessage: response['error'].toString(),
      paymentMethodMeta: pmMeta is Map ? Map<String, dynamic>.from(pmMeta as Map) : null,
    );
  }
  return const PaymentResponse(errorMessage: 'Unknown error occured');
}

double computeTotal(double baseTotal,
    {double taxRate = 0.0, double shippingCost = 0.0}) {
  final total = baseTotal * (1 + taxRate / 100) + shippingCost;
  return (total * 100).roundToDouble() / 100;
}

/// Vault a card in Braintree using a payment nonce and return details.
/// Returns a map with keys: 'token', 'brand', 'last4', 'isDefault' or 'error'.
Future<Map<String, dynamic>> saveBraintreePaymentMethod(
  String paymentNonce, {
  bool makeDefault = false,
}) async {
  final response = await makeCloudCall(
    'saveCardPayment',
    {
      'paymentNonce': paymentNonce,
      'isProd': isProdPayments,
      'makeDefault': makeDefault,
    },
  );
  return response;
}

/// Charge using a vaulted payment method token (for saved cards)
Future<PaymentResponse> payWithSavedPaymentMethod(
  double amount,
  String paymentMethodToken, {
  String? deviceData,
}) async {
  final response = await makeCloudCall(
    'payWithSavedPaymentMethod',
    {
      'amount': amount,
      'paymentMethodToken': paymentMethodToken,
      if (deviceData != null) 'deviceData': deviceData,
      'isProd': isProdPayments,
    },
  );
  final ok = response['success'] == true || response['ok'] == true;
  if (ok && response['transactionId'] != null) {
    return PaymentResponse(transactionId: response['transactionId']);
  }
  if (response['error'] != null) {
    return PaymentResponse(errorMessage: response['error'].toString());
  }
  return const PaymentResponse(errorMessage: 'Unknown error occured');
}
