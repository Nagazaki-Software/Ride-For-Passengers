<<<<<<< HEAD
<<<<<<< HEAD
=======
// payment_ride7_widget.dart

>>>>>>> 10c9b5c (new frkdfm)
=======
// payment_ride7_widget.dart

>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/components/add_payment_method_widget.dart';
<<<<<<< HEAD
<<<<<<< HEAD
import '/components/card_payment_widget.dart';
=======
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
import '/components/erronopagamento_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
<<<<<<< HEAD
<<<<<<< HEAD
import '/flutter_flow/custom_functions.dart' as functions;
=======
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
import '/flutter_flow/random_data_util.dart' as random_data;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
<<<<<<< HEAD
=======

>>>>>>> 10c9b5c (new frkdfm)
=======

>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
import 'payment_ride7_model.dart';
export 'payment_ride7_model.dart';

class PaymentRide7Widget extends StatefulWidget {
  const PaymentRide7Widget({
    super.key,
    required this.estilo,
    required this.latlngAtual,
    required this.latlngWhereTo,
  });

  final String? estilo;
  final LatLng? latlngAtual;
  final LatLng? latlngWhereTo;

  static String routeName = 'PaymentRide7';
  static String routePath = '/paymentRide7';

  @override
  State<PaymentRide7Widget> createState() => _PaymentRide7WidgetState();
}

class _PaymentRide7WidgetState extends State<PaymentRide7Widget> {
  late PaymentRide7Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentRide7Model());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Se houver um cartão padrão ou pelo menos um salvo, pré-seleciona para evitar null!
    try {
      final def = FFAppState().defaultCard;
      // Mantém apenas cartões válidos (com token ou máscara+brand)
      final raw = FFAppState().creditCardSalves.toList();
      final filtered = <dynamic>[];
      final seen = <String>{};
      for (final c in raw) {
        try {
          final token = getJsonField(c, r'$.token')?.toString() ?? '';
          if (token.isEmpty) continue; // exige token para usar no pagamento
          final key = 't:$token';
          if (seen.add(key)) filtered.add(c);
        } catch (_) {}
      }
      if (def != null && getJsonField(def, r'$.token') != null) {
        _model.selectCard = def;
      } else if (filtered.isNotEmpty) {
        _model.selectCard = filtered.first;
      }
    } catch (_) {
      // silencioso
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _brandOf(dynamic card) {
    final b = getJsonField(card, r'$.brand');
    return (b == null || b.toString().isEmpty) ? 'CARD' : b.toString();
  }

  String _maskedOf(dynamic card) {
    final masked = getJsonField(card, r'$.numberMasked');
    if (masked != null && masked.toString().trim().isNotEmpty) {
      return masked.toString();
    }
    final last4 = getJsonField(card, r'$.last4')?.toString() ?? '____';
    return '**** **** **** $last4';
  }

  bool _sameCard(dynamic a, dynamic b) {
    if (a == null || b == null) return false;
    final ta = getJsonField(a, r'$.token')?.toString();
    final tb = getJsonField(b, r'$.token')?.toString();
    if (ta != null && tb != null && ta.isNotEmpty && tb.isNotEmpty) {
      return ta == tb;
    }
    // fallback pelo numberMasked+brand
    final ma = getJsonField(a, r'$.numberMasked')?.toString();
    final mb = getJsonField(b, r'$.numberMasked')?.toString();
    final ba = getJsonField(a, r'$.brand')?.toString();
    final bb = getJsonField(b, r'$.brand')?.toString();
    return ma == mb && ba == bb;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        body: Stack(
          children: [
            Padding(
<<<<<<< HEAD
<<<<<<< HEAD
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
=======
              padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
>>>>>>> 10c9b5c (new frkdfm)
=======
              padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
<<<<<<< HEAD
<<<<<<< HEAD
=======
                    // Título
>>>>>>> 10c9b5c (new frkdfm)
=======
                    // Título
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
<<<<<<< HEAD
<<<<<<< HEAD
                          alignment: AlignmentDirectional(0.0, 0.0),
=======
                          alignment: const AlignmentDirectional(0, 0),
>>>>>>> 10c9b5c (new frkdfm)
=======
                          alignment: const AlignmentDirectional(0, 0),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                          child: Text(
                            FFLocalizations.of(context).getText(
                              '48il5165' /* Payment for this ride */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  color: FlutterFlowTheme.of(context).alternate,
<<<<<<< HEAD
<<<<<<< HEAD
                                  fontSize: 28.0,
=======
                                  fontSize: 28,
>>>>>>> 10c9b5c (new frkdfm)
=======
                                  fontSize: 28,
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      ],
                    ),
<<<<<<< HEAD
<<<<<<< HEAD
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryText,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1.0,
                              color: Color(0x33000000),
                              offset: Offset(
                                0.0,
                                1.0,
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 8.0),
=======

                    // Caixinha de informações do passe (mantive como estava)
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryText,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 1,
                              color: Color(0x33000000),
                              offset: Offset(0, 1),
                            )
                          ],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
>>>>>>> 10c9b5c (new frkdfm)
=======

                    // Caixinha de informações do passe (mantive como estava)
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryText,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 1,
                              color: Color(0x33000000),
                              offset: Offset(0, 1),
                            )
                          ],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
<<<<<<< HEAD
<<<<<<< HEAD
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 0.0, 12.0, 0.0),
=======
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 0, 12, 0),
>>>>>>> 10c9b5c (new frkdfm)
=======
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 0, 12, 0),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          FFLocalizations.of(context).getText(
                                            'p8t3hsvx' /* Tourist pass: Week ($8) */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
<<<<<<< HEAD
<<<<<<< HEAD
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 10.0,
                                                letterSpacing: 0.0,
                                                fontWeight:
=======
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 10,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          FFLocalizations.of(context).getText(
                                            'p6e8yole' /* Valid: Aug 20 */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
<<<<<<< HEAD
<<<<<<< HEAD
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 10.0,
                                                letterSpacing: 0.0,
                                                fontWeight:
=======
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 10,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
<<<<<<< HEAD
<<<<<<< HEAD
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 0.0, 12.0, 0.0),
=======
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 0, 12, 0),
>>>>>>> 10c9b5c (new frkdfm)
=======
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 0, 12, 0),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          FFLocalizations.of(context).getText(
                                            'axid08n7' /* Fuel fee: 3 per ride */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
<<<<<<< HEAD
<<<<<<< HEAD
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                                fontWeight:
=======
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                fontSize: 12,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          FFLocalizations.of(context).getText(
                                            'l5w20jdh' /* Charged on Visa *****4343 */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
<<<<<<< HEAD
<<<<<<< HEAD
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 10.0,
                                                letterSpacing: 0.0,
                                                fontWeight:
=======
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 10,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
<<<<<<< HEAD
<<<<<<< HEAD
                            ].divide(SizedBox(height: 6.0)),
=======
                            ].divide(const SizedBox(height: 6)),
