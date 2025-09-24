// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// ===== IMPORTS EXTRAS =====
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_braintree/flutter_braintree.dart';

/// Action única controlada por `charge`:
/// - charge == false  -> apenas SALVA o JSON no Firestore (sem cobrar)
/// - charge == true   -> apenas COBRA via Cloud Functions (sem salvar)
///
/// Parâmetros:
/// - creditCard: PaymentMethodSaveStruct (ou Map/String JSON – lidamos com todos)
/// - charge: bool?  (true = charge, qualquer outra coisa = save)
/// - tokenizationKey: String? ("sandbox_..." / "production_...")
/// - amount: double (valor)
///
/// Retorno:
/// { ok: bool, mode: "save"|"charge", transactionId?: string, error?: string }
Future<dynamic> processCardPayload(
  BuildContext context,
  PaymentMethodSaveStruct creditCard,
  bool? charge,
  String? tokenizationKey,
  double amount,
) async {
  final result = <String, dynamic>{
    'ok': false,
    'mode': (charge == true) ? 'charge' : 'save',
  };

  // ---------- Helpers ----------
  Future<Map<String, dynamic>> _callCharge({
    required String tokenizationKey,
    required double amount,
    String? paymentNonce,
    String? paymentMethodToken,
  }) async {
    final isSandbox = tokenizationKey.startsWith('sandbox_');
    final fnName =
        isSandbox ? 'processBraintreeTestPayment' : 'processBraintreePayment';
    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final callable = functions.httpsCallable(fnName);

    final req = <String, dynamic>{
      'amount': amount.toStringAsFixed(2),
    };
    if (paymentNonce != null && paymentNonce.isNotEmpty) {
      req['paymentNonce'] = paymentNonce;
    }
    if (paymentMethodToken != null && paymentMethodToken.isNotEmpty) {
      req['paymentMethodToken'] = paymentMethodToken;
    }

    final resp = await callable.call(req);
    return Map<String, dynamic>.from(resp.data as Map);
  }

  Map<String, dynamic> _normalizeToMap(dynamic src) {
    try {
      if (src is PaymentMethodSaveStruct) {
        return Map<String, dynamic>.from(src.toMap());
      }
    } catch (_) {}
    if (src is Map) return Map<String, dynamic>.from(src);
    if (src is String && src.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(src);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  String? _str(Map m, String k) {
    final v = m[k];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  bool _isApplePay(String? t) {
    final x = (t ?? '').toLowerCase();
    return x == 'applepay' || x == 'apple_pay' || x == 'apple';
  }

  bool _isGooglePay(String? t) {
    final x = (t ?? '').toLowerCase();
    return x == 'googlepay' ||
        x == 'google_pay' ||
        x == 'gpay' ||
        x == 'google';
  }

  /// Abre o Drop-In só com ApplePay ou só com GooglePay para obter NONCE.
  Future<String?> _getNonceViaDropIn({
    required String tokenizationKey,
    required double amount,
    required bool apple,
    required bool google,
    String? merchantIdentifier, // Apple Pay
    String displayName = 'Sua Loja',
    String currencyCode = 'BRL',
    String countryCode = 'BR',
  }) async {
    // Apple Pay: supportedNetworks + paymentSummaryItems com "type".
    BraintreeApplePayRequest? appleReq;
    if (apple) {
      appleReq = BraintreeApplePayRequest(
        currencyCode: currencyCode,
        countryCode: countryCode,
        merchantIdentifier:
            merchantIdentifier ?? 'merchant.com.seu.bundle', // TODO
        displayName: displayName,
        supportedNetworks: const [
          ApplePaySupportedNetworks.visa,
          ApplePaySupportedNetworks
              .masterCard, // ajuste p/ seu fork se necessário
          ApplePaySupportedNetworks.amex,
          ApplePaySupportedNetworks.discover,
        ],
        paymentSummaryItems: [
          ApplePaySummaryItem(
            label: displayName,
            amount: amount, // <— double, não String
            // Se seu fork tiver `finalPrice` (ou `final`), troque aqui:
            type: ApplePaySummaryItemType.pending,
          ),
        ],
      );
    }

    BraintreeGooglePaymentRequest? googleReq;
    if (google) {
      googleReq = BraintreeGooglePaymentRequest(
        totalPrice: amount.toStringAsFixed(2),
        currencyCode: currencyCode,
        billingAddressRequired: false,
      );
    }

    final dropInReq = BraintreeDropInRequest(
      tokenizationKey: tokenizationKey,
      cardEnabled: false,
      paypalRequest: null,
      applePayRequest: appleReq,
      googlePaymentRequest: googleReq,
      collectDeviceData: false,
    );

    final dropInRes = await BraintreeDropIn.start(dropInReq);
    if (dropInRes == null) return null; // cancelou
    final pm = dropInRes.paymentMethodNonce;
    return (pm == null || pm.nonce.isEmpty) ? null : pm.nonce;
  }

  try {
    // -------- Normalização inicial --------
    final bool doCharge = charge == true;
    final String tk = (tokenizationKey ?? '').trim();
    final double amt = amount;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      result['error'] = 'You must be signed in.';
      return result;
    }
    if (doCharge && (amt <= 0)) {
      result['error'] = 'Invalid amount.';
      return result;
    }
    if (doCharge && tk.isEmpty) {
      result['error'] = 'Missing tokenizationKey.';
      return result;
    }
    if (doCharge && kIsWeb) {
      result['error'] = 'Payments are not supported on web.';
      return result;
    }

    final Map<String, dynamic> payload = _normalizeToMap(creditCard);

    if (doCharge) {
      // ================= CHARGE =================
      final pmToken =
          _str(payload, 'paymentMethodToken') ?? _str(payload, 'token');
      final pmType =
          _str(payload, 'paymentMethodType') ?? _str(payload, 'type');
      String? nonce = _str(payload, 'nonce');

      // 1) Se houver TOKEN (vaulted), cobra por token
      if ((pmToken != null && pmToken.isNotEmpty) &&
          (nonce == null || nonce.isEmpty)) {
        try {
          final data = await _callCharge(
            tokenizationKey: tk,
            amount: amt,
            paymentMethodToken: pmToken,
          );
          final txId = _str(data, 'transactionId');
          if (txId == null) {
            result['error'] = 'Charge failed: missing transactionId.';
          } else {
            result['ok'] = true;
            result['transactionId'] = txId;
          }
        } on FirebaseFunctionsException catch (e) {
          final parts = <String>[];
          if (e.message != null && e.message!.trim().isNotEmpty) {
            parts.add(e.message!.trim());
          }
          if (e.details != null && e.details.toString().trim().isNotEmpty) {
            parts.add(e.details.toString().trim());
          }
          parts.add('CODE: ${e.code.toUpperCase()}');
          result['error'] = parts.join(' · ');
        } catch (e) {
          result['error'] = e.toString();
        }
        return result;
      }

      // 2) Apple Pay / Google Pay → Drop-In para gerar NONCE
      if ((nonce == null || nonce.isEmpty) &&
          (pmType != null) &&
          (_isApplePay(pmType) || _isGooglePay(pmType))) {
        try {
          final isApple = _isApplePay(pmType);
          final isGoogle = _isGooglePay(pmType);

          nonce = await _getNonceViaDropIn(
            tokenizationKey: tk,
            amount: amt,
            apple: isApple,
            google: isGoogle,
            merchantIdentifier: _str(payload, 'merchantIdentifier'),
            displayName: _str(payload, 'displayName') ?? 'Sua Loja',
            currencyCode: _str(payload, 'currencyCode') ?? 'BRL',
            countryCode: _str(payload, 'countryCode') ?? 'BR',
          );

          if (nonce == null || nonce.isEmpty) {
            result['error'] =
                '${isApple ? 'Apple Pay' : 'Google Pay'} canceled or failed.';
            return result;
          }
        } on PlatformException catch (pe) {
          result['error'] = pe.message ?? pe.code;
          return result;
        } catch (e) {
          result['error'] = e.toString();
          return result;
        }
      }

      // 3) Sem nonce? Tokeniza cartão (cardRaw)
      if (nonce == null || nonce.isEmpty) {
        final cardRaw = payload['cardRaw'] is Map
            ? Map<String, dynamic>.from(payload['cardRaw'])
            : null;

        if (cardRaw == null) {
          result['error'] =
              'Missing nonce or cardRaw. Provide a nonce, a paymentMethodToken, '
              'or cardRaw {number, expiryMonth, expiryYear, cvv}.';
          return result;
        }

        final number =
            (cardRaw['number'] ?? '').toString().replaceAll(RegExp(r'\D'), '');
        final mm = (cardRaw['expiryMonth'] ?? '').toString().padLeft(2, '0');
        var yy = (cardRaw['expiryYear'] ?? '').toString().trim();
        if (yy.length == 2) yy = '20$yy';
        final cvv = (cardRaw['cvv'] ?? '').toString();

        if (number.isEmpty || mm.isEmpty || yy.isEmpty || cvv.isEmpty) {
          result['error'] =
              'Incomplete cardRaw: number/expiry/cvv are required.';
          return result;
        }

        try {
          final req = BraintreeCreditCardRequest(
            cardNumber: number,
            expirationMonth: mm,
            expirationYear: yy,
            cvv: cvv,
          );
          final tokenized = await Braintree.tokenizeCreditCard(tk, req);
          if (tokenized == null || tokenized.nonce.isEmpty) {
            result['error'] = 'Tokenization failed.';
            return result;
          }
          nonce = tokenized.nonce;
        } on PlatformException catch (pe) {
          result['error'] = pe.message ?? pe.code;
          return result;
        } catch (e) {
          result['error'] = e.toString();
          return result;
        }
      }

      // 4) Tendo NONCE → cobra
      if (nonce != null && nonce.isNotEmpty) {
        try {
          final data = await _callCharge(
            tokenizationKey: tk,
            amount: amt,
            paymentNonce: nonce,
          );
          final txId = _str(data, 'transactionId');
          if (txId == null || txId.isEmpty) {
            result['error'] = 'Charge failed: missing transactionId.';
          } else {
            result['ok'] = true;
            result['transactionId'] = txId;
          }
        } on FirebaseFunctionsException catch (e) {
          final parts = <String>[];
          if (e.message != null && e.message!.trim().isNotEmpty) {
            parts.add(e.message!.trim());
          }
          if (e.details != null && e.details.toString().trim().isNotEmpty) {
            parts.add(e.details.toString().trim());
          }
          parts.add('CODE: ${e.code.toUpperCase()}');
          result['error'] = parts.join(' · ');
        } catch (e) {
          result['error'] = e.toString();
        }
      }
      // ============================================================
    } else {
      // ================= SAVE (somente salvar) ====================
      final payloadToStore = Map<String, dynamic>.from(payload)
        ..remove('nonce')
        ..remove('cardRaw')
        ..remove('cvv'); // nunca guarde CVV

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('payments')
            .add({
          ...payloadToStore,
          'amount': amt,
          'createdAt': FieldValue.serverTimestamp(),
        });
        result['ok'] = true;
      } catch (e) {
        result['error'] = e.toString();
      }
    }
  } catch (e) {
    result['error'] = e.toString();
  }

  return result; // ÚNICO return
}
