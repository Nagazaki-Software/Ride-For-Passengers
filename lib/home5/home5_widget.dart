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

  // Controller do mapa + memo do último destino + flag do 3D inicial
  final custom_widgets.PickerMapNativeController _mapCtrl =
      custom_widgets.PickerMapNativeController();
  LatLng? _lastDest;
  bool _didInitial3D = false;

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

    // carrega localização e injeta no FFAppState
    getCurrentUserLocation(
      defaultLocation: const LatLng(0.0, 0.0),
      cached: true,
    ).then((loc) => safeSetState(() {
          currentUserLocationValue = loc;
          FFAppState().latlngAtual ??= loc;
          FFAppState().update(() {});
        }));

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      currentUserLocationValue =
          await getCurrentUserLocation(defaultLocation: const LatLng(0.0, 0.0));

      _model.locationPerto = await actions.googlePlacesNearbyImportant(
        context,
        'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ',
        currentUserLocationValue!,
        3000,
        '',
        'us',
        6,
      );

      _model.fraseInicial = await actions.localGreetingAction();
      FFAppState().fraseInicial = _model.fraseInicial!;
      FFAppState().locationsPorPerto = _model.locationPerto!
          .map((e) => getJsonField(e, r'''$.name'''))
          .map((e) => e.toString())
          .toList()
          .cast<String>();
      FFAppState().latlngAtual = currentUserLocationValue;
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
            TintEffect(
              curve: Curves.easeInOut,
              delay: 90.ms,
              duration: 360.ms,
              color: const Color(0xC4BAB5B5),
              begin: 1.0,
              end: 0.0,
            ),
          ],
        ),
    });
    setupAnimations(
      animationsMap.values.where((anim) => anim.trigger == AnimationTrigger.onActionTrigger || !anim.applyInitialState),
      this,
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    // Auto-enquadrar quando o destino muda
    final userNow = FFAppState().latlngAtual;
    final destNow = FFAppState().latlangAondeVaiIr;

    if (userNow != null &&
        destNow != null &&
        (_lastDest == null ||
            _lastDest!.latitude != destNow.latitude ||
            _lastDest!.longitude != destNow.longitude)) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _mapCtrl.fitBounds([userNow!, destNow!], padding: 80);
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 350));
        try {
          await _mapCtrl.fitBounds([userNow!, destNow!], padding: 80);
        } catch (_) {}
      });
      _lastDest = destNow;
    }

    // 3D inicial quando só há origem (uma vez)
    if (!_didInitial3D && destNow == null && userNow != null) {
      _didInitial3D = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _mapCtrl.cameraTo(
            userNow.latitude,
            userNow.longitude,
            zoom: 17,
            tilt: 45,
            bearing: 30,
          );
        } catch (_) {}
      });
    }

    // loading até ter uma origem válida
    if (currentUserLocationValue == null || FFAppState().latlngAtual == null) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
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
            // MAPA NATIVO (full)
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
                      if (!snapshot.hasData || FFAppState().latlngAtual == null) {
                        return Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: SpinKitDoubleBounce(
                              color: FlutterFlowTheme.of(context).accent1,
                              size: 50,
                            ),
                          ),
                        );
                      }
                      final drivers = snapshot.data!;
                      return custom_widgets.PickerMapNative(
                        width: double.infinity,
                        height: double.infinity,
                        controller: _mapCtrl,
                        userLocation: FFAppState().latlngAtual!,
                        destination: FFAppState().latlangAondeVaiIr,

                        // Tema dark + amarelo (sem azul)
                        mapStyleJson: kGoogleMapsDarkAmberStyle,

                        // Rota âmbar e mais grossa
                        routeColor: const Color(0xFFFFC107),
                        routeWidth: 6,

                        // Parâmetros existentes
                        driversRefs: drivers.map((e) => e.reference).toList(),
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

                        // padding para não colar na navbar gestual
                        brandSafePaddingBottom: 60,

                        // Evita "véu cinza"/lite
                        liteModeOnAndroid: false,
                        ultraLowSpecMode: false,

                        // sem painel de debug
                        showDebugPanel: false,
                      );
                    },
                  ),
                ),
              ),
            ),

            // OVERLAYS (header + bottom + navbar) — igual ao seu
            PointerInterceptor(
              intercepting: isWeb,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // HEADER…
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
                                            BoxShadow(
                                              blurRadius: 4,
                                              color: Color(0x33000000),
                                              offset: Offset(0, 2),
                                            )
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
                                              boxShadow: const [
                                                BoxShadow(blurRadius: 10, color: Colors.black, offset: Offset(5, 0))
                                              ],
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF252525),
                                              boxShadow: const [
                                                BoxShadow(blurRadius: 6, color: Color(0x48FFFFFF), offset: Offset(-2, -1))
                                              ],
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            alignment: const AlignmentDirectional(0, 0),
                                            child: Icon(Icons.menu,
                                                color: FlutterFlowTheme.of(context).secondaryBackground, size: 18),
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
                                              padding:
                                                  const EdgeInsetsDirectional.fromSTEB(10, 8, 0, 8),
                                              child: Text(
                                                FFAppState().locationWhereTo,
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
                                                fontStyle: FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
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

                            // Chips de lugares por perto (inalterado)
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
                                                _model.geolocatoraddressonchoose =
                                                    await actions.geocodeAddress(
                                                  context,
                                                  'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ',
                                                  item,
                                                );
                                                FFAppState().latlangAondeVaiIr =
                                                    functions.formatStringToLantLng(
                                                  getJsonField(_model.geolocatoraddressonchoose, r'''$.lat''')
                                                      .toString(),
                                                  getJsonField(_model.geolocatoraddressonchoose, r'''$.lng''')
                                                      .toString(),
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
                                                      ? [
                                                          BoxShadow(
                                                            blurRadius: 10,
                                                            offset: const Offset(0, 4),
                                                            color: Colors.black.withOpacity(0.25),
                                                          )
                                                        ]
                                                      : const [],
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  item,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        font: GoogleFonts.poppins(
                                                          fontWeight: FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                          fontStyle: FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .fontStyle,
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

                  // Bottom card + navbar (como no seu)
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
                                                        fontStyle: FlutterFlowTheme.of(context)
                                                            .bodyMedium
                                                            .fontStyle,
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
                                                    fontStyle: FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
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
                                                    fontStyle: FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
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
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: () async {
                                                  final d = await showDatePicker(
                                                    context: context,
                                                    initialDate: getCurrentTimestamp,
                                                    firstDate: getCurrentTimestamp,
                                                    lastDate: DateTime(2050),
                                                    builder: (context, child) {
                                                      return wrapInMaterialDatePickerTheme(
                                                        context,
                                                        child!,
                                                        headerBackgroundColor: FlutterFlowTheme.of(context).primary,
                                                        headerForegroundColor: FlutterFlowTheme.of(context).info,
                                                        headerTextStyle: FlutterFlowTheme.of(context)
                                                            .headlineLarge
                                                            .override(
                                                              font: GoogleFonts.poppins(
                                                                fontWeight: FontWeight.w600,
                                                                fontStyle: FlutterFlowTheme.of(context)
                                                                    .headlineLarge
                                                                    .fontStyle,
                                                              ),
                                                              fontSize: 32,
                                                            ),
                                                        pickerBackgroundColor:
                                                            FlutterFlowTheme.of(context).secondaryBackground,
                                                        pickerForegroundColor:
                                                            FlutterFlowTheme.of(context).primaryText,
                                                        selectedDateTimeBackgroundColor:
                                                            FlutterFlowTheme.of(context).primary,
                                                        selectedDateTimeForegroundColor:
                                                            FlutterFlowTheme.of(context).info,
                                                        actionButtonForegroundColor:
                                                            FlutterFlowTheme.of(context).primaryText,
                                                        iconSize: 24,
                                                      );
                                                    },
                                                  );
                                                  if (d != null) {
                                                    safeSetState(() {
                                                      _model.datePicked = DateTime(d.year, d.month, d.day);
                                                    });
                                                  } else if (_model.datePicked != null) {
                                                    safeSetState(() {
                                                      _model.datePicked = getCurrentTimestamp;
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(context).alternate,
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                  padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.date_range,
                                                          color: Color(0xC2414141), size: 14),
                                                      Text(
                                                        _model.datePicked != null
                                                            ? dateTimeFormat(
                                                                "yMd",
                                                                _model.datePicked,
                                                                locale:
                                                                    FFLocalizations.of(context).languageCode,
                                                              )
                                                            : dateTimeFormat(
                                                                "yMd",
                                                                getCurrentTimestamp,
                                                                locale:
                                                                    FFLocalizations.of(context).languageCode,
                                                              ),
                                                        style: FlutterFlowTheme.of(context)
                                                            .bodyMedium
                                                            .override(
                                                              font: GoogleFonts.poppins(
                                                                fontWeight: FontWeight.w500,
                                                                fontStyle: FlutterFlowTheme.of(context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              color: const Color(0xC2242424),
                                                              fontSize: 8,
                                                            ),
                                                      ),
                                                    ].divide(const SizedBox(width: 4)),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: () async {
                                                  if (animationsMap['containerOnActionTriggerAnimation2'] != null) {
                                                    safeSetState(() => hasContainerTriggered2 = true);
                                                    SchedulerBinding.instance.addPostFrameCallback(
                                                      (_) async => await animationsMap[
                                                              'containerOnActionTriggerAnimation2']!
                                                          .controller
                                                          .forward(from: 0.0),
                                                    );
                                                  }
                                                  FFAppState().passangers =
                                                      FFAppState().passangers == 8 ? 1 : FFAppState().passangers + 1;
                                                  safeSetState(() {});
                                                },
                                                child: Container(
                                                  width: 80,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(context).alternate,
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(Icons.person_outline,
                                                          color: Color(0xC2414141), size: 14),
                                                      Text(
                                                        '${valueOrDefault<String>(FFAppState().passangers.toString(), '1')} passengers',
                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                              font: GoogleFonts.poppins(
                                                                fontWeight: FontWeight.w500,
                                                                fontStyle: FlutterFlowTheme.of(context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              color: const Color(0xC2242424),
                                                              fontSize: 8,
                                                            ),
                                                      ),
                                                    ].divide(const SizedBox(width: 4)),
                                                  ),
                                                ),
                                              ).animateOnActionTrigger(
                                                animationsMap['containerOnActionTriggerAnimation2']!,
                                                hasBeenTriggered: hasContainerTriggered2,
                                              ),
                                            ].divide(const SizedBox(width: 10)),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _optionChip(
                                              context: context,
                                              labelKey: '6xonkgu6', // Ride
                                              minutesKey: 'hp82na6c',
                                              selected: _model.rideChoose == 'ride',
                                              onTap: () async {
                                                if (animationsMap['containerOnActionTriggerAnimation3'] != null) {
                                                  safeSetState(() => hasContainerTriggered3 = true);
                                                  SchedulerBinding.instance.addPostFrameCallback(
                                                    (_) async => await animationsMap[
                                                            'containerOnActionTriggerAnimation3']!
                                                        .controller
                                                        .forward(from: 0.0),
                                                  );
                                                }
                                                _model.rideChoose = 'ride';
                                                safeSetState(() {});
                                              },
                                              animKey: 'containerOnActionTriggerAnimation3',
                                              hasBeenTriggered: hasContainerTriggered3,
                                              animationsMap: animationsMap,
                                            ),
                                            _optionChip(
                                              context: context,
                                              labelKey: 'h5ahsyfq', // XL
                                              minutesKey: 'tr0g6iky',
                                              selected: _model.rideChoose == 'xl',
                                              onTap: () async {
                                                if (animationsMap['containerOnActionTriggerAnimation4'] != null) {
                                                  safeSetState(() => hasContainerTriggered4 = true);
                                                  SchedulerBinding.instance.addPostFrameCallback(
                                                    (_) async => await animationsMap[
                                                            'containerOnActionTriggerAnimation4']!
                                                        .controller
                                                        .forward(from: 0.0),
                                                  );
                                                }
                                                _model.rideChoose = 'xl';
                                                safeSetState(() {});
                                              },
                                              animKey: 'containerOnActionTriggerAnimation4',
                                              hasBeenTriggered: hasContainerTriggered4,
                                              animationsMap: animationsMap,
                                            ),
                                            _optionChip(
                                              context: context,
                                              labelKey: 'drdui58r', // Luxury
                                              minutesKey: 'zkgb4g4y',
                                              selected: _model.rideChoose == 'luxury',
                                              onTap: () async {
                                                if (animationsMap['containerOnActionTriggerAnimation5'] != null) {
                                                  safeSetState(() => hasContainerTriggered5 = true);
                                                  SchedulerBinding.instance.addPostFrameCallback(
                                                    (_) async => await animationsMap[
                                                            'containerOnActionTriggerAnimation5']!
                                                        .controller
                                                        .forward(from: 0.0),
                                                  );
                                                }
                                                _model.rideChoose = 'luxury';
                                                safeSetState(() {});
                                              },
                                              animKey: 'containerOnActionTriggerAnimation5',
                                              hasBeenTriggered: hasContainerTriggered5,
                                              animationsMap: animationsMap,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            onTap: () async {
                                              currentUserLocationValue = await getCurrentUserLocation(
                                                defaultLocation: const LatLng(0.0, 0.0),
                                              );
                                              if (animationsMap['containerOnActionTriggerAnimation6'] != null) {
                                                safeSetState(() => hasContainerTriggered6 = true);
                                                SchedulerBinding.instance.addPostFrameCallback(
                                                  (_) async => await animationsMap[
                                                          'containerOnActionTriggerAnimation6']!
                                                      .controller
                                                      .forward(from: 0.0),
                                                );
                                              }
                                              context.pushNamed(
                                                PaymentRide7Widget.routeName,
                                                queryParameters: {
                                                  'estilo': serializeParam(_model.rideChoose, ParamType.String),
                                                  'latlngAtual': serializeParam(
                                                    FFAppState().latlngAtual ?? currentUserLocationValue,
                                                    ParamType.LatLng,
                                                  ),
                                                  'latlngWhereTo': serializeParam(
                                                    FFAppState().latlangAondeVaiIr,
                                                    ParamType.LatLng,
                                                  ),
                                                }.withoutNulls,
                                                extra: const <String, dynamic>{
                                                  kTransitionInfoKey: TransitionInfo(
                                                    hasTransition: true,
                                                    transitionType: PageTransitionType.leftToRight,
                                                  ),
                                                },
                                              );
                                            },
                                            child: Container(
                                              width: 120,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).accent1,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              alignment: const AlignmentDirectional(0, 0),
                                              child: Text(
                                                FFLocalizations.of(context).getText('iv1ii278' /* Confirm Ride   */),
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.bold,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 10,
                                                    ),
                                              ),
                                            ),
                                          ).animateOnActionTrigger(
                                            animationsMap['containerOnActionTriggerAnimation6']!,
                                            hasBeenTriggered: hasContainerTriggered6,
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            onTap: () async {
                                              if (animationsMap['containerOnActionTriggerAnimation7'] != null) {
                                                safeSetState(() => hasContainerTriggered7 = true);
                                                SchedulerBinding.instance.addPostFrameCallback(
                                                  (_) async => await animationsMap[
                                                          'containerOnActionTriggerAnimation7']!
                                                      .controller
                                                      .forward(from: 0.0),
                                                );
                                              }
                                              context.pushNamed(
                                                RideShare6Widget.routeName,
                                                extra: const <String, dynamic>{
                                                  kTransitionInfoKey: TransitionInfo(
                                                    hasTransition: true,
                                                    transitionType: PageTransitionType.rightToLeft,
                                                  ),
                                                },
                                              );
                                            },
                                            child: Container(
                                              width: 120,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).alternate,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              alignment: const AlignmentDirectional(0, 0),
                                              child: Text(
                                                FFLocalizations.of(context).getText('nzvn5ujp' /* Ride Share */),
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.bold,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 10,
                                                    ),
                                              ),
                                            ),
                                          ).animateOnActionTrigger(
                                            animationsMap['containerOnActionTriggerAnimation7']!,
                                            hasBeenTriggered: hasContainerTriggered7,
                                          ),
                                        ],
                                      ),
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

  // Helper para os botões Ride/XL/Luxury
  Widget _optionChip({
    required BuildContext context,
    required String labelKey,
    required String minutesKey,
    required bool selected,
    required VoidCallback onTap,
    required String animKey,
    required bool hasBeenTriggered,
    required Map<String, AnimationInfo> animationsMap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: 70,
        height: 35,
        decoration: BoxDecoration(
          boxShadow: const [BoxShadow(blurRadius: 4, color: Color(0x33000000), offset: Offset(0, 2))],
          gradient: LinearGradient(
            colors: [
              selected ? const Color(0xFFF4B000) : FlutterFlowTheme.of(context).primaryText,
              selected ? const Color(0xFFEE8B05) : FlutterFlowTheme.of(context).primaryText,
            ],
            stops: const [0, 1],
            begin: const AlignmentDirectional(0.03, -1),
            end: const AlignmentDirectional(-0.03, 1),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FFLocalizations.of(context).getText(labelKey),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).alternate,
                      fontSize: 8,
                    ),
              ),
              Text(
                FFLocalizations.of(context).getText(minutesKey),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 8,
                    ),
              ),
            ],
          ),
        ),
      ),
    ).animateOnActionTrigger(
      animationsMap[animKey]!,
      hasBeenTriggered: hasBeenTriggered,
    );
  }
}

// Tema DARK com acentos âmbar (amarelo), sem azul.
const String kGoogleMapsDarkAmberStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1a1a1a"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1a1a1a"}]},

  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#5f5f5f"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#252525"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1f1f1f"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#232323"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0d0d0d"}]},

  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a2a2a"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#3a3a3a"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#444444"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#e6c200"}]},
  {"featureType":"road","elementType":"labels.text.stroke","stylers":[{"color":"#151515"}]},

  {"featureType":"poi.business","elementType":"labels.text.fill","stylers":[{"color":"#ffc107"}]},
  {"featureType":"poi.attraction","elementType":"labels.text.fill","stylers":[{"color":"#ffc107"}]}
]
''';