>>>>>>> 10c9b5c (new frkdfm)
=======
                            ].divide(const SizedBox(height: 6)),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                          ),
                        ),
                      ),
                    ),
<<<<<<< HEAD
<<<<<<< HEAD
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        decoration: BoxDecoration(
                          color: Color(0xA5414141),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1.0,
                              color: Color(0x33000000),
                              offset: Offset(
                                0.0,
                                1.0,
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 8.0),
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be

                    // Opções de pagamento (mantive)
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        decoration: const BoxDecoration(
                          color: Color(0xA5414141),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1,
                              color: Color(0x33000000),
                              offset: Offset(0, 1),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 0, 12, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: custom_widgets.Radiobuttompayment(
                                        width: 30,
                                        height: 30,
                                        selected: true,
                                      ),
                                    ),
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'lpcumiyr' /* Pay in app (Recommendad) */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ].divide(const SizedBox(width: 10)),
                                ),
                              ),
                            ].divide(const SizedBox(height: 6)),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        decoration: const BoxDecoration(
                          color: Color(0xA5414141),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1,
                              color: Color(0x33000000),
                              offset: Offset(0, 1),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
<<<<<<< HEAD
<<<<<<< HEAD
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 0.0, 12.0, 0.0),
=======
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 0, 12, 0),
>>>>>>> 10c9b5c (new frkdfm)
=======
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 0, 12, 0),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
<<<<<<< HEAD
<<<<<<< HEAD
                                    Container(
                                      width: 30.0,
                                      height: 30.0,
                                      child: custom_widgets.Radiobuttompayment(
                                        width: 30.0,
                                        height: 30.0,
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: custom_widgets.Radiobuttompayment(
                                        width: 30,
                                        height: 30,
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                        selected: false,
                                      ),
                                    ),
                                    Text(
                                      FFLocalizations.of(context).getText(
<<<<<<< HEAD
<<<<<<< HEAD
                                        'lpcumiyr' /* Pay in app (Recommendad) */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: 10.0)),
                                ),
                              ),
                            ].divide(SizedBox(height: 6.0)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        decoration: BoxDecoration(
                          color: Color(0xA5414141),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1.0,
                              color: Color(0x33000000),
                              offset: Offset(
                                0.0,
                                1.0,
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 0.0, 12.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 30.0,
                                      height: 30.0,
                                      child: custom_widgets.Radiobuttompayment(
                                        width: 30.0,
                                        height: 30.0,
                                        selected: false,
                                      ),
                                    ),
                                    Text(
                                      FFLocalizations.of(context).getText(
=======
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                        'ow1d3q6k' /* Pay driver directly */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            letterSpacing: 0.0,
<<<<<<< HEAD
<<<<<<< HEAD
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: 10.0)),
                                ),
                              ),
                            ].divide(SizedBox(height: 6.0)),
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                          ),
                                    ),
                                  ].divide(const SizedBox(width: 10)),
                                ),
                              ),
                            ].divide(const SizedBox(height: 6)),
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                          ),
                        ),
                      ),
                    ),
