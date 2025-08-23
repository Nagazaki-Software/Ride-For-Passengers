// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// lib/custom_code/widgets/card_form_f_f.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:google_fonts/google_fonts.dart';

// FlutterFlow (esses dois existem em qualquer projeto FF)

// Estes dois existem se você usa o Auth/Firestore do FF.
// Se não tiver, remova o import e as linhas que usam currentUserReference/createUsersRecordData.
import '/auth/firebase_auth/auth_util.dart';

class CardData {
  final String number;
  final String expiry; // MM/YY ou MM/YYYY
  final String cvv;
  final String holder;
  const CardData({
    required this.number,
    required this.expiry,
    required this.cvv,
    required this.holder,
  });
  String get month {
    final p = expiry.split('/');
    return p.isNotEmpty ? p.first.trim().padLeft(2, '0') : '';
  }

  String get year {
    final p = expiry.split('/');
    if (p.length < 2) return '';
    final y = p.last.trim();
    return y.length == 2 ? '20$y' : y;
  }
}

class PaymentResponse {
  final String? transactionId;
  final String? errorMessage;
  PaymentResponse({this.transactionId, this.errorMessage});
}

class CardFormFF extends StatefulWidget {
  const CardFormFF({
    super.key,
    this.width,
    this.height,
    required this.value, // valor a cobrar
    required this.passe, // texto para sucesso
    required this.tokenizationKey, // Braintree tokenization key (ex.: sandbox_xxx...)
  });

  final double? width;
  final double? height;
  final double value;
  final String passe;
  final String tokenizationKey;

  @override
  State<CardFormFF> createState() => _CardFormFFState();
}

class _CardFormFFState extends State<CardFormFF> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();

  String? _transactionId;

  static const kBgDark = Color(0xFF232323);
  static const kFieldOrange = Color(0xFFFF9F1C);
  static const kPillOrange = Color(0xFFF5A623);

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _holderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: kBgDark,
      child: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_numberCtrl, 'Type your credit card here'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field(_expiryCtrl, 'Due date (MM/YY)')),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_cvvCtrl, 'CVV', isCvv: true)),
                  ],
                ),
                const SizedBox(height: 12),
                _field(_holderCtrl, 'Type your name on the card here'),
                const SizedBox(height: 12),

                // Salvar cartão -> AppState + callback
                _pillButton(
                  label: 'Salvar Cartão',
                  color: kFieldOrange,
                  textColor: Colors.black,
                  onTap: () {
                    if (!(_formKey.currentState?.validate() ?? false)) {
                      showSnackbar(context, 'Preencha os campos.');
                      return;
                    }
                    final data = _collect();
                    FFAppState().update(() {
                      FFAppState().cardNumber = data.number;
                      FFAppState().cardExpiry = data.expiry;
                      FFAppState().cardCvv = data.cvv;
                      FFAppState().cardHolder = data.holder;
                    });

                    showSnackbar(context, 'Cartão salvo (AppState).');
                  },
                ),
                const SizedBox(height: 12),

                _secureBadge(),
                const SizedBox(height: 12),

                // Continue -> tokeniza + HTTP
                _pillButton(
                  label: 'Continue',
                  color: kPillOrange,
                  textColor: const Color(0xFF1E1E1E),
                  onTap: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    if (kIsWeb) {
                      showSnackbar(
                          context, 'Payments not yet supported on web.');
                      return;
                    }

                    final data = _collect();

                    showSnackbar(context, 'Processing payment...',
                        duration: 10, loading: true);

                    // 1) Tokeniza com Braintree (usando tokenizationKey pública)
                    final req = BraintreeCreditCardRequest(
                      cardNumber: data.number,
                      expirationMonth: data.month,
                      expirationYear: data.year,
                      cvv: data.cvv,
                    );
                    final result = await Braintree.tokenizeCreditCard(
                      widget.tokenizationKey,
                      req,
                    );
                    if (result == null) return;

                    // 2) Cobra via HTTP (Callable onCall)
                    final pay = await _callProcessTestPaymentHttp(
                      amount: widget.value,
                      paymentNonce: result.nonce,
                    );

                    if (pay.errorMessage != null) {
                      showSnackbar(context, 'Error: ${pay.errorMessage}');
                      await _showErrorBottomSheet();
                      return;
                    }

                    _transactionId = pay.transactionId;
                    showSnackbar(context, 'Success!');

                    if (_transactionId != null && _transactionId!.isNotEmpty) {
                      // Se não tiver Firestore/Auth do FF, remova este bloco try/catch
                      try {
                        await currentUserReference?.update(
                          createUsersRecordData(passe: 'day'),
                        );
                      } catch (_) {}
                      await _showSuccessBottomSheet(widget.passe);
                    } else {
                      await _showErrorBottomSheet();
                    }

                    if (!mounted) return;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== Helpers =====
  CardData _collect() => CardData(
        number: _numberCtrl.text.trim(),
        expiry: _expiryCtrl.text.trim(),
        cvv: _cvvCtrl.text.trim(),
        holder: _holderCtrl.text.trim(),
      );

  Widget _field(TextEditingController c, String hint, {bool isCvv = false}) {
    return TextFormField(
      controller: c,
      obscureText: isCvv,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: kFieldOrange,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(Icons.local_drink, color: Colors.black),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _secureBadge() {
    return Semantics(
      label:
          'Pagamento seguro usando plataformas Quicky. Seus dados são enviados por conexão criptografada.',
      child: Row(
        children: const [
          Icon(Icons.lock_outline_rounded, size: 18, color: Colors.white70),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Secure payment using Quicky© platforms.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.white70,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Bottom sheets internos (sem dependências externas) =====
  Future<void> _showSuccessBottomSheet(String passe) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 36),
                const SizedBox(height: 12),
                Text(
                  'Pagamento aprovado!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Passe: $passe\nTransação: ${_transactionId ?? '-'}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                _pillButton(
                  label: 'Fechar',
                  color: kPillOrange,
                  textColor: const Color(0xFF1E1E1E),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showErrorBottomSheet() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 36),
                const SizedBox(height: 12),
                Text(
                  'Não foi possível processar o pagamento.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _pillButton(
                  label: 'Tentar novamente',
                  color: kFieldOrange,
                  textColor: Colors.black,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== HTTP direto para seu Callable =====
  Future<PaymentResponse> _callProcessTestPaymentHttp({
    required double amount,
    required String paymentNonce,
    String? deviceData,
  }) async {
    // Callable exige usuário autenticado
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final uri = Uri.parse(
      'https://us-central1-quick-b108e.cloudfunctions.net/processBraintreeTestPayment',
    );

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      },
      // Callable v1 espera {"data": {...}}
      body: jsonEncode({
        'data': {
          'amount': amount,
          'paymentNonce': paymentNonce,
          'deviceData': deviceData,
        }
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      return PaymentResponse(
        errorMessage: 'HTTP ${resp.statusCode}: ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body);
    final map = (decoded is Map<String, dynamic>)
        ? (decoded['result'] ?? decoded['data'] ?? decoded)
        : null;

    if (map is Map<String, dynamic>) {
      return PaymentResponse(
        transactionId: map['transactionId'] as String?,
        errorMessage: map['error'] as String?,
      );
    }
    return PaymentResponse(errorMessage: 'Resposta inesperada do servidor.');
  }
}
