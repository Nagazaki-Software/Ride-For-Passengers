import '../cloud_functions/cloud_functions.dart';
import '/backend/schema/structs/index.dart';

export 'package:flutter/foundation.dart';
export 'package:flutter_braintree/flutter_braintree.dart';

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
  const PaymentResponse({this.transactionId, this.errorMessage});
  final String? transactionId;
  final String? errorMessage;
}

Future<PaymentResponse> processBraintreePayment(
  double amount,
  String paymentNonce, [
  String? deviceData,
]) async {
  final response = await makeCloudCall('payAndReturnPaymentMethod', {
    'amount': amount,
    'paymentNonce': paymentNonce,
    'isProd': isProdPayments,
    if (deviceData != null) 'deviceData': deviceData,
  });
  if (response.containsKey('transactionId')) {
    return PaymentResponse(transactionId: response['transactionId']);
  }
  if (response.containsKey('error')) {
    return PaymentResponse(errorMessage: response['error']);
  }
  return PaymentResponse(errorMessage: 'Unknown error occured');
}

double computeTotal(double baseTotal,
    {double taxRate = 0.0, double shippingCost = 0.0}) {
  final total = baseTotal * (1 + taxRate / 100) + shippingCost;
  return (total * 100).roundToDouble() / 100;
}

// New helpers for saved methods and tips

PaymentMethodSaveStruct _metaToStruct(Map<String, dynamic> meta) {
  return createPaymentMethodSaveStruct(
    brand: meta['brand']?.toString(),
    isDefault: meta['isDefault'] == true || meta['default'] == true,
    last4Numbers: meta['last4Numbers']?.toString() ?? meta['last4']?.toString(),
    paymentMethodToken: meta['paymentMethodToken']?.toString() ?? meta['token']?.toString(),
    pass: meta['pass'] == true,
  );
}

Future<PaymentMethodSaveStruct?> saveCardWithNonce(String paymentNonce,
    {String? deviceData}) async {
  final res = await makeCloudCall('saveCardPayment', {
    'paymentNonce': paymentNonce,
    'isProd': isProdPayments,
    if (deviceData != null) 'deviceData': deviceData,
  });
  if (res['success'] == true && res['paymentMethod'] is Map) {
    return _metaToStruct(Map<String, dynamic>.from(res['paymentMethod']));
  }
  return null;
}

Future<PaymentResponse> payWithSavedToken(double amount, String token,
    {String? deviceData}) async {
  final res = await makeCloudCall('payWithSavedPaymentMethod', {
    'amount': amount,
    'paymentMethodToken': token,
    'isProd': isProdPayments,
    if (deviceData != null) 'deviceData': deviceData,
  });
  if (res['success'] == true && res['transactionId'] != null) {
    return PaymentResponse(transactionId: res['transactionId'].toString());
  }
  return PaymentResponse(errorMessage: res['error']?.toString() ?? 'Payment failed');
}

Future<PaymentResponse> tipWithSavedToken(
  double amount,
  String token, {
  String? rideId,
  String? driverId,
  String? deviceData,
}) async {
  final res = await makeCloudCall('tipDriver', {
    'amount': amount,
    'paymentMethodToken': token,
    'isProd': isProdPayments,
    if (rideId != null) 'rideId': rideId,
    if (driverId != null) 'driverId': driverId,
    if (deviceData != null) 'deviceData': deviceData,
  });
  if (res['success'] == true && res['transactionId'] != null) {
    return PaymentResponse(transactionId: res['transactionId'].toString());
  }
  return PaymentResponse(errorMessage: res['error']?.toString() ?? 'Tip failed');
}
