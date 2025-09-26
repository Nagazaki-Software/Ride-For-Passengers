import '/backend/braintree/payment_manager.dart';
import '/flutter_flow/flutter_flow_credit_card_form.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/random_data_util.dart' as random_data;
import '/backend/schema/structs/payment_method_save_struct.dart';
import '/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Using native platform channel bridge (Android: Kotlin, iOS: Swift)
import '/backend/braintree/native_bridge.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'card_payment_model.dart';
export 'card_payment_model.dart';

/// crie um bottom sheet para realizar pagamentos com o google pay, apple pay
/// e cartao de credito
class CardPaymentWidget extends StatefulWidget {
  const CardPaymentWidget({
    super.key,
    required this.value,
    required this.passe,
    bool? pagamento,
    bool? autoRenew,
  })  : this.pagamento = pagamento ?? false,
        this.autoRenew = autoRenew ?? false;

  final double? value;
  final String? passe;
  final bool pagamento;
  final bool autoRenew;

  @override
  State<CardPaymentWidget> createState() => _CardPaymentWidgetState();
}

class _CardPaymentWidgetState extends State<CardPaymentWidget> {
  late CardPaymentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CardPaymentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.65,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryText,
          boxShadow: [
            BoxShadow(
              blurRadius: 10.0,
              color: Color(0x33000000),
              offset: Offset(
                0.0,
                -2.0,
              ),
              spreadRadius: 0.0,
            )
          ],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, -1.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'p8t6d1h2' /* Payment Method */,
                      ),
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontWeight,
                                  fontStyle: FontStyle.italic,
                                ),
                                color: FlutterFlowTheme.of(context).alternate,
                                fontSize: 22.0,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .fontWeight,
                                fontStyle: FontStyle.italic,
                              ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, -1.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'a008km1g' /* Choose your preferred payment ... */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                ].divide(SizedBox(height: 8.0)),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      if (widget.pagamento && isAndroid)
                        FFButtonWidget(
                          onPressed: () async {
                            logFirebaseEvent(
                                'CARD_PAYMENT_PAY_WITH_GOOGLE_PAY_BTN_ON_');
                            logFirebaseEvent('Button_braintree_payment');
                            final transacAmount = widget.value!;
                            final transacDisplayName =
                                'RIDE-${random_data.randomInteger(0, 6).toString()}';
                            if (kIsWeb) {
                              showSnackbar(context,
                                  'Payments not yet supported on web.');
                              return;
                            }

                            // Using native Google Pay flow via braintree_native_ui
                            try {
                              final nonce = await BraintreeNativeBridge.googlePay(
                                authorization: braintreeClientToken(),
                                amount: transacAmount.toStringAsFixed(2),
                                currencyCode: 'USD',
                              );
                              if (nonce == null || nonce.isEmpty) return;
                              showSnackbar(
                                context,
                                'Processing payment...',
                                duration: 10,
                                loading: true,
                              );
                              final paymentResponse = await processBraintreePayment(
                                transacAmount,
                                nonce,
                              );
                              if (paymentResponse.errorMessage != null) {
                                showSnackbar(context,
                                    'Error: ${paymentResponse.errorMessage}');
                                return;
                              }
                              // Persist saved payment method locally if provided by server
                              final pm = paymentResponse.paymentMethodMeta;
                              if (pm != null && pm.isNotEmpty) {
                                final brand = (pm['brand'] ?? '') as String;
                                final last4 = (pm['last4Numbers'] ?? pm['last4'] ?? '') as String;
                                final token = (pm['paymentMethodToken'] ?? pm['token'] ?? '') as String;
                                final isDefault = (pm['isDefault'] ?? pm['default'] ?? false) as bool;
                                if (token.isNotEmpty) {
                                  FFAppState().addToPaymentMethods(
                                    createPaymentMethodSaveStruct(
                                      brand: brand.isNotEmpty ? brand : 'Card',
                                      last4Numbers: last4,
                                      paymentMethodToken: token,
                                      isDefault: isDefault,
                                    ),
                                  );
                                }
                              }
                              showSnackbar(context, 'Success!');
                              _model.transactionId =
                                  paymentResponse.transactionId!;

                              safeSetState(() {});
                            } catch (e) {
                              showSnackbar(
                                context,
                                'Google Pay not available or failed: $e',
                              );
                            }
                          },
                          text: FFLocalizations.of(context).getText(
                            '0skbwu9o' /* Pay with Google Pay */,
                          ),
                          icon: FaIcon(
                            FontAwesomeIcons.googlePay,
                            size: 30.0,
                          ),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50.0,
                            padding: EdgeInsets.all(8.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconColor: FlutterFlowTheme.of(context).primaryText,
                            color: FlutterFlowTheme.of(context).alternate,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Poppins',
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                    ],
                  ),
                  Stack(
                    children: [
                      if (widget.pagamento && isiOS)
                        FFButtonWidget(
                          onPressed: () async {
                            logFirebaseEvent(
                                'CARD_PAYMENT_PAY_WITH_APPLE_PAY_BTN_ON_');
                            logFirebaseEvent('Button_braintree_payment');
                            final transacAmount = widget.value!;
                            if (kIsWeb) {
                              showSnackbar(context,
                                  'Payments not yet supported on web.');
                              return;
                            }

                            try {
                              final nonce = await BraintreeNativeBridge.applePay(
                                authorization: braintreeClientToken(),
                                amount: transacAmount.toStringAsFixed(2),
                                currencyCode: 'USD',
                                merchantIdentifier: appleMerchantId(),
                                displayName: 'Ride Bahamas',
                              );
                              if (nonce == null || nonce.isEmpty) return;
                              showSnackbar(
                                context,
                                'Processing payment...',
                                duration: 10,
                                loading: true,
                              );
                              final paymentResponse = await processBraintreePayment(
                                transacAmount,
                                nonce,
                              );
                              if (paymentResponse.errorMessage != null) {
                                showSnackbar(context,
                                    'Error: ${paymentResponse.errorMessage}');
                                return;
                              }
                              // Persist saved payment method locally if provided by server
                              final pm = paymentResponse.paymentMethodMeta;
                              if (pm != null && pm.isNotEmpty) {
                                final brand = (pm['brand'] ?? '') as String;
                                final last4 = (pm['last4Numbers'] ?? pm['last4'] ?? '') as String;
                                final token = (pm['paymentMethodToken'] ?? pm['token'] ?? '') as String;
                                final isDefault = (pm['isDefault'] ?? pm['default'] ?? false) as bool;
                                if (token.isNotEmpty) {
                                  FFAppState().addToPaymentMethods(
                                    createPaymentMethodSaveStruct(
                                      brand: brand.isNotEmpty ? brand : 'Card',
                                      last4Numbers: last4,
                                      paymentMethodToken: token,
                                      isDefault: isDefault,
                                    ),
                                  );
                                }
                              }
                              showSnackbar(context, 'Success!');
                              _model.transactionId2 =
                                  paymentResponse.transactionId!;

                              safeSetState(() {});
                            } catch (e) {
                              showSnackbar(
                                context,
                                'Apple Pay not available or failed: $e',
                              );
                            }
                          },
                          text: FFLocalizations.of(context).getText(
                            '0cdaev13' /* Pay with Apple Pay */,
                          ),
                          icon: FaIcon(
                            FontAwesomeIcons.applePay,
                            size: 30.0,
                          ),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50.0,
                            padding: EdgeInsets.all(8.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconColor: Colors.white,
                            color: Colors.black,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                    ],
                  ),
                ].divide(SizedBox(height: 12.0)),
              ),
              Container(
                width: double.infinity,
                height: 1.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FFLocalizations.of(context).getText(
                      '9j9a154z' /* Credit Card Information */,
                    ),
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FlutterFlowTheme.of(context)
                                .titleMedium
                                .fontWeight,
                            fontStyle: FontStyle.italic,
                          ),
                          color: FlutterFlowTheme.of(context).alternate,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .titleMedium
                              .fontWeight,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlutterFlowCreditCardForm(
                        formKey: _model.creditCardFormKey,
                        creditCardModel: _model.creditCardInfo,
                        obscureNumber: false,
                        obscureCvv: true,
                        spacing: 12.0,
                        textStyle:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                        inputDecoration: InputDecoration(
                          filled: true,
                          fillColor: FlutterFlowTheme.of(context).primary,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: () async {
                          logFirebaseEvent(
                              'CARD_PAYMENT_COMP_CONFIRM_BTN_ON_TAP');
                          logFirebaseEvent('Button_braintree_payment');
                          final transacAmount = widget.value!;
                          if (!(_model.creditCardFormKey.currentState
                                  ?.validate() ??
                              false)) {
                            return;
                          }
                          if (kIsWeb) {
                            showSnackbar(
                                context, 'Payments not yet supported on web.');
                            return;
                          }

                          // Tokenize the card directly via native UI helper
                          try {
                            final nonce = await BraintreeNativeBridge.tokenizeCard(
                              authorization: braintreeClientToken(),
                              number: _model.creditCardInfo.cardNumber,
                              expirationMonth: _model.creditCardInfo.expiryDate.split('/').first,
                              expirationYear: _model.creditCardInfo.expiryDate.split('/').last,
                              cvv: _model.creditCardInfo.cvvCode,
                              amount: transacAmount.toStringAsFixed(2),
                            );
                            if (nonce == null || nonce.isEmpty) return;
                            showSnackbar(
                              context,
                              'Processing payment...',
                              duration: 10,
                              loading: true,
                            );
                            final paymentResponse = await processBraintreePayment(
                              transacAmount,
                              nonce,
                            );
                            if (paymentResponse.errorMessage != null) {
                              showSnackbar(context,
                                  'Error: ${paymentResponse.errorMessage}');
                              return;
                            }
                            // If server returned saved payment method metadata, persist locally for reuse
                            final pm = paymentResponse.paymentMethodMeta;
                            if (pm != null && pm.isNotEmpty) {
                              final brand = (pm['brand'] ?? '') as String;
                              final last4 = (pm['last4Numbers'] ?? pm['last4'] ?? '') as String;
                              final token = (pm['paymentMethodToken'] ?? pm['token'] ?? '') as String;
                              final isDefault = (pm['isDefault'] ?? pm['default'] ?? false) as bool;
                              if (token.isNotEmpty) {
                                FFAppState().addToPaymentMethods(
                                  createPaymentMethodSaveStruct(
                                    brand: brand.isNotEmpty ? brand : 'Card',
                                    last4Numbers: last4,
                                    paymentMethodToken: token,
                                    isDefault: isDefault,
                                  ),
                                );
                              }
                            }
                            showSnackbar(context, 'Success!');
                            _model.transactionId3 =
                                paymentResponse.transactionId!;

                            safeSetState(() {});
                          } catch (e) {
                            showSnackbar(context, 'Card payment failed: $e');
                          }
                        },
                        text: FFLocalizations.of(context).getText(
                          'hxpv6ouk' /* Confirm */,
                        ),
                        options: FFButtonOptions(
                          width: 120.0,
                          height: 40.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ].divide(SizedBox(height: 12.0)),
                  ),
                ].divide(SizedBox(height: 16.0)),
              ),
            ].divide(SizedBox(height: 20.0)),
          ),
        ),
      ),
    );
  }
}