<<<<<<< HEAD
<<<<<<< HEAD
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryText,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1.0,
                              color: Color(0x33000000),
                              offset: Offset(
                                0.0,
                                1.0,
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 8.0, 8.0, 8.0),
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be

                    // Caixa com observação + CAMPO TEXTO
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryText,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 1,
                              color: Color(0x33000000),
                              offset: Offset(0, 1),
                            )
                          ],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
<<<<<<< HEAD
<<<<<<< HEAD
                              Text(
                                valueOrDefault<String>(
                                  FFAppState()
                                      .creditCardSalves
                                      .firstOrNull
                                      ?.toString(),
                                  'TESTING CARDFILE',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 10.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                              Container(
                                width: 307.0,
                                height: 32.0,
                                decoration: BoxDecoration(
                                  color: Color(0x87414141),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ),
                                ),
                                child: Container(
                                  width: 200.0,
=======
                              // Removido texto de debug do primeiro cartão salvo
                              Container(
                                width: 307,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0x87414141),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: SizedBox(
                                  width: 200,
>>>>>>> 10c9b5c (new frkdfm)
=======
                              // Removido texto de debug do primeiro cartão salvo
                              Container(
                                width: 307,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0x87414141),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: SizedBox(
                                  width: 200,
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                  child: TextFormField(
                                    controller: _model.textController,
                                    focusNode: _model.textFieldFocusNode,
                                    autofocus: false,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
<<<<<<< HEAD
<<<<<<< HEAD
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
=======
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                          ),
                                      hintText:
                                          FFLocalizations.of(context).getText(
                                        'vse9hbic' /* e.g., meet at Hotel lobby */,
                                      ),
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
<<<<<<< HEAD
<<<<<<< HEAD
                                            fontSize: 10.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(6.0),
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                            fontSize: 10,
                                            letterSpacing: 0.0,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
<<<<<<< HEAD
<<<<<<< HEAD
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(6.0),
=======
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
>>>>>>> 10c9b5c (new frkdfm)
=======
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
<<<<<<< HEAD
<<<<<<< HEAD
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      filled: true,
                                      fillColor: Color(0xA5414141),
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xA5414141),
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
<<<<<<< HEAD
<<<<<<< HEAD
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
=======
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                        ),
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    enableInteractiveSelection: true,
                                    validator: _model.textControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
<<<<<<< HEAD
<<<<<<< HEAD
                            ].divide(SizedBox(height: 6.0)),
=======
                            ].divide(const SizedBox(height: 6)),
>>>>>>> 10c9b5c (new frkdfm)
=======
                            ].divide(const SizedBox(height: 6)),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                          ),
                        ),
                      ),
                    ),
