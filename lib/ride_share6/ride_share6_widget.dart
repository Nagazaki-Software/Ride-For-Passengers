import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/share_q_r_code_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;

import 'dart:async';                       // NOVO
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';    // NOVO (Clipboard)
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'ride_share6_model.dart';
export 'ride_share6_model.dart';

class RideShare6Widget extends StatefulWidget {
  const RideShare6Widget({super.key});

  static String routeName = 'RideShare6';
  static String routePath = '/rideShare6';

  @override
  State<RideShare6Widget> createState() => _RideShare6WidgetState();
}

class _RideShare6WidgetState extends State<RideShare6Widget> {
  late RideShare6Model _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // --- Estado adicional ---
  StreamSubscription<DocumentSnapshot>? _sessionSub;
  List<DocumentReference> _participants = [];
  double _totalFare = 19.50; // fallback local; será sobrescrito pelo Firestore
  Map<String, double> _shares = {}; // uid -> valor $
  String _splitType = 'equal';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RideShare6Model());

    // Tenta juntar pela URL (ex.: ride://.../rideShare6?join=<rideId>)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _maybeJoinByLink();
      if (_model.session != null) {
        _subscribeToSession(_model.session!);
      }
    });
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _model.dispose();
    super.dispose();
  }

  // ===================== FUNÇÕES CORE =====================

  /// Cria sessão (doc em rideOrders) se ainda não existir.
  Future<void> _createSessionIfNeeded() async {
    if (_model.session != null) return;

    final docRef = RideOrdersRecord.collection.doc();
    final now = DateTime.now();
    await docRef.set({
      ...createRideOrdersRecordData(
        rideShare: true,
      ),
      'hostRef': currentUserReference,
      'participantes': [currentUserReference],
      'totalFare': _totalFare,   // se você calcula em outro lugar, escreva lá
      'splitType': 'equal',
      'customShares': <String, num>{},
      'isOpen': true,
      'createdAt': now,
      'updatedAt': now,
    });

    _model.session = docRef;
    _subscribeToSession(docRef);
  }

  /// Se veio com ?join=<rideId>, entra na sessão (arrayUnion + listener).
  Future<void> _maybeJoinByLink() async {
    final uri = GoRouterState.of(context).uri;
    final join = uri.queryParameters['join'];
    if (join == null || join.isEmpty) return;

    final docRef = RideOrdersRecord.collection.doc(join);
    final snap = await docRef.get();
    if (!snap.exists) return;

    _model.session = docRef;

    // Adiciona participante (se ainda não está)
    await docRef.update({
      'participantes': FieldValue.arrayUnion([currentUserReference]),
      'updatedAt': DateTime.now(),
    });

    _subscribeToSession(docRef);
  }

  /// Observa o doc em tempo real e recalcula shares/participantes.
  void _subscribeToSession(DocumentReference sessionRef) {
    _sessionSub?.cancel();
    _sessionSub = sessionRef.snapshots().listen((doc) async {
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>;

      final List<dynamic> refsDyn = (data['participantes'] ?? []) as List<dynamic>;
      _participants = refsDyn.whereType<DocumentReference>().toList();

      _totalFare = (data['totalFare'] is num) ? (data['totalFare'] as num).toDouble() : _totalFare;
      _splitType = (data['splitType'] as String?) ?? 'equal';
      final Map<String, dynamic> customShares =
          (data['customShares'] as Map<String, dynamic>?) ?? {};

      _recalculateShares(
        splitType: _splitType,
        customShares: customShares.map((k, v) => MapEntry(k, (v as num).toDouble())),
      );

      if (mounted) setState(() {});
    });
  }

  /// Divide valores conforme splitType (equal ou custom).
  void _recalculateShares({
    required String splitType,
    required Map<String, double> customShares,
  }) {
    _shares = {};
    if (_participants.isEmpty) return;

    if (splitType == 'equal') {
      final each = (_totalFare / _participants.length);
      for (final ref in _participants) {
        _shares[ref.id] = double.parse(each.toStringAsFixed(2));
      }
    } else {
      // 'custom' — assume que customShares soma ~100 (%). Fazemos uma normalização defensiva.
      final sum = customShares.values.fold<double>(0, (a, b) => a + b);
      final safeSum = sum == 0 ? 100.0 : sum;
      for (final ref in _participants) {
        final pct = customShares[ref.id] ?? 0.0;
        _shares[ref.id] = double.parse(((_totalFare * (pct / safeSum))).toStringAsFixed(2));
      }
    }
  }

  /// Gera o link de convite com ?join=<rideId>
  String _inviteLink() {
    final basePath = GoRouterState.of(context).uri.path; // /rideShare6
    final id = _model.session!.id;
    return 'ride://ride.com$basePath?join=$id';
  }

  /// Copia link de convite
  Future<void> _copyInviteLink() async {
    await _createSessionIfNeeded();
    final link = _inviteLink();
    await Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link copiado: $link')),
    );
  }

  /// Abre o bottom sheet do QR já passando o link certo.
  Future<void> _openQR() async {
    await _createSessionIfNeeded();
    final ref = _model.session!;
    final link = _inviteLink();

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: ShareQRCodeWidget(
              rideDoc: ref,
              linkCurrentPage: link, // <<<<<<<<<<<<<<<<<<<<<<<< link correto
            ),
          ),
        );
      },
    );
  }

  /// Helper: avatar do participante (pega nome no UsersRecord)
  Widget _participantAvatar(DocumentReference userRef) {
    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(userRef),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final initials = (user?.displayName ?? '??')
            .trim()
            .split(RegExp(r'\s+'))
            .map((p) => p.isNotEmpty ? p[0] : '')
            .take(2)
            .join()
            .toUpperCase();
        return Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xA5414141),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).alternate,
                  fontSize: 12,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
        );
      },
    );
  }

  double _myShare() {
    final uid = currentUserReference?.id;
    if (uid == null) return 0;
    return _shares[uid] ?? 0;
  }

  String _totalFareText() => '\$${_totalFare.toStringAsFixed(2)}';
  String _myShareText() => '\$${_myShare().toStringAsFixed(2)}';

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
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
            Align(
              alignment: const AlignmentDirectional(0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 28, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(1, 0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                            child: Text(
                              _model.session != null ? 'Session started' : 'Session not started',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    color: _model.session != null
                                        ? FlutterFlowTheme.of(context).secondary
                                        : FlutterFlowTheme.of(context).error,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(0, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Text(
                                      FFLocalizations.of(context).getText('c2ku81ov' /* Ride Share */),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context).alternate,
                                            fontSize: 22,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          FFLocalizations.of(context).getText('vd485i7w' /* Invite riders to split the far... */),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 10,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // ====== BLOCO: Invite / Link / QR ======
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
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
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 0, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 124,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).alternate,
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  ),
                                  alignment: const AlignmentDirectional(0, 0),
                                  child: Text(
                                    FFLocalizations.of(context).getText('5dxw36ml' /* Invite friends */),
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                          fontSize: 10,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: _openQR,
                                        child: Container(
                                          width: 64,
                                          height: 26,
                                          decoration: const BoxDecoration(
                                            color: Color(0x89414141),
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                          ),
                                          alignment: const AlignmentDirectional(0, 0),
                                          child: Text(
                                            FFLocalizations.of(context).getText('9ensgtkt' /* QR */),
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                  fontSize: 10,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _copyInviteLink,
                                        child: Container(
                                          width: 64,
                                          height: 26,
                                          decoration: const BoxDecoration(
                                            color: Color(0xA8414141),
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                          ),
                                          alignment: const AlignmentDirectional(0, 0),
                                          child: Text(
                                            FFLocalizations.of(context).getText('yglrvlqu' /* Link */),
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                  fontSize: 10,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 30)),
                                  ),
                                ),
                              ],
                            ),
                            // resto do bloco (switch etc.) mantido...
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                                  child: Text(
                                    FFLocalizations.of(context).getText('wme97if5' /* Auto-match nearby riders */),
                                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                          fontSize: 10,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 50,
                                          height: 40,
                                          child: custom_widgets.Switchrideshare(
                                            width: 50,
                                            height: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ====== PARTICIPANTS ======
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 66,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryText,
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FFLocalizations.of(context).getText('ax3wm89h' /* Participants */),
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        fontSize: 10,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                ),
                                Row(
                                  children: _participants.isEmpty
                                      ? [
                                          // placeholders se vazio
                                          Container(width: 34, height: 34, decoration: const BoxDecoration(color: Color(0xA5414141), shape: BoxShape.circle)),
                                          const SizedBox(width: 8),
                                          Container(width: 34, height: 34, decoration: const BoxDecoration(color: Color(0xA5414141), shape: BoxShape.circle)),
                                          const SizedBox(width: 8),
                                          Container(width: 34, height: 34, decoration: const BoxDecoration(color: Color(0xA5414141), shape: BoxShape.circle)),
                                        ]
                                      : _participants.map((ref) => Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: _participantAvatar(ref),
                                          )).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 0, 0),
                          child: Text(
                            FFLocalizations.of(context).getText('niwa8eid' /* Tab to remove • “- -” are open spots */),
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 10,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ====== RIDERS SPLITTING (mantido UI). Você pode ligar botões para mudar splitType) ======
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 124,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryText,
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FFLocalizations.of(context).getText('us6osckg' /* Riders splitting */),
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        fontSize: 10,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 24,
                                      child: custom_widgets.Countcontrolerideshare(
                                        width: 100,
                                        height: 24,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (_model.session == null) await _createSessionIfNeeded();
                                        await _model.session!.update({
                                          'splitType': 'equal',
                                          'updatedAt': DateTime.now(),
                                        });
                                      },
                                      child: Container(
                                        width: 98,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: _splitType == 'equal'
                                              ? FlutterFlowTheme.of(context).alternate
                                              : const Color(0xA5414141),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        alignment: const AlignmentDirectional(0, 0),
                                        child: Text(
                                          FFLocalizations.of(context).getText('wpvhw4cs' /* Equal split */),
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                ),
                                                fontSize: 10,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        // Exemplo simples: seta "custom" e deixa você editar depois
                                        if (_model.session == null) await _createSessionIfNeeded();
                                        await _model.session!.update({
                                          'splitType': 'custom',
                                          'updatedAt': DateTime.now(),
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Custom % ativado. Preencha customShares no doc.')),
                                        );
                                      },
                                      child: Container(
                                        width: 96,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: _splitType == 'custom' ? FlutterFlowTheme.of(context).alternate : const Color(0xA5414141),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        alignment: const AlignmentDirectional(0, 0),
                                        child: Text(
                                          FFLocalizations.of(context).getText('enexrc8j' /* Custom % */),
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                fontSize: 10,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ].divide(const SizedBox(width: 8)),
                                ),
                                Text(
                                  FFLocalizations.of(context).getText('nvqck3af' /* Hold 1 extra seat for your friend */),
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        fontSize: 10,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                ),
                                SizedBox(
                                  width: 50,
                                  height: 30,
                                  child: custom_widgets.Switchriderssplitting(
                                    width: 50,
                                    height: 30,
                                  ),
                                ),
                              ].divide(const SizedBox(height: 5)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ====== Your share / Total ======
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryText,
                            boxShadow: const [
                              BoxShadow(blurRadius: 1, color: Color(0x33000000), offset: Offset(0, 1))
                            ],
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 0, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Text(
                                          FFLocalizations.of(context).getText('qycpjvd7' /* Your share */),
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                fontSize: 10,
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                        ),
                                      ]),
                                      Row(children: [
                                        Text(
                                          FFLocalizations.of(context).getText('a0l4grqi' /* +3 min detour */),
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context).alternate,
                                                fontSize: 14,
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Text(
                                          _myShareText(),
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context).alternate,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                        ),
                                      ]),
                                      Row(children: [
                                        Text(
                                          'of ${_totalFareText()} total',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                fontSize: 10,
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 0, 0),
                          child: Text(
                            FFLocalizations.of(context).getText('s3y7hgro' /* Price updates if route or riders change before pickup. */),
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 10,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ====== Privacy, Confirm, etc. (layout original) ======
                  // ... (mantive seu bloco, sem mudanças funcionais) ...

                  // Seu bloco final mantido:
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 320,
                        height: 38,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).alternate,
                          borderRadius: const BorderRadius.all(Radius.circular(18)),
                        ),
                        alignment: const AlignmentDirectional(0, 0),
                        child: Text(
                          FFLocalizations.of(context).getText('ntglhxb6' /* Confirm Ride Share */),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primary,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                              ),
                        ),
                      ),
                      Container(
                        width: 320,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xA5414141),
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        ),
                        alignment: const AlignmentDirectional(0, 0),
                        child: Text(
                          FFLocalizations.of(context).getText('4br05fcj' /* Skip for now */),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).alternate,
                                fontSize: 10,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 0, 0),
                        child: Text(
                          FFLocalizations.of(context).getText('ltqpaty4' /* Next: Matching - Get picked up... */),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 10,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                              ),
                        ),
                      ),
                    ].divide(const SizedBox(height: 8)),
                  ),
                ].divide(const SizedBox(height: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
