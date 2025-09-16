import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// lib/custom_code/widgets/card_form_f_f.dart
import 'package:flutter/foundation.dart' show kIsWeb;
<<<<<<< HEAD
=======
import 'package:flutter/services.dart';
>>>>>>> 10c9b5c (new frkdfm)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
// Replaced flutter_braintree with native SDK bridge
import '../native/braintree_native.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
import 'package:flutter/services.dart';
import 'package:cloud_functions/cloud_functions.dart';

// FlutterFlow auth (remova se não usa)
=======
// FlutterFlow auth (remove if not used)
>>>>>>> 10c9b5c (new frkdfm)
import '/auth/firebase_auth/auth_util.dart';

const bool kDebugPayments = false;

class CardData {
  final String number; // digits only
  final String expiry; // MM/YY
  final String cvv; // 3-4 digits
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

class SaveMethodResponse {
  final String? token;
  final String? last4;
  final String? name;
  final String? errorMessage;
  SaveMethodResponse({this.token, this.last4, this.name, this.errorMessage});
}

class CardFormFF extends StatefulWidget {
  const CardFormFF({
    super.key,
    this.width,
    this.height,
<<<<<<< HEAD
    required this.value, // valor para cobrar
    required this.passe, // texto do passe
    required this.tokenizationKey, // Braintree tokenization key
    this.onTextField, // Future Function(dynamic)
    this.chargeOnConfirm = true, // true = pagar; false = salvar (vault)
    this.onSave, // callback específico de salvar
    this.closeOnSave = true, // fecha bottom sheet após salvar
=======
    required this.value, // value to charge
    required this.passe, // pass text
    required this.tokenizationKey, // Braintree tokenization key
    this.onTextField, // Future Function(dynamic)
    this.chargeOnConfirm = true, // true = charge; false = save to vault
    this.onSave, // callback for save mode
    this.closeOnSave = true, // close bottom sheet after save
    this.enableThreeDS = true, // run 3D Secure verification in charge mode
>>>>>>> 10c9b5c (new frkdfm)
  });

  final double? width;
  final double? height;
  final double value;
  final String passe;
  final String tokenizationKey;

<<<<<<< HEAD
  /// Callback chamado a cada digitação e no submit (modo UI).
  /// No FlutterFlow: Future Function(dynamic)
  final Future<dynamic> Function(dynamic creditCardTextfield)? onTextField;

  /// true = cobra; false = salva no Vault e retorna JSON minimalista.
  final bool chargeOnConfirm;

  /// Recebe APENAS { token, name, last4 } (dinâmico pro FF)
  final Future<dynamic> Function(dynamic jsonReturn)? onSave;

  /// Se true, dá dismiss no BottomSheet depois de salvar.
  final bool closeOnSave;

=======
  /// Callback fired on change/submit to emit form JSON to FF
  final Future<dynamic> Function(dynamic creditCardTextfield)? onTextField;

  /// true = charge; false = save to Vault
  final bool chargeOnConfirm;

  /// Receives a minimal JSON { token, name, last4 }
  final Future<dynamic> Function(dynamic jsonReturn)? onSave;

  /// Dismiss bottom sheet after save
  final bool closeOnSave;

  /// Enable 3D Secure verification for charge mode
  final bool enableThreeDS;

>>>>>>> 10c9b5c (new frkdfm)
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
  bool _isPaying = false;

