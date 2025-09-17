import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'card_payment_model.dart';
export 'card_payment_model.dart';
import 'card_added_success_widget.dart';

/// Bottom sheet to handle card payments via CardFormFF
class CardPaymentWidget extends StatefulWidget {
  const CardPaymentWidget({
    super.key,
    required this.value,
    required this.passe,
    bool? pagamento,
<<<<<<< HEAD
<<<<<<< HEAD
  }) : this.pagamento = pagamento ?? false;
=======
  }) : pagamento = pagamento ?? false;
>>>>>>> 10c9b5c (new frkdfm)
=======
  }) : pagamento = pagamento ?? false;
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be

  final double? value;
  final String? passe;
  final bool pagamento;

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
      alignment: const AlignmentDirectional(0.0, 1.0),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.8,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryText,
          boxShadow: const [
            BoxShadow(
              blurRadius: 10.0,
              color: Color(0x33000000),
              offset: Offset(0.0, -2.0),
            )
          ],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
<<<<<<< HEAD
<<<<<<< HEAD
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FFLocalizations.of(context).getText(
                      'p8t6d1h2' /* Payment Method */,
                    ),
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .fontWeight,
                            fontStyle: FontStyle.italic,
                          ),
                          color: FlutterFlowTheme.of(context).alternate,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .fontWeight,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  Text(
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
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ].divide(SizedBox(height: 8.0)),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      if (widget.pagamento)
                        FFButtonWidget(
                          onPressed: () {
                            print('Button pressed ...');
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
                      if (widget.pagamento)
                        FFButtonWidget(
                          onPressed: () {
                            print('Button pressed ...');
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
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
              const SizedBox(height: 16),
              Text(
                FFLocalizations.of(context).getText('p8t6d1h2' /* Payment Method */),
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                        fontStyle: FontStyle.italic,
                      ),
                      color: FlutterFlowTheme.of(context).alternate,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                      fontStyle: FontStyle.italic,
                    ),
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
              ),
              const SizedBox(height: 8),
              Text(
                FFLocalizations.of(context)
                    .getText('9j9a154z' /* Credit Card Information */),
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).titleMedium.fontWeight,
                        fontStyle: FontStyle.italic,
                      ),
                      color: FlutterFlowTheme.of(context).alternate,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).titleMedium.fontWeight,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                width: MediaQuery.sizeOf(context).width * 0.9,
                height: 330.0,
                child: custom_widgets.CardFormFF(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  height: 330.0,
                  value: widget.value!,
                  passe: widget.passe!,
                  tokenizationKey: 'sandbox_ck9vkcgg_brg8dhjg5tqpw496',
                  chargeOnConfirm: widget.pagamento,
                  closeOnSave: true,
                  // Apenas acompanha mudanças para UI (não salva aqui)
                  onTextField: (creditCardTextfield) async {
                    // Ignora eventos de digitação para não poluir o estado.
                  },
                  // Salva somente quando o cartão foi tokenizado e salvo no Vault.
                  onSave: (jsonReturn) async {
                    try {
                      if (jsonReturn is Map) {
                        // Upsert por token/brand+numberMasked
                        final token = (jsonReturn['token'] ?? '').toString();
                        final brand = (jsonReturn['brand'] ?? '').toString();
                        final masked = (jsonReturn['numberMasked'] ?? '').toString();

                        final list = FFAppState().creditCardSalves;
                        int idx = -1;
                        for (int i = 0; i < list.length; i++) {
                          final it = list[i];
                          if (it is Map) {
                            final t = (it['token'] ?? '').toString();
                            final b = (it['brand'] ?? '').toString();
                            final m = (it['numberMasked'] ?? '').toString();
                            if (token.isNotEmpty && t.isNotEmpty && t == token) {
                              idx = i;
                              break;
                            }
                            if (token.isEmpty && b == brand && m == masked) {
                              idx = i;
                              break;
                            }
                          }
                        }
                        if (idx >= 0) {
                          FFAppState().update(() {
                            FFAppState().updateCreditCardSalvesAtIndex(idx, (_) => jsonReturn);
                          });
                        } else {
                          FFAppState().update(() {
                            FFAppState().addToCreditCardSalves(jsonReturn);
                          });
                        }

                        // Se não há default ainda, define este como default
                        if (FFAppState().defaultCard == null) {
                          FFAppState().defaultCard = jsonReturn;
                        }
                        safeSetState(() {});

                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: false,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => CardAddedSuccessWidget(
                            card: Map<String, dynamic>.from(jsonReturn),
                          ),
                        );
                      }
                    } catch (_) {}
                  },
                ),
              ),
<<<<<<< HEAD
<<<<<<< HEAD
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
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.9,
                        height: 330.0,
                        child: custom_widgets.CardFormFF(
                          width: MediaQuery.sizeOf(context).width * 0.9,
                          height: 330.0,
                          value: widget.value!,
                          passe: widget.passe!,
                          tokenizationKey: 'sandbox_ck9vkcgg_brg8dhjg5tqpw496',
                          chargeOnConfirm: widget.pagamento,
                          closeOnSave: true,
                          onTextField: (creditCardTextfield) async {
                            FFAppState()
                                .addToCreditCardSalves(creditCardTextfield);
                            safeSetState(() {});
                          },
                          onSave: (jsonReturn) async {},
                        ),
                      ),
                    ].divide(SizedBox(height: 12.0)),
                  ),
                ].divide(SizedBox(height: 16.0)),
              ),
            ].divide(SizedBox(height: 20.0)),
=======
            ],
>>>>>>> 10c9b5c (new frkdfm)
=======
            ],
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
          ),
        ),
      ),
    );
  }
}
