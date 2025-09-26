import '/backend/braintree/payment_manager.dart';
import '/flutter_flow/flutter_flow_credit_card_form.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/schema/structs/payment_method_save_struct.dart';
import '/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '/backend/braintree/native_bridge.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'save_card_payment_model.dart';
export 'save_card_payment_model.dart';

/// crie um bottom sheet para realizar pagamentos com o google pay, apple pay
/// e cartao de credito
class SaveCardPaymentWidget extends StatefulWidget {
  const SaveCardPaymentWidget({super.key});

  @override
  State<SaveCardPaymentWidget> createState() => _SaveCardPaymentWidgetState();
}

class _SaveCardPaymentWidgetState extends State<SaveCardPaymentWidget> {
  late SaveCardPaymentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SaveCardPaymentModel());
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
                        '0pw9zd4r' /* Save Payment Method */,
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
                  // Google Pay button intentionally not included here to keep this sheet compact.
                  Align(
                    alignment: AlignmentDirectional(0.0, -1.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'yossibud' /* Choose your preferred payment ... */,
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
                      if (isAndroid)
                        FFButtonWidget(
                          onPressed: () async {
                            logFirebaseEvent(
                                'SAVE_CARD_PAYMENT_GPAY_BTN_ON_TAP');
                            logFirebaseEvent('Button_braintree_payment');
                            if (kIsWeb) {
                              showSnackbar(context,
                                  'Payments not yet supported on web.');
                              return;
                            }
                            try {
                              // Use a nominal amount just to obtain a Google Pay nonce for vaulting
                              final nonce = await BraintreeNativeBridge.googlePay(
                                authorization: braintreeClientToken(),
                                amount: 1.00.toStringAsFixed(2),
                                currencyCode: 'USD',
                              );
                              if (nonce == null || nonce.isEmpty) {
                                showSnackbar(
                                  context,
                                  'Google Pay cancelado ou sem método retornado.',
                                );
                                return;
                              }
                              showSnackbar(
                                context,
                                'Saving payment method...',
                                duration: 10,
                                loading: true,
                              );
                              final shouldMakeDefault = FFAppState()
                                      .paymentMethods
                                      .isEmpty ||
                                  !FFAppState()
                                      .paymentMethods
                                      .any((e) => e.isDefault);
                              final resp = await saveBraintreePaymentMethod(
                                nonce,
                                makeDefault: shouldMakeDefault,
                              );
                              final ok =
                                  (resp['success'] == true) || (resp['ok'] == true);
                              if (!ok) {
                                final err = resp['error'] ??
                                    'Failed to save payment method.';
                                showSnackbar(context, 'Error: $err');
                                return;
                              }

                              final pm = (resp['paymentMethod'] ?? {}) as Map;
                              final brand = (pm['brand'] ?? '') as String;
                              final last4 =
                                  (pm['last4Numbers'] ?? pm['last4'] ?? '') as String;
                              final token = (pm['paymentMethodToken'] ??
                                      pm['token'] ??
                                      '')
                                  as String;
                              final isDefault =
                                  (pm['isDefault'] ?? pm['default'] ?? false) as bool;

                              if (token.isEmpty) {
                                showSnackbar(context,
                                    'Error: Missing payment method token.');
                                return;
                              }

                              FFAppState().addToPaymentMethods(
                                createPaymentMethodSaveStruct(
                                  brand: brand.isNotEmpty ? brand : 'Card',
                                  last4Numbers: last4,
                                  paymentMethodToken: token,
                                  isDefault: isDefault,
                                ),
                              );

                              showSnackbar(context, 'Card saved.');
                              Navigator.of(context).pop(true);
                            } catch (e) {
                              showSnackbar(
                                  context, 'Google Pay failed: ${e.toString()}');
                            }
                          },
                          text: FFLocalizations.of(context).getText(
                            '3hwrt0xn' /* Pay with Google Pay */,
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
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
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
                  Stack(
                    children: [
                      if (isiOS)
                        FFButtonWidget(
                          onPressed: () async {
                            logFirebaseEvent(
                                'SAVE_CARD_PAYMENT_APPLE_PAY_BTN_ON_TAP');
                            logFirebaseEvent('Button_braintree_payment');
                            if (kIsWeb) {
                              showSnackbar(context,
                                  'Payments not yet supported on web.');
                              return;
                            }
                            try {
                              final nonce = await BraintreeNativeBridge.applePay(
                                authorization: braintreeClientToken(),
                                amount: 1.00.toStringAsFixed(2),
                                currencyCode: 'USD',
                                merchantIdentifier: appleMerchantId(),
                                displayName: 'Ride Bahamas',
                              );
                              if (nonce == null || nonce.isEmpty) return;
                              showSnackbar(
                                context,
                                'Saving payment method...',
                                duration: 10,
                                loading: true,
                              );
                              final shouldMakeDefault = FFAppState()
                                      .paymentMethods
                                      .isEmpty ||
                                  !FFAppState()
                                      .paymentMethods
                                      .any((e) => e.isDefault);
                              final resp = await saveBraintreePaymentMethod(
                                nonce,
                                makeDefault: shouldMakeDefault,
                              );
                              final ok =
                                  (resp['success'] == true) || (resp['ok'] == true);
                              if (!ok) {
                                final err = resp['error'] ??
                                    'Failed to save payment method.';
                                showSnackbar(context, 'Error: $err');
                                return;
                              }

                              final pm = (resp['paymentMethod'] ?? {}) as Map;
                              final brand = (pm['brand'] ?? '') as String;
                              final last4 =
                                  (pm['last4Numbers'] ?? pm['last4'] ?? '') as String;
                              final token = (pm['paymentMethodToken'] ??
                                      pm['token'] ??
                                      '')
                                  as String;
                              final isDefault =
                                  (pm['isDefault'] ?? pm['default'] ?? false) as bool;

                              if (token.isEmpty) {
                                showSnackbar(context,
                                    'Error: Missing payment method token.');
                                return;
                              }

                              FFAppState().addToPaymentMethods(
                                createPaymentMethodSaveStruct(
                                  brand: brand.isNotEmpty ? brand : 'Card',
                                  last4Numbers: last4,
                                  paymentMethodToken: token,
                                  isDefault: isDefault,
                                ),
                              );

                              showSnackbar(context, 'Card saved.');
                              Navigator.of(context).pop(true);
                            } catch (e) {
                              showSnackbar(
                                  context, 'Apple Pay failed: ${e.toString()}');
                            }
                          },
                          text: FFLocalizations.of(context).getText(
                            'q3lwkya8' /* Pay with Apple Pay */,
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
                      'sb1xr1ba' /* Credit Card Information */,
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
                          if (!(_model.creditCardFormKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          if (kIsWeb) {
                            showSnackbar(context, 'Saving cards on web is not supported.');
                            return;
                          }

                          // Tokenize card to get a nonce
                          final cc = _model.creditCardInfo;
                          final expParts = cc.expiryDate.split('/');
                          final tokenizationKey = braintreeClientToken();
                          try {
                            final tokenized = await BraintreeNativeBridge.tokenizeCard(
                              authorization: tokenizationKey,
                              number: cc.cardNumber,
                              expirationMonth: expParts.isNotEmpty ? expParts.first : '',
                              expirationYear: expParts.length > 1 ? expParts.last : '',
                              cvv: cc.cvvCode,
                              amount: '0.00',
                            );
                            if (tokenized == null || tokenized.isEmpty) {
                              showSnackbar(context, 'Falha ao tokenizar o cartão.');
                              return;
                            }

                            showSnackbar(context, 'Saving card...', duration: 10, loading: true);
                            final shouldMakeDefault = FFAppState().paymentMethods.isEmpty ||
                                !FFAppState().paymentMethods.any((e) => e.isDefault);
                            final resp = await saveBraintreePaymentMethod(
                              tokenized,
                              makeDefault: shouldMakeDefault,
                            );
                            final ok = (resp['success'] == true) || (resp['ok'] == true);
                            if (!ok) {
                              final err = resp['error'] ?? 'Failed to save payment method.';
                              showSnackbar(context, 'Error: $err');
                              return;
                            }

                            final pm = (resp['paymentMethod'] ?? {}) as Map;
                            final brand = (pm['brand'] ?? '') as String;
                            final last4 = (pm['last4Numbers'] ?? pm['last4'] ?? '') as String;
                            final token = (pm['paymentMethodToken'] ?? pm['token'] ?? '') as String;
                            final isDefault = (pm['isDefault'] ?? pm['default'] ?? false) as bool;

                            if (token.isEmpty) {
                              showSnackbar(context, 'Error: Missing payment method token.');
                              return;
                            }

                            // Save locally in app state
                            FFAppState().addToPaymentMethods(
                              createPaymentMethodSaveStruct(
                                brand: brand.isNotEmpty ? brand : 'Card',
                                last4Numbers: last4.isNotEmpty
                                    ? last4
                                    : (cc.cardNumber.length >= 4
                                        ? cc.cardNumber.substring(cc.cardNumber.length - 4)
                                        : ''),
                                paymentMethodToken: token,
                                isDefault: isDefault,
                              ),
                            );

                            showSnackbar(context, 'Card saved.');
                            // Close bottom sheet and signal success to caller
                            Navigator.of(context).pop(true);
                          } catch (e) {
                            showSnackbar(context, 'Failed to save card: $e');
                          }
                        },
                        text: FFLocalizations.of(context).getText(
                          '88csuyfb' /* Save Credit Card */,
                        ),
                        options: FFButtonOptions(
                          width: 160.0,
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
