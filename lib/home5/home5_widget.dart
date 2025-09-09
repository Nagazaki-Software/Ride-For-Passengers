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

class _Home5WidgetState extends State<Home5Widget>
    with TickerProviderStateMixin {
  late Home5Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;
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

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      currentUserLocationValue =
          await getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0));
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
          .map((e) => getJsonField(
                e,
                r'''$.name''',
              ))
          .toList()
          .map((e) => e.toString())
          .toList()
          .toList()
          .cast<String>();
      FFAppState().latlngAtual = currentUserLocationValue;
      FFAppState().update(() {});
    });

    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
    animationsMap.addAll({
      'containerOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xAEFB9000),
            begin: 1.0,
            end: 0.0,
          ),
        ],
      ),
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 980.0.ms,
            begin: Offset(0.0, -30.0),
            end: Offset(0.0, 0.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 450.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1.0,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1.0,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1.0,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1.0,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1.0,
            end: 0.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation7': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xB9FB9000),
            begin: 1.0,
            end: 0.0,
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
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
    if (currentUserLocationValue == null) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        child: Center(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: SpinKitDoubleBounce(
              color: FlutterFlowTheme.of(context).accent1,
              size: 50.0,
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
            PointerInterceptor(
              intercepting: isWeb,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 60.0),
                child: AuthUserStreamWidget(
                  builder: (context) => StreamBuilder<List<UsersRecord>>(
                    stream: queryUsersRecord(
                      queryBuilder: (usersRecord) => usersRecord
                          .where(
                            'driver',
                            isEqualTo: true,
                          )
                          .where(
                            'driverOnline',
                            isEqualTo: true,
                          ),
                    ),
                    builder: (context, snapshot) {
                      // Customize what your widget looks like when it's loading.
                      if (!snapshot.hasData) {
                        return Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: SpinKitDoubleBounce(
                              color: FlutterFlowTheme.of(context).accent1,
                              size: 50.0,
                            ),
                          ),
                        );
                      }
                      List<UsersRecord> pickerMapUsersRecordList =
                          snapshot.data!;

                      return Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 1.0,
                        child: custom_widgets.PickerMapNative(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: MediaQuery.sizeOf(context).height * 1.0,
                          userLocation: FFAppState().latlngAtual!,
                          googleApiKey:
                              'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ',
                          driversRefs: pickerMapUsersRecordList
                              .map((e) => e.reference)
                              .toList(),
                          destination: FFAppState().latlangAondeVaiIr,
                          refreshMs: 6000,
                          destinationMarkerPngUrl:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png',
                          userPhotoUrl: currentUserPhoto,
                          userMarkerSize: 40,
                          userName: currentUserDisplayName,
                          routeColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          routeWidth: 2,
                          borderRadius: 0.0,
                          driverIconWidth: 70,
                          driverTaxiIconAsset:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
                          driverDriverIconUrl:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/bgmclb0d2bsd/ChatGPT_Image_3_de_set._de_2025%2C_19_17_48.png',
                          driverTaxiIconUrl:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
                          enableRouteSnake: true,
                          brandSafePaddingBottom: 60.0,
                          liteModeOnAndroid: false,
                          ultraLowSpecMode: false,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            PointerInterceptor(
              intercepting: isWeb,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xB517181D), Color(0x0717181D)],
                        stops: [0.0, 1.0],
                        begin: AlignmentDirectional(0.0, -1.0),
                        end: AlignmentDirectional(0, 1.0),
                      ),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  18.0, 35.0, 18.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        width: 70.0,
                                        height: 70.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 4.0,
                                              color: Color(0x33000000),
                                              offset: Offset(
                                                0.0,
                                                2.0,
                                              ),
                                            )
                                          ],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: AuthUserStreamWidget(
                                                builder: (context) => Container(
                                                  width: 200.0,
                                                  height: 200.0,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Image.network(
                                                    currentUserPhoto,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (currentUserPhoto == '')
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: AuthUserStreamWidget(
                                                  builder: (context) => Text(
                                                    functions.partesDoName(
                                                        currentUserDisplayName),
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
                                                          fontSize: 18.0,
                                                          letterSpacing: 3.0,
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
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            FFAppState().fraseInicial,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFF696C6F),
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          AuthUserStreamWidget(
                                            builder: (context) => Text(
                                              currentUserDisplayName,
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
                                                    fontSize: 16.0,
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
                                          ),
                                        ],
                                      ),
                                    ].divide(SizedBox(width: 10.0)),
                                  ),
                                  Stack(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                width: 38.0,
                                                height: 38.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 10.0,
                                                      color: Colors.black,
                                                      offset: Offset(5.0, 0.0),
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(20.0),
                                                    bottomRight:
                                                        Radius.circular(20.0),
                                                    topLeft:
                                                        Radius.circular(20.0),
                                                    topRight:
                                                        Radius.circular(20.0),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 38.0,
                                                height: 38.0,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF252525),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 6.0,
                                                      color: Color(0x48FFFFFF),
                                                      offset: Offset(
                                                        -2.0,
                                                        -1.0,
                                                      ),
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(20.0),
                                                    bottomRight:
                                                        Radius.circular(20.0),
                                                    topLeft:
                                                        Radius.circular(20.0),
                                                    topRight:
                                                        Radius.circular(20.0),
                                                  ),
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.menu,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 18.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                    ],
                                  ),
                                ].divide(SizedBox(width: 12.0)),
                              ),
                            ),
                            Stack(
                              alignment: AlignmentDirectional(0.0, -1.0),
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 8.0, 0.0, 0.0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
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
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: SelectLocationWidget(
                                                escolha: 'textfield',
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.9,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      10.0, 8.0, 0.0, 8.0),
                                              child: Text(
                                                FFAppState().locationWhereTo,
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
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
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
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 12.0, 0.0),
                                    child: Container(
                                      width: 48.0,
                                      height: 18.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'v2jubsa7' /* 3 min */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              fontSize: 10.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: AlignmentDirectional(-1.0, -1.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    17.0, 6.0, 12.0, 0.0),
                                child: Builder(
                                  builder: (context) {
                                    final pertos =
                                        FFAppState().locationsPorPerto.toList();

                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: List.generate(pertos.length,
                                            (pertosIndex) {
                                          final pertosItem =
                                              pertos[pertosIndex];
                                          return InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (FFAppState().listPerto ==
                                                  pertosItem) {
                                                FFAppState().latlangAondeVaiIr =
                                                    null;
                                                FFAppState().listPerto = '';
                                                FFAppState().locationWhereTo =
                                                    'Where to?';
                                                safeSetState(() {});
                                              } else {
                                                _model.geolocatoraddressonchoose =
                                                    await actions
                                                        .geocodeAddress(
                                                  context,
                                                  'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ',
                                                  pertosItem,
                                                );
                                                FFAppState().latlangAondeVaiIr =
                                                    functions
                                                        .formatStringToLantLng(
                                                            getJsonField(
                                                              _model
                                                                  .geolocatoraddressonchoose,
                                                              r'''$.lat''',
                                                            ).toString(),
                                                            getJsonField(
                                                              _model
                                                                  .geolocatoraddressonchoose,
                                                              r'''$.lng''',
                                                            ).toString());
                                                FFAppState().listPerto =
                                                    pertosItem;
                                                FFAppState().locationWhereTo =
                                                    pertosItem;
                                                safeSetState(() {});
                                              }

                                              safeSetState(() {});
                                            },
                                            child: Container(
                                              height: 26.0,
                                              decoration: BoxDecoration(
                                                color: valueOrDefault<Color>(
                                                  FFAppState().listPerto ==
                                                          pertosItem
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .accent1
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                  FlutterFlowTheme.of(context)
                                                      .accent1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        6.0, 0.0, 6.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      pertosItem,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: Color(
                                                                    0xFF585858),
                                                                fontSize: 10.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ).animateOnActionTrigger(
                                              animationsMap[
                                                  'containerOnActionTriggerAnimation1']!,
                                              hasBeenTriggered:
                                                  hasContainerTriggered1);
                                        }).divide(SizedBox(width: 8.0)),
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
                  Spacer(flex: 10),
                  Align(
                    alignment: AlignmentDirectional(0.0, 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                       // Generated code for this Container Widget...
if (FFAppState().latlangAondeVaiIr != null)
  Padding(
    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 28),
    child: Container(
      width: MediaQuery.sizeOf(context).width * 0.86,
      height: 182,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF333333), FlutterFlowTheme.of(context).primary],
          stops: [0, 0.8],
          begin: AlignmentDirectional(0, -1),
          end: AlignmentDirectional(0, 1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          'ybwe42qc' /* Ride Estimative */,
                        ),
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.italic,
                              ),
                              color: FlutterFlowTheme.of(context).alternate,
                              fontSize: 16,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      FutureBuilder<List<RideOrdersRecord>>(
                        future: queryRideOrdersRecordOnce(),
                        builder: (context, snapshot) {
                          // Customize what your widget looks like when it's loading.
                          if (!snapshot.hasData) {
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
                          List<RideOrdersRecord> textRideOrdersRecordList =
                              snapshot.data!;
                          return GradientText(
                            formatNumber(
                              functions.mediaCorridaNesseKm(
                                  FFAppState().latlngAtual!,
                                  FFAppState().latlangAondeVaiIr!,
                                  textRideOrdersRecordList.toList()),
                              formatType: FormatType.decimal,
                              decimalType: DecimalType.commaDecimal,
                              currency: '\$',
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
                                  color:
                                      FlutterFlowTheme.of(context).secondary,
                                  fontSize: 16,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                            colors: [
                              FlutterFlowTheme.of(context).accent1,
                              FlutterFlowTheme.of(context).secondary,
                              Color(0xFFF2E6D5)
                            ],
                            gradientDirection: GradientDirection.ttb,
                            gradientType: GradientType.linear,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          '76w8fz75' /* Time */,
                        ),
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color:
                                  FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w300,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        functions.estimativeTime(FFAppState().latlngAtual!,
                            FFAppState().latlangAondeVaiIr!),
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color:
                                  FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w300,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 336,
                height: 1,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if ((_model.location != null) ||
                            (_model.locationAtual != null))
                          GradientText(
                            valueOrDefault<String>(
                              functions.latlngForKm(FFAppState().latlngAtual!,
                                  FFAppState().latlangAondeVaiIr!),
                              '2.4 Km',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).secondary,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                            colors: [
                              FlutterFlowTheme.of(context).accent1,
                              FlutterFlowTheme.of(context).secondary
                            ],
                            gradientDirection: GradientDirection.rtl,
                            gradientType: GradientType.linear,
                          ),
                      ],
                    ),
                  ),
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
                          final _datePickedDate = await showDatePicker(
                            context: context,
                            initialDate: getCurrentTimestamp,
                            firstDate: getCurrentTimestamp,
                            lastDate: DateTime(2050),
                            builder: (context, child) {
                              return wrapInMaterialDatePickerTheme(
                                context,
                                child!,
                                headerBackgroundColor:
                                    FlutterFlowTheme.of(context).primary,
                                headerForegroundColor:
                                    FlutterFlowTheme.of(context).info,
                                headerTextStyle: FlutterFlowTheme.of(context)
                                    .headlineLarge
                                    .override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .headlineLarge
                                                .fontStyle,
                                      ),
                                      fontSize: 32,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineLarge
                                          .fontStyle,
                                    ),
                                pickerBackgroundColor:
                                    FlutterFlowTheme.of(context)
                                        .secondaryBackground,
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
                          if (_datePickedDate != null) {
                            safeSetState(() {
                              _model.datePicked = DateTime(
                                _datePickedDate.year,
                                _datePickedDate.month,
                                _datePickedDate.day,
                              );
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
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.date_range,
                                  color: Color(0xC2414141),
                                  size: 14,
                                ),
                                Text(
                                  _model.datePicked != null
                                      ? dateTimeFormat(
                                          "yMd",
                                          _model.datePicked,
                                          locale: FFLocalizations.of(context)
                                              .languageCode,
                                        )
                                      : dateTimeFormat(
                                          "yMd",
                                          getCurrentTimestamp,
                                          locale: FFLocalizations.of(context)
                                              .languageCode,
                                        ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: Color(0xC2242424),
                                        fontSize: 8,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                      ),
                                ),
                              ]
                                  .divide(SizedBox(width: 4))
                                  .around(SizedBox(width: 4)),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation2'] !=
                              null) {
                            safeSetState(() => hasContainerTriggered2 = true);
                            SchedulerBinding.instance.addPostFrameCallback(
                                (_) async => await animationsMap[
                                        'containerOnActionTriggerAnimation2']!
                                    .controller
                                    .forward(from: 0.0));
                          }
                          if (FFAppState().passangers == 8) {
                            FFAppState().passangers = 1;
                            safeSetState(() {});
                          } else {
                            FFAppState().passangers =
                                FFAppState().passangers + 1;
                            safeSetState(() {});
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 24,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Color(0xC2414141),
                                size: 14,
                              ),
                              Text(
                                '${valueOrDefault<String>(
                                  FFAppState().passangers.toString(),
                                  '1',
                                )} passengers',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                      ),
                                      color: Color(0xC2242424),
                                      fontSize: 8,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ].divide(SizedBox(width: 4)),
                          ),
                        ),
                      ).animateOnActionTrigger(
                          animationsMap[
                              'containerOnActionTriggerAnimation2']!,
                          hasBeenTriggered: hasContainerTriggered2),
                    ].divide(SizedBox(width: 10)),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 2),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        if (_model.rideChoose == 'ride') {
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation3'] !=
                              null) {
                            safeSetState(() => hasContainerTriggered3 = true);
                            SchedulerBinding.instance.addPostFrameCallback(
                                (_) async => await animationsMap[
                                        'containerOnActionTriggerAnimation3']!
                                    .controller
                                    .forward(from: 0.0));
                          }
                        } else {
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation3'] !=
                              null) {
                            safeSetState(() => hasContainerTriggered3 = true);
                            SchedulerBinding.instance.addPostFrameCallback(
                                (_) async => await animationsMap[
                                        'containerOnActionTriggerAnimation3']!
                                    .controller
                                    .forward(from: 0.0));
                          }
                          _model.rideChoose = 'ride';
                          safeSetState(() {});
                        }
                      },
                      child: Container(
                        width: 70,
                        height: 35,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Color(0x33000000),
                              offset: Offset(
                                0,
                                2,
                              ),
                            )
                          ],
                          gradient: LinearGradient(
                            colors: [
                              _model.rideChoose == 'ride'
                                  ? Color(0xFFF4B000)
                                  : FlutterFlowTheme.of(context).primaryText,
                              _model.rideChoose == 'ride'
                                  ? Color(0xFFEE8B05)
                                  : FlutterFlowTheme.of(context).primaryText
                            ],
                            stops: [0, 1],
                            begin: AlignmentDirectional(0.03, -1),
                            end: AlignmentDirectional(-0.03, 1),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(5, 5, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FFLocalizations.of(context).getText(
                                  '6xonkgu6' /* Ride  */,
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
                                          .alternate,
                                      fontSize: 8,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                              Text(
                                FFLocalizations.of(context).getText(
                                  'hp82na6c' /* 3 min */,
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
                                          .secondaryText,
                                      fontSize: 8,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animateOnActionTrigger(
                        animationsMap['containerOnActionTriggerAnimation3']!,
                        hasBeenTriggered: hasContainerTriggered3),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        if (_model.rideChoose == 'xl') {
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation4'] !=
                              null) {
                            safeSetState(() => hasContainerTriggered4 = true);
                            SchedulerBinding.instance.addPostFrameCallback(
                                (_) async => await animationsMap[
                                        'containerOnActionTriggerAnimation4']!
                                    .controller
                                    .forward(from: 0.0));
                          }
                        } else {
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation4'] !=
                              null) {
                            safeSetState(() => hasContainerTriggered4 = true);
                            SchedulerBinding.instance.addPostFrameCallback(
                                (_) async => await animationsMap[
                                        'containerOnActionTriggerAnimation4']!
                                    .controller
                                    .forward(from: 0.0));
                          }
                          _model.rideChoose = 'xl';
                          safeSetState(() {});
                        }
                      },
                      child: Container(
                        width: 70,
                        height: 35,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Color(0x33000000),
                              offset: Offset(
                                0,
                                2,
                              ),
                            )
                          ],
                          gradient: LinearGradient(
                            colors: [
                              _model.rideChoose == 'xl'
                                  ? Color(0xFFF4B000)
                                  : FlutterFlowTheme.of(context).primaryText,
                              _model.rideChoose == 'xl'
                                  ? Color(0xFFEE8B05)
                                  : FlutterFlowTheme.of(context).primaryText
                            ],
                            stops: [0, 1],
                            begin: AlignmentDirectional(0.03, -1),
                            end: AlignmentDirectional(-0.03, 1),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(5, 5, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FFLocalizations.of(context).getText(
                                  'h5ahsyfq' /* XL */,
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
                                          .alternate,
                                      fontSize: 8,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                              Text(
                                FFLocalizations.of(context).getText(
                                  'tr0g6iky' /* 6 min */,
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
                                          .secondaryText,
                                      fontSize: 8,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animateOnActionTrigger(
                        animationsMap['containerOnActionTriggerAnimation4']!,
                        hasBeenTriggered: hasContainerTriggered4),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        if (_model.rideChoose == 'luxury') {
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation5'] !=
                              null) {
                            safeSetState(() => hasContainerTriggered5 = true);
                            SchedulerBinding.instance.addPostFrameCallback(
                                (_) async => await animationsMap[
                                        'containerOnActionTriggerAnimation5']!
                                    .controller
                                    .forward(from: 0.0));
                          }
                        } else {
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation5'] !=
                              null) {
                            safeSetState(() => hasContainerTriggered5 = true);
                            SchedulerBinding.instance.addPostFrameCallback(
                                (_) async => await animationsMap[
                                        'containerOnActionTriggerAnimation5']!
                                    .controller
                                    .forward(from: 0.0));
                          }
                          _model.rideChoose = 'luxury';
                          safeSetState(() {});
                        }
                      },
                      child: Container(
                        width: 70,
                        height: 35,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Color(0x33000000),
                              offset: Offset(
                                0,
                                2,
                              ),
                            )
                          ],
                          gradient: LinearGradient(
                            colors: [
                              _model.rideChoose == 'luxury'
                                  ? Color(0xFFF4B000)
                                  : FlutterFlowTheme.of(context).primaryText,
                              _model.rideChoose == 'luxury'
                                  ? Color(0xFFEE8B05)
                                  : FlutterFlowTheme.of(context).primaryText
                            ],
                            stops: [0, 1],
                            begin: AlignmentDirectional(0.03, -1),
                            end: AlignmentDirectional(-0.03, 1),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(5, 5, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FFLocalizations.of(context).getText(
                                  'drdui58r' /* Luxury */,
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
                                          .alternate,
                                      fontSize: 8,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                              Text(
                                FFLocalizations.of(context).getText(
                                  'zkgb4g4y' /* 10 min */,
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
                                          .secondaryText,
                                      fontSize: 8,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animateOnActionTrigger(
                        animationsMap['containerOnActionTriggerAnimation5']!,
                        hasBeenTriggered: hasContainerTriggered5),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      currentUserLocationValue = await getCurrentUserLocation(
                          defaultLocation: LatLng(0.0, 0.0));
                      if (animationsMap[
                              'containerOnActionTriggerAnimation6'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered6 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation6']!
                                .controller
                                .forward(from: 0.0));
                      }
                      context.pushNamed(
                        PaymentRide7Widget.routeName,
                        queryParameters: {
                          'estilo': serializeParam(
                            _model.rideChoose,
                            ParamType.String,
                          ),
                          'latlngAtual': serializeParam(
                            FFAppState().latlngAtual != null
                                ? FFAppState().latlngAtual
                                : currentUserLocationValue,
                            ParamType.LatLng,
                          ),
                          'latlngWhereTo': serializeParam(
                            FFAppState().latlangAondeVaiIr,
                            ParamType.LatLng,
                          ),
                        }.withoutNulls,
                        extra: <String, dynamic>{
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
                      alignment: AlignmentDirectional(0, 0),
                      child: Text(
                        FFLocalizations.of(context).getText(
                          'iv1ii278' /* Confirm Ride   */,
                        ),
                        style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 10,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                      ),
                    ),
                  ).animateOnActionTrigger(
                      animationsMap['containerOnActionTriggerAnimation6']!,
                      hasBeenTriggered: hasContainerTriggered6),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      if (animationsMap[
                              'containerOnActionTriggerAnimation7'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered7 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation7']!
                                .controller
                                .forward(from: 0.0));
                      }
                      context.pushNamed(
                        RideShare6Widget.routeName,
                        extra: <String, dynamic>{
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
                      alignment: AlignmentDirectional(0, 0),
                      child: Text(
                        FFLocalizations.of(context).getText(
                          'nzvn5ujp' /* Ride Share */,
                        ),
                        style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 10,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                      ),
                    ),
                  ).animateOnActionTrigger(
                      animationsMap['containerOnActionTriggerAnimation7']!,
                      hasBeenTriggered: hasContainerTriggered7),
                ],
              ),
            ].divide(SizedBox(height: 5)),
          ),
        ),
      ),
    ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!),
  )

                      ],
                    ),
                  ),
                  wrapWithModel(
                    model: _model.navbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: NavbarWidget(),
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
