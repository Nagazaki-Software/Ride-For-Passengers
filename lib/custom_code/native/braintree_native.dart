import 'dart:async';
import 'package:flutter/services.dart';

class BraintreeNative {
  static const MethodChannel _channel = MethodChannel('braintree_native');

  /// Tokenize a raw card using native Braintree SDKs (Android/iOS), without Drop-in.
  /// Returns a map like { nonce, last4, cardType } or throws [PlatformException].
  static Future<Map<String, dynamic>> tokenizeCard({
    required String tokenizationKey,
    required String number,
    required String expirationMonth,
    required String expirationYear,
    String? cvv,
    String? cardholderName,
  }) async {
    final args = <String, dynamic>{
      'tokenizationKey': tokenizationKey,
      'number': number,
      'expirationMonth': expirationMonth,
      'expirationYear': expirationYear,
      if (cvv != null) 'cvv': cvv,
      if (cardholderName != null) 'cardholderName': cardholderName,
    };
    final result = await _channel.invokeMethod<dynamic>('tokenizeCard', args);
    if (result is Map) {
      return Map<String, dynamic>.from(result as Map);
    }
    return <String, dynamic>{};
  }

  /// Perform 3D Secure verification for a given card nonce and amount.
  /// Returns a map like { nonce, liabilityShifted, liabilityShiftPossible }
  /// or throws [PlatformException].
  static Future<Map<String, dynamic>> threeDSecureVerify({
    required String tokenizationKey,
    required String nonce,
    required String amount,
    String? email,
  }) async {
    final args = <String, dynamic>{
      'tokenizationKey': tokenizationKey,
      'nonce': nonce,
      'amount': amount,
      if (email != null) 'email': email,
    };
    final result = await _channel.invokeMethod<dynamic>('threeDSecureVerify', args);
    if (result is Map) {
      return Map<String, dynamic>.from(result as Map);
    }
    return <String, dynamic>{};
  }
}