<<<<<<< HEAD
<<<<<<< HEAD
                    Builder(
                      builder: (context) {
                        final creditCards = FFAppState()
                            .creditCardSalves
                            .map((e) => getJsonField(
                                  e,
                                  r'''$.numberMasked''',
                                ))
                            .toList();
                        if (creditCards.isEmpty) {
                          return AddPaymentMethodWidget();
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be

                    // Lista de cartões salvos
                    Builder(
                      builder: (context) {
                        // Filtra e deduplica (token preferido; senão usa brand+masked ou last4)
                        final raw = FFAppState().creditCardSalves.toList();
                        final cards = <dynamic>[];
                        final seen = <String>{};
                        for (final c in raw) {
                          try {
                            final token = (getJsonField(c, r'$.token')?.toString() ?? '').trim();
                            final brand = (getJsonField(c, r'$.brand')?.toString() ?? '').trim();
                            final masked = (getJsonField(c, r'$.numberMasked')?.toString() ?? '').trim();
                            final last4 = (getJsonField(c, r'$.last4')?.toString() ?? '').trim();
                            final key = token.isNotEmpty
                                ? 't:$token'
                                : 'm:${brand}_$masked${last4.isNotEmpty ? '_$last4' : ''}';
                            if (key.trim().isEmpty) continue;
                            if (seen.add(key)) cards.add(c);
                          } catch (_) {}
                        }

                        if (cards.isEmpty) {
                          return const AddPaymentMethodWidget();
                        }

                        // Auto-select default/first card if none selected yet
                        if (_model.selectCard == null) {
                          final def = FFAppState().defaultCard;
                          if (def != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) setState(() => _model.selectCard = def);
                            });
                          } else if (cards.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) setState(() => _model.selectCard = cards.first);
                            });
                          }
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.max,
<<<<<<< HEAD
<<<<<<< HEAD
                          children: List.generate(creditCards.length,
                              (creditCardsIndex) {
                            final creditCardsItem =
                                creditCards[creditCardsIndex];
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                          children: List.generate(cards.length, (index) {
                            final card = cards[index];
                            final selected = _sameCard(_model.selectCard, card);
                            final isDefault =
                                _sameCard(FFAppState().defaultCard, card);
                            final brand = _brandOf(card);
                            final masked = _maskedOf(card);

<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                            return InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
<<<<<<< HEAD
<<<<<<< HEAD
                              onTap: () async {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  enableDrag: false,
                                  context: context,
                                  builder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: CardPaymentWidget(
                                          value: 30.00,
                                          passe: '',
                                        ),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                              onTap: () {
                                setState(() {
                                  _model.selectCard = card;
                                });
                              },
                              onLongPress: () {
                                // Define como default no long-press
                                FFAppState().defaultCard = card;
                                setState(() {});
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 0.7,
                                decoration: BoxDecoration(
<<<<<<< HEAD
<<<<<<< HEAD
                                  color: getJsonField(
                                            _model.selectCard,
                                            r'''$.numberMasked''',
                                          ) ==
                                          getJsonField(
                                            creditCardsItem,
                                            r'''$.numberMasked''',
                                          )
                                      ? FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                      : FlutterFlowTheme.of(context).primary,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 1.0,
                                      color: Color(0x33000000),
                                      offset: Offset(
                                        0.0,
                                        1.0,
                                      ),
                                    )
                                  ],
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0),
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 15.0, 0.0, 15.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 0.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                if (getJsonField(
                                                      creditCardsItem,
                                                      r'''$.numberMasked''',
                                                    ) ==
                                                    getJsonField(
                                                      FFAppState().defaultCard,
                                                      r'''$.numberMasked''',
                                                    ))
                                                  Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      'q0r0r5ua' /* This Default  */,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                          fontSize: 10.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                Text(
                                                  '${getJsonField(
                                                    creditCardsItem,
                                                    r'''$.brand''',
                                                  ).toString()} ${functions.esconderCreditCard(getJsonField(
                                                    creditCardsItem,
                                                    r'''$.numberMasked''',
                                                  ).toString())}',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        fontSize: 10.0,
                                                        letterSpacing: 0.0,
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                  color: selected
                                      ? FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                      : FlutterFlowTheme.of(context).primary,
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 1,
                                      color: Color(0x33000000),
                                      offset: Offset(0, 1),
                                    )
                                  ],
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 15, 0, 15),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(12, 0, 0, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              '${brand.toUpperCase()}  $masked',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    fontSize: 12,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                            if (isDefault) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                FFLocalizations.of(context).getText(
                                                    'q0r0r5ua' /* This Default  */),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
<<<<<<< HEAD
<<<<<<< HEAD
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 6.0)),
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      fontSize: 10,
                                                      letterSpacing: 0.0,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                  ),
                                ),
                              ),
                            );
<<<<<<< HEAD
<<<<<<< HEAD
                          }).divide(SizedBox(height: 8.0)),
                        );
                      },
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(18.0, 0.0, 18.0, 0.0),
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                          }).divide(const SizedBox(height: 8)),
                        );
                      },
                    ),

                    // Tips (mantive igual)
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
<<<<<<< HEAD
<<<<<<< HEAD
                            padding: EdgeInsetsDirectional.fromSTEB(
                                5.0, 0.0, 0.0, 0.0),
