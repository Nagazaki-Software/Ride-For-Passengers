// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
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
/// Parâmetros (posicionais, como no stub do FF):
/// - creditCardTextfield: Map OU String JSON (o mesmo do widget)
/// - charge: bool?  (true = charge, qualquer outra coisa = save)
/// - tokenizationKey: String? ("sandbox_..." / "production_...")
/// - amount: double (valor)
///
/// Retorno (um único return no final):
/// { ok: bool, mode: "save"|"charge", transactionId?: string, error?: string }
Future<dynamic> processCardPayload(
  BuildContext context,
  dynamic creditCardTextfield,
  bool? charge,
  String? tokenizationKey,
  double amount,
) async {
  // Resultado único
  final result = <String, dynamic>{
    'ok': false,
    'mode': (charge == true) ? 'charge' : 'save',
  };

  try {
    // -------- Normalização inicial --------
    final bool doCharge = charge == true;
    final String tk = (tokenizationKey ?? '').trim();
    final double amt = amount; // já vem double no stub

    // payload pode vir Map ou String JSON
    Map<String, dynamic> payload = {};
    if (creditCardTextfield is Map) {
      payload = Map<String, dynamic>.from(creditCardTextfield as Map);
    } else if (creditCardTextfield is String &&
        creditCardTextfield.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(creditCardTextfield);
        if (decoded is Map) {
          payload = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {/* ignora */}
    }

    // -------- Regras básicas --------
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      result['error'] = 'You must be signed in.';
    } else if (doCharge && (amt <= 0)) {
      result['error'] = 'Invalid amount.';
    } else if (doCharge && tk.isEmpty) {
      result['error'] = 'Missing tokenizationKey.';
    } else if (doCharge && kIsWeb) {
      // Plugin nativo não funciona no Web
      result['error'] = 'Payments are not supported on web.';
    } else {
      if (doCharge) {
        // ================= CHARGE (somente cobrar) =================
        String? nonce =
            (payload['nonce'] is String) ? (payload['nonce'] as String) : null;

        // Se não há nonce, tenta tokenizar a partir de cardRaw
        if (nonce == null || nonce.isEmpty) {
          Map<String, dynamic>? cardRaw = payload['cardRaw'] is Map
              ? Map<String, dynamic>.from(payload['cardRaw'])
              : null;

          if (cardRaw == null) {
            result['error'] =
                'Missing nonce or cardRaw. Provide creditCardTextfield["nonce"] '
                'or cardRaw {number, expiryMonth, expiryYear, cvv}.';
          } else {
            final number = (cardRaw['number'] ?? '')
                .toString()
                .replaceAll(RegExp(r'\D'), '');
            final mm =
                (cardRaw['expiryMonth'] ?? '').toString().padLeft(2, '0');
            var yy = (cardRaw['expiryYear'] ?? '').toString().trim();
            if (yy.length == 2) yy = '20$yy';
            final cvv = (cardRaw['cvv'] ?? '').toString();

            if (number.isEmpty || mm.isEmpty || yy.isEmpty || cvv.isEmpty) {
              result['error'] =
                  'Incomplete cardRaw: number/expiry/cvv are required.';
            } else {
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
                } else {
                  nonce = tokenized.nonce;
                }
              } on PlatformException catch (pe) {
                result['error'] = pe.message ?? pe.code;
              } catch (e) {
                result['error'] = e.toString();
              }
            }
          }
        }

        // Se temos nonce e ainda não houve erro, chama a Function (us-central1 fixo)
        if (result['error'] == null && nonce != null && nonce.isNotEmpty) {
          final isSandbox = tk.startsWith('sandbox_');
          final fnName = isSandbox
              ? 'processBraintreeTestPayment'
              : 'processBraintreePayment';
          final functions =
              FirebaseFunctions.instanceFor(region: 'us-central1');
          final callable = functions.httpsCallable(fnName);

          try {
            final resp = await callable.call(<String, dynamic>{
              'amount': amt.toStringAsFixed(2),
              'paymentNonce': nonce,
            });

            final data = Map<String, dynamic>.from(resp.data as Map);
            final txId = data['transactionId'] as String?;
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
        // ============================================================
      }
    }
  } catch (e) {
    result['error'] = e.toString();
  }

  // ÚNICO return
  return result;
}
