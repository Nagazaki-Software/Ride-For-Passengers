import 'package:flutter/services.dart';

class BraintreeNativeBridge {
  static const MethodChannel _ch = MethodChannel('com.quicky.ridebahamas/braintree');

  static Future<String?> tokenizeCard({
    required String authorization,
    required String number,
    required String expirationMonth,
    required String expirationYear,
    String? cvv,
  }) async {
    final res = await _ch.invokeMethod<String>('tokenizeCard', {
      'authorization': authorization,
      'number': number,
      'expirationMonth': expirationMonth,
      'expirationYear': expirationYear,
      'cvv': cvv,
    });
    return res;
  }

  static Future<String?> paypalCheckout({
    required String authorization,
    required String amount,
    String currencyCode = 'USD',
  }) async {
    final res = await _ch.invokeMethod<String>('paypalCheckout', {
      'authorization': authorization,
      'amount': amount,
      'currencyCode': currencyCode,
    });
    return res;
  }

  static Future<String?> googlePay({
    required String authorization,
    required String amount,
    String currencyCode = 'USD',
  }) async {
    final res = await _ch.invokeMethod<String>('googlePay', {
      'authorization': authorization,
      'amount': amount,
      'currencyCode': currencyCode,
    });
    return res;
  }
}