=======
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                5, 0, 0, 0),
>>>>>>> 10c9b5c (new frkdfm)
=======
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                5, 0, 0, 0),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                            child: Text(
                              FFLocalizations.of(context).getText(
                                'nxuhtebu' /* Optinal tip (at pickup) */,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 10,
<<<<<<< HEAD
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
<<<<<<< HEAD
                                width: 72.0,
=======
                                width: 72,
>>>>>>> 10c9b5c (new frkdfm)
                                height: 20.7,
                                decoration: BoxDecoration(
                                  color: _model.selectTip == 1
                                      ? FlutterFlowTheme.of(context).secondary
                                      : FlutterFlowTheme.of(context).tertiary,
<<<<<<< HEAD
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
=======
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: const AlignmentDirectional(0, 0),
>>>>>>> 10c9b5c (new frkdfm)
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    'gd3kce3k' /* $1 */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: _model.selectTip == 1
                                            ? FlutterFlowTheme.of(context)
                                                .primaryText
                                            : FlutterFlowTheme.of(context)
                                                .alternate,
<<<<<<< HEAD
                                        fontSize: 10.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
=======
                                        fontSize: 10,
                                        letterSpacing: 0.0,
>>>>>>> 10c9b5c (new frkdfm)
                                      ),
                                ),
                              ),
                              Container(
<<<<<<< HEAD
                                width: 72.0,
=======
                                width: 72,
>>>>>>> 10c9b5c (new frkdfm)
                                height: 20.7,
                                decoration: BoxDecoration(
                                  color: _model.selectTip == 2
                                      ? FlutterFlowTheme.of(context).secondary
                                      : FlutterFlowTheme.of(context).tertiary,
<<<<<<< HEAD
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
=======
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: const AlignmentDirectional(0, 0),
>>>>>>> 10c9b5c (new frkdfm)
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    '994bahd0' /* $2 */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: _model.selectTip == 2
                                            ? FlutterFlowTheme.of(context)
                                                .primaryBackground
                                            : FlutterFlowTheme.of(context)
                                                .alternate,
<<<<<<< HEAD
                                        fontSize: 10.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
=======
                                        fontSize: 10,
                                        letterSpacing: 0.0,
>>>>>>> 10c9b5c (new frkdfm)
                                      ),
                                ),
                              ),
                              Container(
<<<<<<< HEAD
                                width: 72.0,
=======
                                width: 72,
>>>>>>> 10c9b5c (new frkdfm)
                                height: 20.7,
                                decoration: BoxDecoration(
                                  color: _model.selectTip == 3
                                      ? FlutterFlowTheme.of(context).secondary
                                      : FlutterFlowTheme.of(context).tertiary,
<<<<<<< HEAD
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
=======
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: const AlignmentDirectional(0, 0),
>>>>>>> 10c9b5c (new frkdfm)
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    'esljy9on' /* $3 */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: _model.selectTip == 3
                                            ? FlutterFlowTheme.of(context)
                                                .primaryText
                                            : FlutterFlowTheme.of(context)
                                                .alternate,
<<<<<<< HEAD
                                        fontSize: 10.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
=======
                                        fontSize: 10,
                                        letterSpacing: 0.0,
>>>>>>> 10c9b5c (new frkdfm)
                                      ),
                                ),
                              ),
                              Container(
<<<<<<< HEAD
                                width: 72.0,
=======
                                width: 72,
>>>>>>> 10c9b5c (new frkdfm)
                                height: 20.7,
                                decoration: BoxDecoration(
                                  color: _model.selectTip == null
                                      ? FlutterFlowTheme.of(context).secondary
                                      : FlutterFlowTheme.of(context).tertiary,
<<<<<<< HEAD
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
=======
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: const AlignmentDirectional(0, 0),
>>>>>>> 10c9b5c (new frkdfm)
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    'm9wj15bb' /* No tip */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
<<<<<<< HEAD
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        fontSize: 10.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            ].divide(SizedBox(width: 10.0)),
                          ),
                        ].divide(SizedBox(height: 8.0)),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _model.processPayment =
                                    await actions.processCardPayload(
                                  context,
                                  _model.selectCard!,
                                  true,
                                  'sandbox_ck9vkcgg_brg8dhjg5tqpw496',
                                  20.0,
                                );
                                if (getJsonField(
                                      _model.processPayment,
                                      r'''$.cardRaw''',
                                    ) !=
                                    null) {
                                  _model.latlngOrigem =
                                      await LatlngToStringCall.call(
                                    latlng: widget.latlngAtual?.toString(),
                                  );

                                  _model.latlngDestino =
                                      await LatlngToStringCall.call(
                                    latlng: widget.latlngWhereTo?.toString(),
                                  );

                                  var rideOrdersRecordReference =
                                      RideOrdersRecord.collection.doc();
                                  await rideOrdersRecordReference
                                      .set(createRideOrdersRecordData(
                                    user: currentUserReference,
                                    latlng: widget.latlngWhereTo,
                                    dia: getCurrentTimestamp,
                                    option: widget.estilo,
                                    latlngAtual: widget.latlngAtual,
                                    nomeOrigem: LatlngToStringCall.shrotName(
                                      (_model.latlngOrigem?.jsonBody ?? ''),
                                    )?.firstOrNull,
                                    nomeDestino: LatlngToStringCall.shrotName(
                                      (_model.latlngDestino?.jsonBody ?? ''),
                                    )?.firstOrNull,
                                    rideValue:
                                        random_data.randomDouble(5.0, 100.0),
                                  ));
                                  _model.order =
                                      RideOrdersRecord.getDocumentFromData(
                                          createRideOrdersRecordData(
                                            user: currentUserReference,
                                            latlng: widget.latlngWhereTo,
                                            dia: getCurrentTimestamp,
                                            option: widget.estilo,
                                            latlngAtual: widget.latlngAtual,
                                            nomeOrigem:
                                                LatlngToStringCall.shrotName(
                                              (_model.latlngOrigem?.jsonBody ??
                                                  ''),
                                            )?.firstOrNull,
                                            nomeDestino:
                                                LatlngToStringCall.shrotName(
                                              (_model.latlngDestino?.jsonBody ??
                                                  ''),
                                            )?.firstOrNull,
                                            rideValue: random_data.randomDouble(
                                                5.0, 100.0),
                                          ),
                                          rideOrdersRecordReference);

                                  context.goNamed(
                                    FindingDrive8Widget.routeName,
                                    queryParameters: {
                                      'rideOrder': serializeParam(
                                        _model.order?.reference,
                                        ParamType.DocumentReference,
                                      ),
                                    }.withoutNulls,
                                  );
                                } else {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: Padding(
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: ErronopagamentoWidget(),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                }

                                safeSetState(() {});
                              },
                              child: Container(
                                width: 318.0,
                                height: 38.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(18.0),
                                    bottomRight: Radius.circular(18.0),
                                    topLeft: Radius.circular(18.0),
                                    topRight: Radius.circular(18.0),
                                  ),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    '6r67s6mb' /* Confirm & Pay */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