  static const kBgDark = Color(0xFF232323);
  static const kFieldOrange = Color(0xFFFF9F1C);
  static const kPillStart = Color(0xFFFFC107);
  static const kPillEnd = Color(0xFFFF7A00);

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _emitState(event: 'change'); // estado inicial
=======
    _emitState(event: 'change'); // initial state
>>>>>>> 10c9b5c (new frkdfm)
  }

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
    final ctaLabel = widget.chargeOnConfirm
<<<<<<< HEAD
        ? (_isPaying ? 'Processing…' : 'Confirm and Pay')
        : (_isPaying ? 'Saving…' : 'Save');

=======
        ? (_isPaying ? 'Processing...' : 'Confirm and Pay')
        : (_isPaying ? 'Saving...' : 'Save');
>>>>>>> 10c9b5c (new frkdfm)
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
                _cardNumberField(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _expiryField()),
                    const SizedBox(width: 12),
                    Expanded(child: _cvvField()),
                  ],
                ),
                const SizedBox(height: 12),
                _holderField(),
                const SizedBox(height: 12),
                _secureBadge(),
                const SizedBox(height: 16),
                _pillButton(
                  label: ctaLabel,
                  onTap: _isPaying ? null : _onConfirmPressed,
                  loading: _isPaying,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =======================
<<<<<<< HEAD
  // CONFIRMAR (pagar ou só salvar)
=======
  // CONFIRM (charge or save)
>>>>>>> 10c9b5c (new frkdfm)
  // =======================
  Future<void> _onConfirmPressed() async {
    HapticFeedback.selectionClick();

<<<<<<< HEAD
    // ---------- MODO SALVAR (VAULT) ----------
    if (!widget.chargeOnConfirm) {
      // exige os 4 campos
      if (!(_formKey.currentState?.validate() ?? false)) {
        await _emitState(event: 'submit', mode: 'save');
        showSnackbar(context, 'Complete os dados do cartão.');
        return;
      }

      if (kIsWeb) {
        showSnackbar(context, 'Saving on web is not supported.');
=======
    // ---------- SAVE MODE (Vault) ----------
    if (!widget.chargeOnConfirm) {
      // require all fields
      if (!(_formKey.currentState?.validate() ?? false)) {
        showSnackbar(context, 'Please fill in all fields.');
>>>>>>> 10c9b5c (new frkdfm)
        return;
      }

      final precheckError = await _ensureReady();
      if (precheckError != null) {
        showSnackbar(context, precheckError);
        return;
      }

<<<<<<< HEAD
      final data = _collect();

      try {
        setState(() => _isPaying = true);

        // 1) Tokenize
        final req = BraintreeCreditCardRequest(
          cardNumber: data.number,
          expirationMonth: data.month,
          expirationYear: data.year,
          cvv: data.cvv,
          cardholderName: data.holder,
        );

        BraintreePaymentMethodNonce? result;
        try {
          result = await Braintree.tokenizeCreditCard(
            widget.tokenizationKey,
            req,
          );
=======
      setState(() => _isPaying = true);

      try {
        final data = _collect();

        // 1) Tokenize in client
        String nonce;
        try {
          final res = await BraintreeNative.tokenizeCard(
            tokenizationKey: widget.tokenizationKey,
            number: data.number,
            expirationMonth: data.month,
            expirationYear: data.year,
            cvv: data.cvv,
            cardholderName: data.holder.isEmpty ? null : data.holder,
          );
          nonce = (res['nonce'] as String?) ?? '';
>>>>>>> 10c9b5c (new frkdfm)
        } on PlatformException catch (pe) {
          showSnackbar(context, _friendlyBraintreeError(pe));
          return;
        }

<<<<<<< HEAD
        if (result == null) {
          showSnackbar(context, 'Operação cancelada.');
          return;
        }

        final nonce = result.nonce;

        // 2) Salvar no Vault via Cloud Function
=======
        if (nonce.isEmpty) {
          showSnackbar(context, 'Operation cancelled.');
          return;
        }

        // 2) Save to Vault via Cloud Function
>>>>>>> 10c9b5c (new frkdfm)
        final isSandbox = widget.tokenizationKey.trim().startsWith('sandbox_');
        final saved = await _callSavePaymentMethodCallable(
          nonce: nonce,
          isProd: !isSandbox,
        );

        if (saved.errorMessage != null) {
          showSnackbar(context, saved.errorMessage!);
          return;
        }

<<<<<<< HEAD
        // JSON enriquecido para a UI
=======
        // JSON for UI
>>>>>>> 10c9b5c (new frkdfm)
        final brand = _detectBrand(data.number);
        final jsonReturn = <String, dynamic>{
          'token': saved.token ?? '',
          'name': saved.name ?? data.holder,
          'last4': saved.last4 ??
              (data.number.length >= 4
                  ? data.number.substring(data.number.length - 4)
                  : ''),
          'numberMasked': _maskNumber(data.number),
          'brand': brand,
          'expMonth': data.month,
          'expYear': data.year,
        };

        try {
          if (widget.onSave != null) {
            await widget.onSave!(jsonReturn);
          } else if (widget.onTextField != null) {
            await widget.onTextField!({
              'event': 'saved',
              'json': jsonReturn,
            });
          }
        } catch (_) {}

<<<<<<< HEAD
        showSnackbar(context, 'Cartão salvo.');
=======
        showSnackbar(context, 'Card saved.');
>>>>>>> 10c9b5c (new frkdfm)
        if (widget.closeOnSave) {
          await _dismiss();
        }
      } catch (e) {
        if (kDebugPayments) debugPrint('Save failure: $e');
<<<<<<< HEAD
        showSnackbar(context, 'Erro inesperado ao salvar.');
=======
        showSnackbar(context, 'Unexpected error while saving.');
>>>>>>> 10c9b5c (new frkdfm)
      } finally {
        if (mounted) setState(() => _isPaying = false);
      }
      return;
    }

<<<<<<< HEAD
    // ---------- MODO PAGAR ----------
    if (!(_formKey.currentState?.validate() ?? false)) {
      await _emitState(event: 'submit', mode: 'charge');
      return;
    }

    if (kIsWeb) {
      showSnackbar(context, 'Payments are not supported on web.');
      return;
    }
=======
    // ---------- CHARGE MODE ----------
    if (!(_formKey.currentState?.validate() ?? false)) return;
>>>>>>> 10c9b5c (new frkdfm)

    final precheckError = await _ensureReady();
    if (precheckError != null) {
      showSnackbar(context, precheckError);
      return;
    }

<<<<<<< HEAD
    try {
      HapticFeedback.lightImpact();
      setState(() => _isPaying = true);

      final data = _collect();

      showSnackbar(
        context,
        'Processing your payment…',
        duration: 8,
        loading: true,
      );

      // 1) Tokenize
      final req = BraintreeCreditCardRequest(
        cardNumber: data.number,
        expirationMonth: data.month,
        expirationYear: data.year,
        cvv: data.cvv,
      );

      BraintreePaymentMethodNonce? result;
      try {
        result = await Braintree.tokenizeCreditCard(
          widget.tokenizationKey,
          req,
        );
=======
    setState(() => _isPaying = true);

    try {
      final data = _collect();

      // 1) Tokenize
      String nonce;
      try {
        final res = await BraintreeNative.tokenizeCard(
          tokenizationKey: widget.tokenizationKey,
          number: data.number,
          expirationMonth: data.month,
          expirationYear: data.year,
          cvv: data.cvv,
          cardholderName: data.holder.isEmpty ? null : data.holder,
        );
        nonce = (res['nonce'] as String?) ?? '';
>>>>>>> 10c9b5c (new frkdfm)
      } on PlatformException catch (pe) {
        if (kDebugPayments) {
          debugPrint(
              'Braintree PlatformException: code=${pe.code} message=${pe.message} details=${pe.details}');
        }
        showSnackbar(context, _friendlyBraintreeError(pe));
        return;
      }

<<<<<<< HEAD
      if (result == null) {
        showSnackbar(context, 'Operação cancelada.');
        return;
      }

      final nonce = result.nonce;

      // 2) Server
=======
      if (nonce.isEmpty) {
        showSnackbar(context, 'Operation cancelled.');
        return;
      }

      // 2) Optional: 3D Secure verification before charging
      if (widget.enableThreeDS) {
        try {
          final threeDS = await BraintreeNative.threeDSecureVerify(
            tokenizationKey: widget.tokenizationKey,
            nonce: nonce,
            amount: widget.value.toStringAsFixed(2),
            email: currentUserEmail,
          );
          final threeDSNonce = (threeDS['nonce'] as String?) ?? '';
          if (threeDSNonce.isNotEmpty) {
            nonce = threeDSNonce;
          }
        } on PlatformException catch (pe) {
          if (kDebugPayments) {
            debugPrint('3DS verify error: code=${pe.code} message=${pe.message}');
          }
          // proceed without 3DS if it fails unexpectedly
        }
      }

      // 3) Server: call Cloud Function
>>>>>>> 10c9b5c (new frkdfm)
      final isSandbox = widget.tokenizationKey.trim().startsWith('sandbox_');
      final pay = await _callProcessPaymentCallable(
        amount: widget.value,
        paymentNonce: nonce,
        isProd: !isSandbox,
      );

      if (pay.errorMessage != null) {
        final msg = pay.errorMessage!;
        showSnackbar(context, msg);
        if (!mounted) return;
        await _emitState(event: 'submit', mode: 'charge');
        await _showErrorBottomSheet(msg);
        return;
      }

      _transactionId = pay.transactionId;
      await _emitState(event: 'submit', mode: 'charge');
      showSnackbar(context, 'Payment approved!');

      if (_transactionId != null && _transactionId!.isNotEmpty) {
        try {
          await currentUserReference?.update(
            createUsersRecordData(passe: 'day'),
          );
        } catch (_) {}
        if (!mounted) return;
        await _showSuccessBottomSheet(widget.passe);
      } else {
        if (!mounted) return;
        await _showErrorBottomSheet('Transaction returned no ID.');
      }
    } catch (e) {
      if (kDebugPayments) debugPrint('Payment failure: $e');
      if (!mounted) return;
      await _emitState(event: 'submit', mode: 'charge');
      showSnackbar(context, 'Unexpected error while processing payment.');
      await _showErrorBottomSheet(e.toString());
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  // =======================
<<<<<<< HEAD
  // Form state + JSON emit (para UI)
=======
  // Form state + JSON emit (for UI)
>>>>>>> 10c9b5c (new frkdfm)
  // =======================
  CardData _collect() => CardData(
        number: _digitsOnly(_numberCtrl.text),
        expiry: _expiryCtrl.text.trim(),
        cvv: _cvvCtrl.text.trim(),
        holder: _holderCtrl.text.trim(),
      );

  Future<void> _emitState({String event = 'change', String? mode}) async {
    if (widget.onTextField == null) return;

    final data = _collect();
    final numDigits = data.number;
    final brand = _detectBrand(numDigits);

    final errors = <String, String?>{
      'number': _validateNumber(numDigits),
      'expiry': _validateExpiry(data.expiry),
      'cvv': _validateCvv(data.cvv),
      'holder': _validateHolder(data.holder),
    };
    final isComplete = errors.values.every((e) => e == null);

    final payload = <String, dynamic>{
      'numberMasked': _maskNumber(numDigits),
      'last4': numDigits.length >= 4
          ? numDigits.substring(numDigits.length - 4)
          : null,
      'holder': data.holder,
      'brand': brand,
      'number': numDigits,
      'expiry': data.expiry,
      'expMonth': data.month,
      'expYear': data.year,
      'cvvLength': data.cvv.length,
      'isComplete': isComplete,
      'errors': errors,
      'mode': mode ?? (widget.chargeOnConfirm ? 'charge' : 'save'),
      'event': event,
      if (_transactionId != null) 'transactionId': _transactionId,
    };

    try {
      await widget.onTextField!(payload);
    } catch (_) {}
  }

  // ========== Validators & helpers ==========
  String? _validateNumber(String digits) {
    if (digits.isEmpty) return 'Required';
    if (digits.length < 13 || digits.length > 19) return 'Invalid card number';
    if (!_luhnOk(digits)) return 'Invalid card number';
    return null;
  }

  String? _validateExpiry(String text) {
    final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
    if (text.isEmpty) return 'Required';
    if (!regex.hasMatch(text)) return 'Use MM/YY';
    if (!_isExpiryInFuture(text)) return 'Card expired';
    return null;
  }

  String? _validateCvv(String text) {
    if (text.isEmpty) return 'Required';
    if (text.length < 3 || text.length > 4) return 'Invalid CVV';
    return null;
  }

  String? _validateHolder(String text) {
    if (text.trim().isEmpty) return 'Required';
    if (text.trim().length < 2) return 'Name too short';
    return null;
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  bool _isExpiryInFuture(String mmYY) {
    if (mmYY.length < 5) return false;
    final mm = int.tryParse(mmYY.substring(0, 2));
    final yy = int.tryParse(mmYY.substring(3));
    if (mm == null || yy == null) return false;
    final year = 2000 + yy;
    final now = DateTime.now();
    final lastDay = DateTime(year, mm + 1, 0);
    return lastDay.isAfter(DateTime(now.year, now.month, now.day));
  }

  String _maskNumber(String digits) {
    if (digits.isEmpty) return '';
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buf.write(digits[i]);
      if ((i + 1) % 4 == 0 && i != digits.length - 1) buf.write(' ');
    }
    return buf.toString();
  }

  bool _luhnOk(String digits) {
    int sum = 0;
    bool alt = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alt) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alt = !alt;
    }
    return sum % 10 == 0;
  }

  String _detectBrand(String digits) {
    if (digits.isEmpty) return 'unknown';
    if (RegExp(r'^4').hasMatch(digits)) return 'visa';
    if (RegExp(r'^(5[1-5])').hasMatch(digits) ||
        RegExp(r'^(2(2[2-9]|[3-6]\d|7[01]|720))').hasMatch(digits)) {
      return 'mastercard';
    }
    if (RegExp(r'^(34|37)').hasMatch(digits)) return 'amex';
    if (RegExp(r'^(30[0-5]|3[68])').hasMatch(digits)) return 'diners';
    if (RegExp(r'^(6011|65|64[4-9])').hasMatch(digits)) return 'discover';
    return 'unknown';
  }

  Future<String?> _ensureReady() async {
    final key = widget.tokenizationKey.trim();
    if (key.isEmpty) return 'Invalid setup: tokenizationKey is empty.';
    if (!(key.startsWith('sandbox_') || key.startsWith('production_'))) {
      return 'Suspicious tokenizationKey. Use sandbox_* for test or production_* for live.';
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'You must be signed in.';
    return null;
  }

  // =======================
  // Inputs (onChanged -> _emitState)
  // =======================
  Widget _cardNumberField() {
    return TextFormField(
      controller: _numberCtrl,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(19),
        _CardNumberInputFormatter(),
      ],
      onChanged: (_) => _emitState(event: 'change'),
      validator: (v) => _validateNumber(_digitsOnly(v ?? '')),
      style: const TextStyle(color: Colors.black),
      decoration: _inputDecoration(
        hint: 'Card number',
        icon: Icons.credit_card,
      ),
    );
  }

  Widget _expiryField() {
    return TextFormField(
      controller: _expiryCtrl,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        _ExpiryDateInputFormatter(),
      ],
      onChanged: (_) => _emitState(event: 'change'),
      validator: (v) => _validateExpiry((v ?? '').trim()),
      style: const TextStyle(color: Colors.black),
      decoration: _inputDecoration(
        hint: 'Expiry (MM/YY)',
        icon: Icons.date_range,
      ),
    );
  }

  Widget _cvvField() {
    return TextFormField(
      controller: _cvvCtrl,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      obscureText: true,
<<<<<<< HEAD
      obscuringCharacter: '•',
=======
      obscuringCharacter: '*',
>>>>>>> 10c9b5c (new frkdfm)
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      onChanged: (_) => _emitState(event: 'change'),
      validator: (v) => _validateCvv((v ?? '').trim()),
      style: const TextStyle(color: Colors.black),
      decoration: _inputDecoration(
        hint: 'CVV',
        icon: Icons.lock_outline_rounded,
      ),
    );
  }

  Widget _holderField() {
    return TextFormField(
      controller: _holderCtrl,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      onChanged: (_) => _emitState(event: 'change'),
      validator: (v) => _validateHolder((v ?? '').trim()),
      style: const TextStyle(color: Colors.black),
      decoration: _inputDecoration(
        hint: 'Name on card',
        icon: Icons.person_outline,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: kFieldOrange,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: Icon(icon, color: Colors.black),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    );
  }

  // =======================
  // CTA button
  // =======================
  Widget _pillButton({
    required String label,
    required Future<void> Function()? onTap,
    bool loading = false,
  }) {
    final enabled = onTap != null && !loading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: enabled ? 1 : 0.7,
      child: GestureDetector(
        onTapDown: (_) => HapticFeedback.lightImpact(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPillStart, kPillEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.black),
                )
              : Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E1E),
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _secureBadge() {
    return Semantics(
      label: 'Secure payment. Your data is sent over an encrypted connection.',
      child: Row(
        children: const [
          Icon(Icons.lock_outline_rounded, size: 18, color: Colors.white70),
          SizedBox(width: 8),
          Expanded(
            child: Text(
<<<<<<< HEAD
              'Secure payment via Quicky© platform.',
=======
              'Secure payment via Quicky platform.',
>>>>>>> 10c9b5c (new frkdfm)
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

  Future<void> _showSuccessBottomSheet(String passe) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
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
                  'Payment approved!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pass: $passe\nTransaction: ${_transactionId ?? '-'}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                _pillButton(
                  label: 'Close',
                  onTap: () async {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showErrorBottomSheet([String? message]) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
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
<<<<<<< HEAD
                  'We couldn’t process your payment.',
=======
                  'We could not process your payment.',
>>>>>>> 10c9b5c (new frkdfm)
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (message != null && message.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _pillButton(
                  label: 'Try again',
                  onTap: () async {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _dismiss() async {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  Future<PaymentResponse> _callProcessPaymentCallable({
    required double amount,
    required String paymentNonce,
    bool isProd = false,
  }) async {
    try {
<<<<<<< HEAD
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final name = isProd ? 'processBraintreePayment' : 'processBraintreeTestPayment';
      final callable = functions.httpsCallable(name);

      final resp = await callable.call(<String, dynamic>{
        'amount': amount.toStringAsFixed(2),
        'paymentNonce': paymentNonce,
      });

      final data = Map<String, dynamic>.from(resp.data as Map);
=======
      final regions = <String>['us-central1', 'southamerica-east1', 'us-east1', 'europe-west1'];
      final name = isProd ? 'processBraintreePayment' : 'processBraintreeTestPayment';

      Future<HttpsCallableResult<dynamic>> callOn(FirebaseFunctions fns, String n) async {
        return await fns.httpsCallable(n).call(<String, dynamic>{
          'amount': amount.toStringAsFixed(2),
          'paymentNonce': paymentNonce,
        });
      }

      HttpsCallableResult<dynamic>? resp;
      final alt = isProd ? 'processBraintreeTestPayment' : 'processBraintreePayment';
      FirebaseFunctionsException? lastErr;
      for (final region in regions) {
        final fns = FirebaseFunctions.instanceFor(region: region);
        try {
          resp = await callOn(fns, name);
          break;
        } on FirebaseFunctionsException catch (e1) {
          lastErr = e1;
          if (e1.code == 'not-found') {
            try {
              resp = await callOn(fns, alt);
              break;
            } on FirebaseFunctionsException catch (e2) {
              lastErr = e2;
              continue;
            }
          } else {
            continue;
          }
        }
      }
      if (resp == null && lastErr != null) { throw lastErr!; }

      final data = Map<String, dynamic>.from(resp!.data as Map);
>>>>>>> 10c9b5c (new frkdfm)
      return PaymentResponse(transactionId: data['transactionId'] as String?);
    } on FirebaseFunctionsException catch (e) {
      final parts = <String>[];
      if (e.message != null && e.message!.trim().isNotEmpty) {
        parts.add(e.message!.trim());
      }
      if (e.details != null && e.details.toString().trim().isNotEmpty) {
        parts.add(e.details.toString().trim());
      }
      parts.add('CODE: ${e.code.toUpperCase()}');
<<<<<<< HEAD
      final msg = parts.join(' · ');
=======
      final msg = parts.join(' • ');
>>>>>>> 10c9b5c (new frkdfm)
      if (kDebugPayments) {
        debugPrint('[PAY][FunctionsException] $msg');
      }
      return PaymentResponse(errorMessage: msg);
    } catch (e) {
      if (kDebugPayments) debugPrint('[PAY][Exception] $e');
      return PaymentResponse(errorMessage: e.toString());
    }
  }

  Future<SaveMethodResponse> _callSavePaymentMethodCallable({
    required String nonce,
    bool isProd = false,
  }) async {
    try {
<<<<<<< HEAD
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final name = isProd ? 'savePaymentMethod' : 'savePaymentMethodTest';
      final callable = functions.httpsCallable(name);

      final resp = await callable.call(<String, dynamic>{
        'nonce': nonce,
        // opcional: 'customerId': 'u_${FirebaseAuth.instance.currentUser?.uid}',
      });

      final data = Map<String, dynamic>.from(resp.data as Map);
=======
      final regions = <String>['us-central1', 'southamerica-east1', 'us-east1', 'europe-west1'];
      final name = isProd ? 'savePaymentMethod' : 'savePaymentMethodTest';
      final payload = <String, dynamic>{
        'nonce': nonce,
        'customerId': 'u_${FirebaseAuth.instance.currentUser?.uid}',
      };

      Future<HttpsCallableResult<dynamic>> callOn(FirebaseFunctions fns, String n) async {
        return await fns.httpsCallable(n).call(payload);
      }

      HttpsCallableResult<dynamic>? resp;
      final alt = isProd ? 'savePaymentMethodTest' : 'savePaymentMethod';
      FirebaseFunctionsException? lastErr;
      for (final region in regions) {
        final fns = FirebaseFunctions.instanceFor(region: region);
        try {
          resp = await callOn(fns, name);
          break;
        } on FirebaseFunctionsException catch (e1) {
          lastErr = e1;
          if (e1.code == 'not-found') {
            try {
              resp = await callOn(fns, alt);
              break;
            } on FirebaseFunctionsException catch (e2) {
              lastErr = e2;
              continue;
            }
          } else {
            continue;
          }
        }
      }
      if (resp == null && lastErr != null) { throw lastErr!; }

      final data = Map<String, dynamic>.from(resp!.data as Map);
>>>>>>> 10c9b5c (new frkdfm)
      return SaveMethodResponse(
        token: data['token'] as String?,
        last4: data['last4'] as String?,
        name: data['name'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      final parts = <String>[];
      if (e.message != null && e.message!.trim().isNotEmpty) {
        parts.add(e.message!.trim());
      }
      if (e.details != null && e.details.toString().trim().isNotEmpty) {
        parts.add(e.details.toString().trim());
      }
      parts.add('CODE: ${e.code.toUpperCase()}');
<<<<<<< HEAD
      final msg = parts.join(' · ');
=======
      final msg = parts.join(' • ');
>>>>>>> 10c9b5c (new frkdfm)
      if (kDebugPayments) {
        debugPrint('[SAVE][FunctionsException] $msg');
      }
      return SaveMethodResponse(errorMessage: msg);
    } catch (e) {
      if (kDebugPayments) debugPrint('[SAVE][Exception] $e');
      return SaveMethodResponse(errorMessage: e.toString());
    }
  }
}

<<<<<<< HEAD
// ====== Formatadores ======
=======
// ====== Formatters ======
>>>>>>> 10c9b5c (new frkdfm)
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final isLast = i == digits.length - 1;
      if (!isLast && (i + 1) % 4 == 0) buffer.write(' ');
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);

    String mm = '';
    String yy = '';
    if (digits.length >= 2) {
      mm = digits.substring(0, 2);
      final m = int.tryParse(mm) ?? 0;
      if (m == 0) {
        mm = '01';
      } else if (m > 12) {
        mm = '12';
      }
      yy = digits.length > 2 ? digits.substring(2) : '';
    } else {
      mm = digits;
    }

    final formatted = yy.isNotEmpty ? '$mm/$yy' : mm;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ====== Tokenization error mapping ======
String _friendlyBraintreeError(Object e) {
  if (e is PlatformException) {
    final code = e.code.toLowerCase();
    final msg = (e.message ?? '').toLowerCase();
    if (code.contains('network') || msg.contains('network')) {
      return 'Network error while tokenizing. Check your connection and try again.';
    }
    if (msg.contains('authorization') || msg.contains('invalid token')) {
      return 'Invalid/incompatible tokenization key. Use a sandbox_* key from the same merchant as your server.';
    }
    return e.message ?? e.code;
  }
  return e.toString();
}
<<<<<<< HEAD
=======

>>>>>>> 10c9b5c (new frkdfm)
