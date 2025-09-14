import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/navbar_widget.dart';
import '/components/select_location_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'home5_model.dart';
export 'home5_model.dart';

class Home5Widget extends StatefulWidget {
  const Home5Widget({super.key});

  static String routeName = 'Home5';
  static String routePath = '/home5';

  @override
  State<Home5Widget> createState() => _Home5WidgetState();
}

class _Home5WidgetState extends State<Home5Widget> with TickerProviderStateMixin {
  late Home5Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  // Controller do mapa (nativo)
  final custom_widgets.PickerMapNativeController _mapCtrl =
      custom_widgets.PickerMapNativeController();

  // Nassau fallback (se vier null ou 0,0)
  static const LatLng _kNassau = LatLng(25.03428, -77.39628);
  bool _isZero(LatLng p) =>
      (p.latitude == 0.0 && p.longitude == 0.0) ||
      (p.latitude.abs() < 0.000001 && p.longitude.abs() < 0.000001);
  LatLng _safe(LatLng? p) => (p == null || _isZero(p)) ? _kNassau : p;

  var hasContainerTriggered1 = false;
  var hasContainerTriggered2 = false;
  var hasContainerTriggered3 = false;
  var hasContainerTriggered4 = false;
  var hasContainerTriggered5 = false;
  var hasContainerTriggered6 = false;
  var hasContainerTriggered7 = false;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Home5Model());

    // 1) tenta obter rápido do cache
    getCurrentUserLocation(defaultLocation: _kNassau, cached: true)
        .then((loc) => safeSetState(() {
              currentUserLocationValue = loc;
              FFAppState().latlngAtual ??= loc;
              FFAppState().update(() {});
            }));

    // 2) confirma depois sem cache
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final loc = await getCurrentUserLocation(defaultLocation: _kNassau, cached: false);
      currentUserLocationValue = loc;
      FFAppState().latlngAtual = loc; // mantém quente no AppState

      // boot de “lugares por perto” e saudação
      await _bootstrapNearbyAndGreeting(loc);
      FFAppState().update(() {});
    });

    animationsMap.addAll({
      'containerOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(curve: Curves.linear, delay: 0.ms, duration: 280.ms, begin: 0.77, end: 2.0),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.ms,
            duration: 360.ms,
            color: const Color(0xAEFB9000),
            begin: 1.0,
            end: 0.0,
          ),
        ],
      ),
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(curve: Curves.easeInOut, delay: 0.ms, duration: 980.ms, begin: const Offset(0, -30), end: const Offset(0, 0)),
          FadeEffect(curve: Curves.easeInOut, delay: 0.ms, duration: 450.ms, begin: 0.0, end: 1.0),
        ],
      ),
      for (final k in [2, 3, 4, 5, 6, 7])
        'containerOnActionTriggerAnimation$k': AnimationInfo(
          trigger: AnimationTrigger.onActionTrigger,
          applyInitialState: false,
          effectsBuilder: () => [
            SaturateEffect(curve: Curves.linear, delay: 0.ms, duration: 280.ms, begin: 0.77, end: 2.0),
            TintEffect(curve: Curves.easeInOut, delay: 90.ms, duration: 360.ms, color: const Color(0xC4BAB5B5), begin: 1.0, end: 0.0),
          ],
        ),
    });
    setupAnimations(
      animationsMap.values.where((anim) => anim.trigger == AnimationTrigger.onActionTrigger || !anim.applyInitialState),
      this,
    );
  }

  Future<void> _bootstrapNearbyAndGreeting(LatLng user) async {
    _model.locationPerto = await actions.googlePlacesNearbyImportant(
      context,
      'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ',
      user,
      3000,
      '',
      'us',
      6,
    );
    _model.fraseInicial = await actions.localGreetingAction();
    FFAppState().fraseInicial = _model.fraseInicial ?? '';
    FFAppState().locationsPorPerto = _model.locationPerto!
        .map((e) => getJsonField(e, r'''$.name'''))
        .map((e) => e.toString())
        .toList()
        .cast<String>();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final LatLng userStart = _safe(FFAppState().latlngAtual ?? currentUserLocationValue);

    if (currentUserLocationValue == null) {
      return Container(
        color: Colors.black, // evita flash branco
        child: Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: SpinKitDoubleBounce(
              color: FlutterFlowTheme.of(context).accent1,
              size: 50,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        body: Stack(
          children: [
            // =========================
            // MAPA NATIVO — ocupa toda a área
            // =========================
            Positioned.fill(
              child: PointerInterceptor(
                intercepting: isWeb,
                child: AuthUserStreamWidget(
                  builder: (context) => StreamBuilder<List<UsersRecord>>(
                    stream: queryUsersRecord(
                      queryBuilder: (usersRecord) =>
                          usersRecord.where('driver', isEqualTo: true).where('driverOnline', isEqualTo: true),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const ColoredBox(
                          color: Colors.black, // placeholder preto
                          child: Center(child: CircularProgressIndicator.adaptive()),
                        );
                      }
                      final pickerMapUsersRecordList = snapshot.data!;
                      return custom_widgets.PickerMapNative(
                        width: double.infinity,
                        height: double.infinity,
                        controller: _mapCtrl,
                        userLocation: userStart,
                        destination: FFAppState().latlangAondeVaiIr, // usa o AppState do seu print
                        mapStyleJson: custom_widgets.kGoogleMapsMonoBlackStyle, // preto/cinza
                        routeColor: const Color(0xFFBDBDBD), // rota cinza
                        routeWidth: 5,

                        // legado (ok manter)
                        driversRefs: pickerMapUsersRecordList.map((e) => e.reference).toList(),
                        refreshMs: 2000,
                        destinationMarkerPngUrl:
                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png',
                        userPhotoUrl: currentUserPhoto,
                        userMarkerSize: 40,
                        userName: currentUserDisplayName,
                        borderRadius: 0,
                        driverIconWidth: 70,
                        driverTaxiIconAsset:
                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
                        driverDriverIconUrl:
                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/bgmclb0d2bsd/ChatGPT_Image_3_de_set._de_2025%2C_19_17_48.png',
                        driverTaxiIconUrl:
                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
                        enableRouteSnake: true,
                        liteModeOnAndroid: false,
                        ultraLowSpecMode: false,
                        brandSafePaddingBottom: 60,
                        showDebugPanel: false, // sem logs
                      );
                    },
                  ),
                ),
              ),
            ),

            // =========================
            // OVERLAYS (topo + bottom card + navbar)
            // =========================
            PointerInterceptor(
              intercepting: isWeb,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // HEADER com gradiente
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xB517181D), Color(0x0717181D)],
                        stops: [0.0, 1.0],
                        begin: AlignmentDirectional(0, -1),
                        end: AlignmentDirectional(0, 1),
                      ),
                    ),
                    child: Align(
                      alignment: const AlignmentDirectional(0, 0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 14, 0, 0),
                        child: Column(
                          children: [
                            // Avatar + menu
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(18, 35, 18, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          boxShadow: const [
                                            BoxShadow(blurRadius: 4, color: Color(0x33000000), offset: Offset(0, 2))
                                          ],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: AuthUserStreamWidget(
                                                builder: (context) => Container(
                                                  width: 200,
                                                  height: 200,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: const BoxDecoration(shape: BoxShape.circle),
                                                  child: Image.network(currentUserPhoto, fit: BoxFit.cover),
                                                ),
                                              ),
                                            ),
                                            if (currentUserPhoto == '')
                                              Align(
                                                alignment: const AlignmentDirectional(0, 0),
                                                child: AuthUserStreamWidget(
                                                  builder: (context) => Text(
                                                    functions.partesDoName(currentUserDisplayName),
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.poppins(
                                                            fontWeight: FlutterFlowTheme.of(context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                            fontStyle: FlutterFlowTheme.of(context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme.of(context).alternate,
                                                          fontSize: 18,
                                                          letterSpacing: 3,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            FFAppState().fraseInicial,
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                  ),
                                                  color: const Color(0xFF696C6F),
                                                  fontSize: 12,
                                                ),
                                          ),
                                          AuthUserStreamWidget(
                                            builder: (context) => Text(
                                              currentUserDisplayName,
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.poppins(
                                                      fontWeight: FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(context).alternate,
                                                    fontSize: 16,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ].divide(const SizedBox(width: 10)),
                                  ),
                                  Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).primaryText,
                                              boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black, offset: Offset(5, 0))],
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF252525),
                                              boxShadow: const [BoxShadow(blurRadius: 6, color: Color(0x48FFFFFF), offset: Offset(-2, -1))],
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            alignment: const AlignmentDirectional(0, 0),
                                            child: Icon(Icons.menu, color: FlutterFlowTheme.of(context).secondaryBackground, size: 18),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ].divide(const SizedBox(width: 12)),
                              ),
                            ),

                            // Where to?
                            Stack(
                              alignment: const AlignmentDirectional(0, -1),
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
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
                                              FocusManager.instance.primaryFocus?.unfocus();
                                            },
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(context),
                                              child: const SelectLocationWidget(escolha: 'textfield'),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width * 0.9,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 0, 8),
                                              child: Text(
                                                FFAppState().locationWhereTo,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(1, -1),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                                    child: Container(
                                      width: 48,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: const AlignmentDirectional(0, 0),
                                      child: Text(
                                        FFLocalizations.of(context).getText('v2jubsa7' /* 3 min */),
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(context).tertiary,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Chips
                            Align(
                              alignment: const AlignmentDirectional(-1, -1),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(17, 6, 12, 0),
                                child: Builder(
                                  builder: (context) {
                                    final pertos = FFAppState().locationsPorPerto.toList();
                                    return SizedBox(
                                      height: 36,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.only(right: 12),
                                        itemCount: pertos.length,
                                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                                        itemBuilder: (context, i) {
                                          final item = pertos[i];
                                          final selected = FFAppState().listPerto == item;

                                          return InkWell(
                                            splashColor: Colors.transparent,
                                            onTap: () async {
                                              if (FFAppState().listPerto == item) {
                                                FFAppState().latlangAondeVaiIr = null;
                                                FFAppState().listPerto = '';
                                                FFAppState().locationWhereTo = 'Where to?';
                                                safeSetState(() {});
                                              } else {
                                                _model.geolocatoraddressonchoose = await actions.geocodeAddress(
                                                  context,
                                                  'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ',
                                                  item,
                                                );
                                                FFAppState().latlangAondeVaiIr = functions.formatStringToLantLng(
                                                  getJsonField(_model.geolocatoraddressonchoose, r'''$.lat''').toString(),
                                                  getJsonField(_model.geolocatoraddressonchoose, r'''$.lng''').toString(),
                                                );
                                                FFAppState().listPerto = item;
                                                FFAppState().locationWhereTo = item;
                                                safeSetState(() {});
                                                HapticFeedback.selectionClick();
                                              }
                                            },
                                            child: AnimatedScale(
                                              scale: selected ? 1.06 : 1.0,
                                              duration: const Duration(milliseconds: 160),
                                              curve: Curves.easeOut,
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 160),
                                                curve: Curves.easeOut,
                                                height: 28,
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: selected
                                                      ? FlutterFlowTheme.of(context).accent1
                                                      : FlutterFlowTheme.of(context).primary,
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: selected
                                                      ? [BoxShadow(blurRadius: 10, offset: const Offset(0, 4), color: Colors.black.withOpacity(0.25))]
                                                      : const [],
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  item,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        font: GoogleFonts.poppins(
                                                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                        ),
                                                        color: const Color(0xFF585858),
                                                        fontSize: 10,
                                                      ),
                                                ),
                                              ),
                                            ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.08),
                                          ).animateOnActionTrigger(
                                            animationsMap['containerOnActionTriggerAnimation1']!,
                                            hasBeenTriggered: hasContainerTriggered1,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 10),

                  // BOTTOM CARD + NAVBAR (inalterados)
                  Align(
                    alignment: const AlignmentDirectional(0, 1),
                    child: Column(
                      children: [
                        if (FFAppState().latlangAondeVaiIr != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 28),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.86,
                              height: 182,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [const Color(0xFF333333), FlutterFlowTheme.of(context).primary],
                                  stops: const [0, 0.8],
                                  begin: const AlignmentDirectional(0, -1),
                                  end: const AlignmentDirectional(0, 1),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText('ybwe42qc' /* Ride Estimative */),
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w300,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  color: FlutterFlowTheme.of(context).alternate,
                                                  fontSize: 16,
                                                ),
                                          ),
                                          FutureBuilder<List<RideOrdersRecord>>(
                                            future: queryRideOrdersRecordOnce(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: SpinKitDoubleBounce(
                                                    color: FlutterFlowTheme.of(context).accent1,
                                                    size: 24,
                                                  ),
                                                );
                                              }
                                              final list = snapshot.data!;
                                              final v = functions.mediaCorridaNesseKm(
                                                FFAppState().latlngAtual!,
                                                FFAppState().latlangAondeVaiIr!,
                                                list.toList(),
                                              );
                                              final price = double.parse(
                                                (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0)
                                                    .toStringAsFixed(2),
                                              );

                                              return GradientText(
                                                formatNumber(
                                                  price,
                                                  formatType: FormatType.decimal,
                                                  decimalType: DecimalType.periodDecimal,
                                                  currency: '\$',
                                                ),
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w500,
                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).secondary,
                                                      fontSize: 16,
                                                    ),
                                                colors: [
                                                  FlutterFlowTheme.of(context).accent1,
                                                  FlutterFlowTheme.of(context).secondary,
                                                  const Color(0xFFF2E6D5),
                                                ],
                                                gradientDirection: GradientDirection.ttb,
                                                gradientType: GradientType.linear,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText('76w8fz75' /* Time */),
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w300,
                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                ),
                                          ),
                                          Text(
                                            functions.estimativeTime(
                                              FFAppState().latlngAtual!,
                                              FFAppState().latlangAondeVaiIr!,
                                            ),
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w300,
                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Container(width: 336, height: 1, color: FlutterFlowTheme.of(context).alternate),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                                            child: (_model.location != null || _model.locationAtual != null)
                                                ? GradientText(
                                                    valueOrDefault<String>(
                                                      functions.latlngForKm(
                                                        FFAppState().latlngAtual!,
                                                        FFAppState().latlangAondeVaiIr!,
                                                      ),
                                                      '2.4 Km',
                                                    ),
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.poppins(
                                                            fontWeight: FontWeight.w500,
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                          color: FlutterFlowTheme.of(context).secondary,
                                                        ),
                                                    colors: [
                                                      FlutterFlowTheme.of(context).accent1,
                                                      FlutterFlowTheme.of(context).secondary,
                                                    ],
                                                    gradientDirection: GradientDirection.rtl,
                                                    gradientType: GradientType.linear,
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                          Row(
                                            children: [
                                              // ... (resto igual ao seu)
                                            ].divide(const SizedBox(width: 10)),
                                          ),
                                        ],
                                      ),
                                      // ... (resto do bottom card e botões, inalterados)
                                    ].divide(const SizedBox(height: 5)),
                                  ),
                                ),
                              ),
                            ),
                          ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!),

                        wrapWithModel(
                          model: _model.navbarModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const NavbarWidget(),
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
    );
  }
}