=======
>>>>>>> 10c9b5c (new frkdfm)
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        fontSize: 10,
                                        letterSpacing: 0.0,
<<<<<<< HEAD
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
=======
                                      ),
                                ),
                              ),
                            ].divide(const SizedBox(width: 10)),
                          ),
                        ].divide(const SizedBox(height: 8)),
                      ),
                    ),

                    // Botão Confirm & Pay
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: _isPaying
                                  ? null
                                  : () async {
                                // Evita crash por null!
                                if (_model.selectCard == null) {
                                  showSnackbar(context,
                                      'Selecione um cartão salvo primeiro.');
                                  return;
                                }
                                
                                // Require signed-in user for onCall functions
                                if (currentUserUid.isEmpty) {
                                  showSnackbar(context, 'You must be signed in to pay.');
                                  return;
                                }
                                
                                try {
                                  setState(() => _isPaying = true);
                                  // Normalize payload to ensure token is present
                                  final sel = _model.selectCard!;
                                  final token = (getJsonField(sel, r'$.token')?.toString() ?? '').trim();
                                  if (token.isEmpty) {
                                    showSnackbar(context, 'This saved card cannot be charged. Please add it again to vault.');
                                    setState(() => _isPaying = false);
                                    return;
                                  }
                                  final payload = token.isNotEmpty
                                      ? ({'token': token} as dynamic)
                                      : sel;

                                  _model.processPayment = await actions.processCardPayload(
                                    context,
                                    payload,
                                    true,
                                    'sandbox_ck9vkcgg_brg8dhjg5tqpw496',
                                    20.0,
                                  );

                                  final ok = getJsonField(
                                        _model.processPayment,
                                        r'$.ok',
                                      ) ==
                                      true;
                                  final txId = getJsonField(
                                        _model.processPayment,
                                        r'$.transactionId',
                                      )
                                          ?.toString() ??
                                      '';

                                  if (ok && txId.isNotEmpty) {
                                    _model.latlngOrigem =
                                        await LatlngToStringCall.call(
                                      latlng: widget.latlngAtual?.toString(),
                                    );

                                    _model.latlngDestino =
                                        await LatlngToStringCall.call(
                                      latlng: widget.latlngWhereTo?.toString(),
                                    );

                                    var rideOrdersRecordReference =
                                        RideOrdersRecord.collection.doc();
                                    await rideOrdersRecordReference
                                        .set(createRideOrdersRecordData(
                                      user: currentUserReference,
                                      latlng: widget.latlngWhereTo,
                                      dia: getCurrentTimestamp,
                                      option: widget.estilo,
                                      latlngAtual: widget.latlngAtual,
                                      nomeOrigem: LatlngToStringCall.shrotName(
                                        (_model.latlngOrigem?.jsonBody ?? ''),
                                      )?.firstOrNull,
                                      nomeDestino: LatlngToStringCall.shrotName(
                                        (_model.latlngDestino?.jsonBody ?? ''),
                                      )?.firstOrNull,
                                      rideValue:
                                          random_data.randomDouble(5, 100),
                                    ));
                                    _model.order =
                                        RideOrdersRecord.getDocumentFromData(
                                            createRideOrdersRecordData(
                                              user: currentUserReference,
                                              latlng: widget.latlngWhereTo,
                                              dia: getCurrentTimestamp,
                                              option: widget.estilo,
                                              latlngAtual: widget.latlngAtual,
                                              nomeOrigem:
                                                  LatlngToStringCall.shrotName(
                                                (_model.latlngOrigem
                                                        ?.jsonBody ??
                                                    ''),
                                              )?.firstOrNull,
                                              nomeDestino:
                                                  LatlngToStringCall.shrotName(
                                                (_model.latlngDestino
                                                        ?.jsonBody ??
                                                    ''),
                                              )?.firstOrNull,
                                              rideValue: random_data
                                                  .randomDouble(5, 100),
                                            ),
                                            rideOrdersRecordReference);

                                    if (!mounted) return;
                                    context.goNamed(
                                      FindingDrive8Widget.routeName,
                                      queryParameters: {
                                        'rideOrder': serializeParam(
                                          _model.order?.reference,
                                          ParamType.DocumentReference,
                                        ),
                                      }.withoutNulls,
                                    );
                                  } else {
                                    // Show error details if any
                                    final errMsg = getJsonField(
                                          _model.processPayment,
                                          r'$.error',
                                        )
                                        ?.toString() ?? '';
                                    if (errMsg.isNotEmpty) {
                                      showSnackbar(context, errMsg);
                                    }
                                    if (!mounted) return;
                                    // Falhou o pagamento -> mostra bottom sheet de erro
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return const ErronopagamentoWidget();
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  }
                                } catch (e) {
                                  // Qualquer exceção no Android não fecha o app, cai aqui
                                  if (!mounted) return;
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return const ErronopagamentoWidget();
                                    },
                                  ).then((value) => safeSetState(() {}));
                                } finally {
                                  setState(() => _isPaying = false);
                                }
                              },
                              child: Container(
                                width: 318,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18),
                                  ),
                                ),
                                alignment: const AlignmentDirectional(0, 0),
                                child: _isPaying
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Processing... ',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .primary,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        FFLocalizations.of(context).getText(
                                          '6r67s6mb' /* Confirm & Pay */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                              ),
>>>>>>> 10c9b5c (new frkdfm)
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              FFLocalizations.of(context).getText(
                                'n1vblhdo' /* You´ll be charged after ride */,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
<<<<<<< HEAD
                                    fontSize: 10.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
=======
                                    fontSize: 10,
                                    letterSpacing: 0.0,
>>>>>>> 10c9b5c (new frkdfm)
=======
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 72,
                                height: 20.7,
                                decoration: BoxDecoration(
                                  color: _model.selectTip == 1
                                      ? FlutterFlowTheme.of(context).secondary
                                      : FlutterFlowTheme.of(context).tertiary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: const AlignmentDirectional(0, 0),
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    'gd3kce3k' /* $1 */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: _model.selectTip == 1
                                            ? FlutterFlowTheme.of(context)
                                                .primaryText
                                            : FlutterFlowTheme.of(context)
                                                .alternate,
                                        fontSize: 10,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              Container(
                                width: 72,
                                height: 20.7,
                                decoration: BoxDecoration(
                                  color: _model.selectTip == 2
                                      ? FlutterFlowTheme.of(context).secondary
                                      : FlutterFlowTheme.of(context).tertiary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: const AlignmentDirectional(0, 0),
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    '994bahd0' /* $2 */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: _model.selectTip == 2
                                            ? FlutterFlowTheme.of(context)
                                                .primaryBackground
                                            : FlutterFlowTheme.of(context)
                                                .alternate,
                                        fontSize: 10,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              Container(
                                width: 72,
                                height: 20.7,
                                decoration: BoxDecoration(
                                  color: _model.selectTip == 3
                                      ? FlutterFlowTheme.of(context).secondary
                                      : FlutterFlowTheme.of(context).tertiary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: const AlignmentDirectional(0, 0),
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    'esljy9on' /* $3 */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: _model.selectTip == 3
                                            ? FlutterFlowTheme.of(context)
                                                .primaryText
                                            : FlutterFlowTheme.of(context)
                                                .alternate,
                                        fontSize: 10,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              Container(
                                width: 72,
                                height: 20.7,
                                decoration: BoxDecoration(
                                  color: _model.selectTip == null
                                      ? FlutterFlowTheme.of(context).secondary
                                      : FlutterFlowTheme.of(context).tertiary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: const AlignmentDirectional(0, 0),
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    'm9wj15bb' /* No tip */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        fontSize: 10,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ].divide(const SizedBox(width: 10)),
                          ),
                        ].divide(const SizedBox(height: 8)),
                      ),
                    ),

                    // Botão Confirm & Pay
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: _isPaying
                                  ? null
                                  : () async {
                                // Evita crash por null!
                                if (_model.selectCard == null) {
                                  showSnackbar(context,
                                      'Selecione um cartão salvo primeiro.');
                                  return;
                                }
                                
                                // Require signed-in user for onCall functions
                                if (currentUserUid.isEmpty) {
                                  showSnackbar(context, 'You must be signed in to pay.');
                                  return;
                                }
                                
                                try {
                                  setState(() => _isPaying = true);
                                  // Normalize payload to ensure token is present
                                  final sel = _model.selectCard!;
                                  final token = (getJsonField(sel, r'$.token')?.toString() ?? '').trim();
                                  if (token.isEmpty) {
                                    showSnackbar(context, 'This saved card cannot be charged. Please add it again to vault.');
                                    setState(() => _isPaying = false);
                                    return;
                                  }
                                  final payload = token.isNotEmpty
                                      ? ({'token': token} as dynamic)
                                      : sel;

                                  _model.processPayment = await actions.processCardPayload(
                                    context,
                                    payload,
                                    true,
                                    'sandbox_ck9vkcgg_brg8dhjg5tqpw496',
                                    20.0,
                                  );

                                  final ok = getJsonField(
                                        _model.processPayment,
                                        r'$.ok',
                                      ) ==
                                      true;
                                  final txId = getJsonField(
                                        _model.processPayment,
                                        r'$.transactionId',
                                      )
                                          ?.toString() ??
                                      '';

                                  if (ok && txId.isNotEmpty) {
                                    _model.latlngOrigem =
                                        await LatlngToStringCall.call(
                                      latlng: widget.latlngAtual?.toString(),
                                    );

                                    _model.latlngDestino =
                                        await LatlngToStringCall.call(
                                      latlng: widget.latlngWhereTo?.toString(),
                                    );

                                    var rideOrdersRecordReference =
                                        RideOrdersRecord.collection.doc();
                                    await rideOrdersRecordReference
                                        .set(createRideOrdersRecordData(
                                      user: currentUserReference,
                                      latlng: widget.latlngWhereTo,
                                      dia: getCurrentTimestamp,
                                      option: widget.estilo,
                                      latlngAtual: widget.latlngAtual,
                                      nomeOrigem: LatlngToStringCall.shrotName(
                                        (_model.latlngOrigem?.jsonBody ?? ''),
                                      )?.firstOrNull,
                                      nomeDestino: LatlngToStringCall.shrotName(
                                        (_model.latlngDestino?.jsonBody ?? ''),
                                      )?.firstOrNull,
                                      rideValue:
                                          random_data.randomDouble(5, 100),
                                    ));
                                    _model.order =
                                        RideOrdersRecord.getDocumentFromData(
                                            createRideOrdersRecordData(
                                              user: currentUserReference,
                                              latlng: widget.latlngWhereTo,
                                              dia: getCurrentTimestamp,
                                              option: widget.estilo,
                                              latlngAtual: widget.latlngAtual,
                                              nomeOrigem:
                                                  LatlngToStringCall.shrotName(
                                                (_model.latlngOrigem
                                                        ?.jsonBody ??
                                                    ''),
                                              )?.firstOrNull,
                                              nomeDestino:
                                                  LatlngToStringCall.shrotName(
                                                (_model.latlngDestino
                                                        ?.jsonBody ??
                                                    ''),
                                              )?.firstOrNull,
                                              rideValue: random_data
                                                  .randomDouble(5, 100),
                                            ),
                                            rideOrdersRecordReference);

                                    if (!mounted) return;
                                    context.goNamed(
                                      FindingDrive8Widget.routeName,
                                      queryParameters: {
                                        'rideOrder': serializeParam(
                                          _model.order?.reference,
                                          ParamType.DocumentReference,
                                        ),
                                      }.withoutNulls,
                                    );
                                  } else {
                                    // Show error details if any
                                    final errMsg = getJsonField(
                                          _model.processPayment,
                                          r'$.error',
                                        )
                                        ?.toString() ?? '';
                                    if (errMsg.isNotEmpty) {
                                      showSnackbar(context, errMsg);
                                    }
                                    if (!mounted) return;
                                    // Falhou o pagamento -> mostra bottom sheet de erro
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return const ErronopagamentoWidget();
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  }
                                } catch (e) {
                                  // Qualquer exceção no Android não fecha o app, cai aqui
                                  if (!mounted) return;
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return const ErronopagamentoWidget();
                                    },
                                  ).then((value) => safeSetState(() {}));
                                } finally {
                                  setState(() => _isPaying = false);
                                }
                              },
                              child: Container(
                                width: 318,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18),
                                  ),
                                ),
                                alignment: const AlignmentDirectional(0, 0),
                                child: _isPaying
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Processing... ',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .primary,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        FFLocalizations.of(context).getText(
                                          '6r67s6mb' /* Confirm & Pay */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              FFLocalizations.of(context).getText(
                                'n1vblhdo' /* You´ll be charged after ride */,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 10,
                                    letterSpacing: 0.0,
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                                  ),
                            ),
                          ],
                        ),
<<<<<<< HEAD
<<<<<<< HEAD
                      ].divide(SizedBox(height: 6.0)),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 0.0, 0.0),
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                      ].divide(const SizedBox(height: 6)),
                    ),

                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(14, 0, 0, 0),
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText(
                              'zdfdyn5j' /* After this step -> Matching */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 10,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ],
                      ),
                    ),
<<<<<<< HEAD
<<<<<<< HEAD
                  ].divide(SizedBox(height: 26.0)),
=======
                  ].divide(const SizedBox(height: 26)),
>>>>>>> 10c9b5c (new frkdfm)
=======
                  ].divide(const SizedBox(height: 26)),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
