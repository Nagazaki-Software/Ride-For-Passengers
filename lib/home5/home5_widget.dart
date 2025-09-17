import '/auth/firebase_auth/auth_util.dart';
<<<<<<< HEAD
  import '/backend/backend.dart';
  import '/components/navbar_widget.dart';
  import '/components/select_location_widget.dart';
  import '/flutter_flow/flutter_flow_animations.dart';
  import '/flutter_flow/flutter_flow_theme.dart';
  import '/flutter_flow/flutter_flow_util.dart';
  import '/flutter_flow/flutter_flow_widgets.dart';
  import '/flutter_flow/lat_lng.dart';
  import 'dart:convert';
  import 'dart:ui';
  import 'package:http/http.dart' as http;
  import '/custom_code/actions/index.dart' as actions;
  import '/flutter_flow/custom_functions.dart' as functions;
  import '/index.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/scheduler.dart';
  import 'package:flutter_animate/flutter_animate.dart';
  import 'package:flutter_spinkit/flutter_spinkit.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:provider/provider.dart';
  import 'package:simple_gradient_text/simple_gradient_text.dart';
  import '/picker_map_native.dart'; // <-- new
=======
import '/backend/backend.dart';
import '/components/navbar_widget.dart';
import '/components/select_location_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '/picker_map_native.dart'; // <-- new

import 'home5_model.dart';
export 'home5_model.dart';
>>>>>>> 10c9b5c (new frkdfm)

  import 'home5_model.dart';
  export 'home5_model.dart';

  class Home5Widget extends StatefulWidget {
    const Home5Widget({super.key});

    static String routeName = 'Home5';
    static String routePath = '/home5';

<<<<<<< HEAD
    @override
    State<Home5Widget> createState() => _Home5WidgetState();
  }

  class _Home5WidgetState extends State<Home5Widget> with TickerProviderStateMixin {
    late Home5Model _model;
    final scaffoldKey = GlobalKey<ScaffoldState>();
    LatLng? currentUserLocationValue;
    final animationsMap = <String, AnimationInfo>{};
    String? _encodedPolyline;

    @override
    void initState() {
      super.initState();
      _model = createModel(context, () => Home5Model());

      SchedulerBinding.instance.addPostFrameCallback((_) async {
        currentUserLocationValue = await getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0));
        _model.locationPerto = await actions.googlePlacesNearbyImportant(
          context,
          'YOUR_GOOGLE_API_KEY',
          currentUserLocationValue!,
          3000,
          '',
          'us',
          6,
        );
        _model.fraseInicial = await actions.localGreetingAction();
        FFAppState().fraseInicial = _model.fraseInicial!;
        FFAppState().locationsPorPerto = _model.locationPerto!
            .map((e) => getJsonField(e, r'$.name'))
            .toList()
            .map((e) => e.toString())
            .toList()
            .cast<String>();
        FFAppState().latlngAtual = currentUserLocationValue;
        FFAppState().update(() {});
      });

      getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
          .then((loc) => safeSetState(() => currentUserLocationValue = loc));
    }

    @override
    void dispose() {
      _model.dispose();
      super.dispose();
    }

    Future<void> _maybeFetchPolyline() async {
      final origin = FFAppState().latlngAtual;
      final dest = FFAppState().latlangAondeVaiIr;
      if (origin == null || dest == null) return;
      try {
        final key = 'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ';
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${dest.latitude},${dest.longitude}'
          '&mode=driving&key=$key',
        );
        final res = await http.get(url);
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          final routes = data['routes'] as List?;
          if (routes != null && routes.isNotEmpty) {
            final enc = routes[0]['overview_polyline']?['points'] as String?;
            if (enc != null && enc.isNotEmpty) {
              setState(() => _encodedPolyline = enc);
            }
          }
        }
      } catch (_) {}
    }

    @override
    Widget build(BuildContext context) {
      context.watch<FFAppState>();
      if (currentUserLocationValue == null) {
        return Container(
          color: FlutterFlowTheme.of(context).primaryBackground,
          child: Center(
            child: SizedBox(
              width: 50, height: 50,
              child: SpinKitDoubleBounce(
                color: FlutterFlowTheme.of(context).accent1, size: 50,
              ),
            ),
          ),
        );
      }

      // When destination changes, refresh route
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (FFAppState().latlangAondeVaiIr != null) _maybeFetchPolyline();
      });

      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryText,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 60),
                child: AuthUserStreamWidget(
                  builder: (context) => StreamBuilder<List<UsersRecord>>(
                    stream: queryUsersRecord(
                      queryBuilder: (usersRecord) => usersRecord
                          .where('driver', isEqualTo: true)
                          .where('driverOnline', isEqualTo: true),
=======
class _Home5WidgetState extends State<Home5Widget>
    with TickerProviderStateMixin {
  late Home5Model _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;
  final animationsMap = <String, AnimationInfo>{};
  String? _encodedPolyline;
  LatLng? _lastDest;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Home5Model());

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
      // Apenas lugares com lat/lng conhecido e nome válido, já ordenados por distância
      final items = _model.locationPerto!;
      final filteredNames = <String>[];
      final mapping = <String, LatLng>{};
      for (final e in items) {
        final name = getJsonField(e, r'$.name').toString();
        final lat = getJsonField(e, r'$.lat');
        final lng = getJsonField(e, r'$.lng');
        if (name.isEmpty || lat == null || lng == null) continue;
        final dlat = (lat as num).toDouble();
        final dlng = (lng as num).toDouble();
        filteredNames.add(name);
        mapping[name] = LatLng(dlat, dlng);
      }
      FFAppState().locationsPorPerto = filteredNames;
      FFAppState().locationsPorPertoMap = mapping;
      FFAppState().latlngAtual = currentUserLocationValue;
      FFAppState().update(() {});
    });

    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _maybeFetchPolyline() async {
    final origin = FFAppState().latlngAtual;
    final dest = FFAppState().latlangAondeVaiIr;
    if (origin == null || dest == null) return;
    try {
      final key = 'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ';
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${dest.latitude},${dest.longitude}'
        '&mode=driving&key=$key',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final enc = routes[0]['overview_polyline']?['points'] as String?;
          if (enc != null && enc.isNotEmpty) {
            setState(() => _encodedPolyline = enc);
          }
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    if (currentUserLocationValue == null) {
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

    // When destination changes (even to another LatLng), refresh or clear route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dest = FFAppState().latlangAondeVaiIr;
      if (dest != null) {
        final changed = _lastDest == null ||
            _lastDest!.latitude != dest.latitude ||
            _lastDest!.longitude != dest.longitude;
        if (changed) _maybeFetchPolyline();
        _lastDest = dest;
      } else {
        if (_encodedPolyline != null) setState(() => _encodedPolyline = null);
        _lastDest = null;
      }
    });

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 60),
              child: AuthUserStreamWidget(
                builder: (context) => StreamBuilder<List<UsersRecord>>(
                  stream: queryUsersRecord(
                    queryBuilder: (usersRecord) => usersRecord
                        .where('driver', isEqualTo: true)
                        .where('driverOnline', isEqualTo: true),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: SizedBox(
                        width: 50,
                        height: 50,
                        child: SpinKitDoubleBounce(
                            color: FlutterFlowTheme.of(context).accent1,
                            size: 50),
                      ));
                    }
                    final drivers = snapshot.data!;
                    // Best effort mapping: expects fields 'driverLat' & 'driverLng' or 'lastLatLng' (FlutterFlow LatLng JSON).
                    List<Map<String, dynamic>> driverMaps = [];
                    for (final u in drivers) {
                      try {
                        double? lat;
                        double? lng;
                        // Try common field names – adjust to your schema
                        final any = u.reference; // keep id
                        final data = u.snapshotData;
                        if (data['driverLat'] != null &&
                            data['driverLng'] != null) {
                          lat = (data['driverLat'] as num).toDouble();
                          lng = (data['driverLng'] as num).toDouble();
                        } else if (data['lastLatLng'] != null) {
                          final m = data['lastLatLng'];
                          if (m is LatLng) {
                            lat = m.latitude;
                            lng = m.longitude;
                          } else if (m is Map) {
                            if (m['lat'] != null && m['lng'] != null) {
                              lat = (m['lat'] as num).toDouble();
                              lng = (m['lng'] as num).toDouble();
                            } else if (m['latitude'] != null &&
                                m['longitude'] != null) {
                              lat = (m['latitude'] as num).toDouble();
                              lng = (m['longitude'] as num).toDouble();
                            }
                          }
                        } else if ((u as dynamic).hasLocation != null &&
                            (u as dynamic).hasLocation()) {
                          final loc = (u as dynamic).location as LatLng?;
                          if (loc != null) {
                            lat = loc.latitude;
                            lng = loc.longitude;
                          }
                        }
                        if (lat != null && lng != null) {
                          driverMaps.add({
                            'id': any.id,
                            'lat': lat,
                            'lng': lng,
                            'bearing': (data['bearing'] is num)
                                ? (data['bearing'] as num).toDouble()
                                : 0.0,
                          });
                        }
                      } catch (_) {}
                    }

                    return PickerMapNative(
                      userLocation: FFAppState().latlngAtual!,
                      destination: FFAppState().latlangAondeVaiIr,
                      googleApiKey: 'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ',
                      userPhotoUrl: currentUserPhoto,
                      userName: currentUserDisplayName,
                      userMarkerSize: 24,
                      drivers: driverMaps,
                      encodedPolyline: _encodedPolyline,
                      enableRouteSnake: true,
                      brandSafePaddingBottom: 90.0,
                      darkStyle: true,
                      // Ícones dos veículos no mapa (pode trocar por URLs http)
                      driverTaxiIconUrl:
                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
                      driverDriverIconUrl:
                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/bgmclb0d2bsd/ChatGPT_Image_3_de_set._de_2025%2C_19_17_48.png',
                    );
                  },
                ),
              ),
            ),
            // ======= Your original beautiful UI below stays intact =======
            // (Unchanged except the chip list gets nicer animations.)
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xB517181D), Color(0x0717181D)],
                      stops: [0, 1],
                      begin: AlignmentDirectional(0, -1),
                      end: AlignmentDirectional(0, 1),
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: SizedBox(
                          width: 50, height: 50,
                          child: SpinKitDoubleBounce(color: FlutterFlowTheme.of(context).accent1, size: 50),
                        ));
                      }
                      final drivers = snapshot.data!;
                      // Best effort mapping: expects fields 'driverLat' & 'driverLng' or 'lastLatLng' (FlutterFlow LatLng JSON).
                      List<Map<String, dynamic>> driverMaps = [];
                      for (final u in drivers) {
                        try {
                          double? lat; double? lng;
                          // Try common field names – adjust to your schema
                          final any = u.reference; // keep id
                          if (u.hasLocation() && u.location != null) {
                            lat = u.location!.latitude;
                            lng = u.location!.longitude;
                          } else if (u.snapshotData.containsKey('driverLat') && u.snapshotData['driverLat'] != null &&
                              u.snapshotData.containsKey('driverLng') && u.snapshotData['driverLng'] != null) {
                            lat = (u.snapshotData['driverLat'] as num).toDouble();
                            lng = (u.snapshotData['driverLng'] as num).toDouble();
                          } else if (u.snapshotData.containsKey('lastLatLng')) {
                            final m = u.snapshotData['lastLatLng'];
                            if (m is Map && m['lat'] != null && m['lng'] != null) {
                              lat = (m['lat'] as num).toDouble();
                              lng = (m['lng'] as num).toDouble();
                            }
                          }
                          if (lat != null && lng != null) {
                            driverMaps.add({
                              'id': any.id,
                              'lat': lat,
                              'lng': lng,
                              'bearing': (u.snapshotData['bearing'] is num)
                                  ? (u.snapshotData['bearing'] as num).toDouble()
                                  : 0.0,
                            });
                          }
                        } catch (_) {}
                      }

                      return PickerMapNative(
                        userLocation: FFAppState().latlngAtual!,
                        destination: FFAppState().latlangAondeVaiIr,
                        googleApiKey: 'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ',
                        userPhotoUrl: currentUserPhoto,
                        userName: currentUserDisplayName,
                        userMarkerSize: 40,
                        drivers: driverMaps,
                        encodedPolyline: _encodedPolyline,
                        enableRouteSnake: true,
                        brandSafePaddingBottom: 90.0,
                        darkStyle: true,
                      );
                    },
                  ),
<<<<<<< HEAD
                ),
              ),
              // ======= Your original beautiful UI below stays intact =======
              // (Unchanged except the chip list gets nicer animations.)
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xB517181D), Color(0x0717181D)],
                        stops: [0, 1],
                        begin: AlignmentDirectional(0, -1),
                        end: AlignmentDirectional(0, 1),
                      ),
                    ),
                    child: Align(
                      alignment: const AlignmentDirectional(0, 0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 14, 0, 0),
                        child: _HeaderBar(),
                      ),
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                    ),
                  ),
                  const Spacer(flex: 10),
                  Align(
                    alignment: const AlignmentDirectional(0, 1),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (FFAppState().latlangAondeVaiIr != null)
                          _BottomCard(encoded: _encodedPolyline),
                      ],
                    ),
=======
                  child: Align(
                    alignment: const AlignmentDirectional(0, 0),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 14, 0, 0),
                      child: _HeaderBar(),
                    ),
                  ),
                ),
                const Spacer(flex: 10),
                Align(
                  alignment: const AlignmentDirectional(0, 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (FFAppState().latlangAondeVaiIr != null)
                        _BottomCard(model: _model, encoded: _encodedPolyline),
<<<<<<< HEAD
                    ],
>>>>>>> 10c9b5c (new frkdfm)
                  ),
                  wrapWithModel(
                    model: _model.navbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const NavbarWidget(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  // --- Extracted widgets from your original code for brevity + minor polish ---
  class _HeaderBar extends StatelessWidget {
    const _HeaderBar();

    @override
    Widget build(BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 35, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    _UserAvatar(),
                    const SizedBox(width: 10),
                    _Greeting(),
                  ],
                ),
<<<<<<< HEAD
                _MenuButton(),
=======
                wrapWithModel(
                  model: _model.navbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const NavbarWidget(),
                ),
>>>>>>> 10c9b5c (new frkdfm)
              ],
            ),
          ),
          _WhereTo(),
          _NearbyChips(), // Animated version
        ],
      );
    }
  }

  class _UserAvatar extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryText,
          boxShadow: const [BoxShadow(blurRadius: 4, color: Color(0x33000000), offset: Offset(0, 2))],
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AuthUserStreamWidget(
            builder: (context) => Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Image.network(currentUserPhoto, fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }
  }

  class _Greeting extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FFAppState().fraseInicial,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              color: const Color(0xFF696C6F),
              fontSize: 12,
            ),
          ),
          AuthUserStreamWidget(
            builder: (context) => Text(
              currentUserDisplayName,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                color: FlutterFlowTheme.of(context).alternate,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }
  }

  class _MenuButton extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Stack(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryText,
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black, offset: Offset(5, 0))],
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            boxShadow: const [BoxShadow(blurRadius: 6, color: Color(0x48FFFFFF), offset: Offset(-2, -1))],
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.menu, color: FlutterFlowTheme.of(context).secondaryBackground, size: 18),
        ),
      ]);
    }
  }

  class _WhereTo extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Stack(
        alignment: const AlignmentDirectional(0, -1),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () async {
                await showModalBottomSheet(
                  isScrollControlled: true, backgroundColor: Colors.transparent, enableDrag: false, context: context,
                  builder: (context) => Padding(
                    padding: MediaQuery.viewInsetsOf(context),
                    child: const SelectLocationWidget(escolha: 'textfield'),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.9,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 0, 8),
                      child: Text(
                        FFAppState().locationWhereTo,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.poppins(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(1, -1),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
              child: Container(
                width: 48, height: 18,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text('3 min',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    color: FlutterFlowTheme.of(context).tertiary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  class _NearbyChips extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      final pertos = FFAppState().locationsPorPerto.toList();
      return Align(
        alignment: const AlignmentDirectional(-1, -1),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(17, 6, 12, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < pertos.length; i++)
                  _ChipItem(text: pertos[i])
                      .animate(delay: (50 * i).ms) // stagger
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.1, end: 0, curve: Curves.easeOutBack)
                      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1,1), duration: 220.ms),
              ].divide(const SizedBox(width: 8)),
            ),
          ),
        ),
      );
    }
  }

  class _ChipItem extends StatelessWidget {
    const _ChipItem({required this.text});
    final String text;
    @override
    Widget build(BuildContext context) {
      final selected = FFAppState().listPerto == text;
      return InkWell(
        splashColor: Colors.transparent,
        onTap: () async {
          if (selected) {
            FFAppState().latlangAondeVaiIr = null;
            FFAppState().listPerto = '';
            FFAppState().locationWhereTo = 'Where to?';
          } else {
            final geo = await actions.geocodeAddress(context, 'YOUR_GOOGLE_API_KEY', text);
            FFAppState().latlangAondeVaiIr = functions.formatStringToLantLng(
              getJsonField(geo, r'$.lat').toString(),
              getJsonField(geo, r'$.lng').toString(),
            );
            FFAppState().listPerto = text;
            FFAppState().locationWhereTo = text;
          }
        },
        child: AnimatedContainer(
          duration: 180.ms,
          curve: Curves.easeOut,
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? FlutterFlowTheme.of(context).accent1 : FlutterFlowTheme.of(context).primary,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.poppins(),
              color: const Color(0xFF585858),
              fontSize: 10,
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 800.ms, color: selected ? Colors.white10 : Colors.transparent),
      );
    }
  }

  // Bottom booking card is your original code (trimmed for brevity); keep as-is in your project.
  class _BottomCard extends StatelessWidget {
    const _BottomCard({this.encoded});
    final String? encoded;
    @override
    Widget build(BuildContext context) {
      // Keep your original detailed widget here; using placeholder to keep the file size small.
      return SizedBox.shrink();
    }
  }
<<<<<<< HEAD
=======
}

// --- Extracted widgets from your original code for brevity + minor polish ---
class _HeaderBar extends StatelessWidget {
  const _HeaderBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 35, 18, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  _UserAvatar(),
                  const SizedBox(width: 10),
                  _Greeting(),
                ],
              ),
              _MenuButton(),
            ],
          ),
        ),
        _WhereTo(),
        _NearbyChips(), // Animated version
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryText,
        boxShadow: const [
          BoxShadow(
              blurRadius: 8, color: Color(0x22000000), offset: Offset(0, 3))
        ],
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AuthUserStreamWidget(
          builder: (context) => Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Image.network(currentUserPhoto, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FFAppState().fraseInicial,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                color: const Color(0xFF696C6F),
                fontSize: 12,
              ),
        ),
        AuthUserStreamWidget(
          builder: (context) => Text(
            currentUserDisplayName,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  color: FlutterFlowTheme.of(context).alternate,
                  fontSize: 16,
                ),
          ),
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
            BoxShadow(
                blurRadius: 6, color: Color(0x48FFFFFF), offset: Offset(-2, -1))
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.menu,
            color: FlutterFlowTheme.of(context).secondaryBackground, size: 18),
      ),
    ]);
  }
}

class _WhereTo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
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
                builder: (context) => Padding(
                  padding: MediaQuery.viewInsetsOf(context),
                  child: const SelectLocationWidget(escolha: 'textfield'),
                ),
              );
            },
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.9,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 0, 8),
                    child: Text(
                      FFAppState().locationWhereTo,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                  ),
                ),
              ]),
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
              alignment: Alignment.center,
              child: Text(
                '3 min',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      color: FlutterFlowTheme.of(context).tertiary,
                      fontSize: 10,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NearbyChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // listen for realtime changes in FFAppState
    context.watch<FFAppState>();
    final pertos = FFAppState().locationsPorPerto.toList();
    return Align(
      alignment: const AlignmentDirectional(-1, -1),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(17, 6, 12, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < pertos.length; i++)
                _ChipItem(text: pertos[i])
                    .animate(delay: (50 * i).ms) // stagger
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.1, end: 0, curve: Curves.easeOutBack)
                    .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: 220.ms),
            ].divide(const SizedBox(width: 8)),
          ),
        ),
      ),
    );
  }
}

class _ChipItem extends StatelessWidget {
  const _ChipItem({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final selected = FFAppState().listPerto == text;
    return _GradientChip(
      text: text,
      selected: selected,
      onTap: () async {
        if (selected) {
          FFAppState().update(() {
            FFAppState().latlangAondeVaiIr = null;
            FFAppState().listPerto = '';
            FFAppState().locationWhereTo = 'Where to?';
          });
        } else {
          // Usa lat/lng direto do Nearby (evita geocode e evita null)
          final map = FFAppState().locationsPorPertoMap;
          final ll = map[text];
          if (ll != null) {
            FFAppState().update(() {
              FFAppState().latlangAondeVaiIr = ll;
              FFAppState().listPerto = text;
              FFAppState().locationWhereTo = text;
            });
          } else {
            // fallback: tenta geocode se não achar no mapa
            final geo = await actions.geocodeAddress(
                context, 'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ', text);
            final lat = getJsonField(geo, r'$.lat');
            final lng = getJsonField(geo, r'$.lng');
            if (lat != null && lng != null) {
              FFAppState().update(() {
                FFAppState().latlangAondeVaiIr =
                    LatLng((lat as num).toDouble(), (lng as num).toDouble());
                FFAppState().listPerto = text;
                FFAppState().locationWhereTo = text;
              });
            }
          }
        }
      },
    )
        .animate()
        .fadeIn(duration: 220.ms)
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1));
  }
}

class _GradientChip extends StatefulWidget {
  const _GradientChip(
      {required this.text, required this.selected, required this.onTap});
  final String text;
  final bool selected;
  final Future<void> Function() onTap;
  @override
  State<_GradientChip> createState() => _GradientChipState();
}

class _GradientChipState extends State<_GradientChip> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final gradient = const LinearGradient(
      colors: [Color(0xFFFFC107), Color(0xFFFF7A00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final bg = selected || _pressed
        ? BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(999),
          )
        : BoxDecoration(
            color: FlutterFlowTheme.of(context).primary,
            borderRadius: BorderRadius.circular(999),
          );
    final txtColor = selected || _pressed
        ? const Color(0xFF1E1E1E)
        : const Color(0xFF585858);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        borderRadius: BorderRadius.circular(999),
        splashColor: Colors.white.withOpacity(0.08),
        highlightColor: Colors.transparent,
        onTap: () async {
          setState(() => _pressed = false);
          await widget.onTap();
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: bg,
          child: Text(
            widget.text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.poppins(),
                  color: txtColor,
                  fontSize: 10,
                ),
          ),
        ),
      ),
    );
  }
}

class _BottomCard extends StatefulWidget {
  const _BottomCard({required this.model, this.encoded});
  final Home5Model model;
  final String? encoded;
  @override
  State<_BottomCard> createState() => _BottomCardState();
}

class _BottomCardState extends State<_BottomCard> {
  bool hasContainerTriggered2 = false;
  bool hasContainerTriggered3 = false;
  bool hasContainerTriggered4 = false;
  bool hasContainerTriggered5 = false;
  bool hasContainerTriggered6 = false;
  bool hasContainerTriggered7 = false;

  LatLng? currentUserLocationValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 28),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.86,
        height: 182,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF333333),
              FlutterFlowTheme.of(context).primary
            ],
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
                          FFLocalizations.of(context)
                              .getText('ybwe42qc' /* Ride Estimative */),
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
                            final list = snapshot.data!;
                            return GradientText(
                              formatNumber(
                                functions.mediaCorridaNesseKm(
                                  FFAppState().latlngAtual!,
                                  FFAppState().latlangAondeVaiIr!,
                                  list.toList(),
                                ),
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
                                const Color(0xFFF2E6D5)
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
                          FFLocalizations.of(context)
                              .getText('76w8fz75' /* Time */),
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
                          functions.estimativeTime(
                            FFAppState().latlngAtual!,
                            FFAppState().latlangAondeVaiIr!,
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
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GradientText(
                            valueOrDefault<String>(
                              functions.latlngForKm(
                                FFAppState().latlngAtual!,
                                FFAppState().latlangAondeVaiIr!,
                              ),
                              '2.4 Km',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  color: FlutterFlowTheme.of(context).secondary,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                            colors: [
                              FlutterFlowTheme.of(context).accent1,
                              FlutterFlowTheme.of(context).secondary,
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
                            final picked = await showDatePicker(
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
                            setState(() {
                              if (picked != null) {
                                widget.model.datePicked = DateTime(
                                    picked.year, picked.month, picked.day);
                              } else if (widget.model.datePicked != null) {
                                widget.model.datePicked = getCurrentTimestamp;
                              }
                            });
                          },
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).alternate,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  4, 0, 4, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.date_range,
                                    color: Color(0xC2414141),
                                    size: 14,
                                  ),
                                  Text(
                                    widget.model.datePicked != null
                                        ? dateTimeFormat(
                                            "yMd",
                                            widget.model.datePicked,
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
                                          color: const Color(0xC2242424),
                                          fontSize: 8,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ].map((w) => w).toList(),
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
                            setState(() {
                              if (FFAppState().passangers == 8) {
                                FFAppState().passangers = 1;
                              } else {
                                FFAppState().passangers =
                                    FFAppState().passangers + 1;
                              }
                            });
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
                                const Icon(
                                  Icons.person_outline,
                                  color: Color(0xC2414141),
                                  size: 14,
                                ),
                                Text(
                                  '${valueOrDefault<String>(FFAppState().passangers.toString(), '1')} passengers',
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
                                        color: const Color(0xC2242424),
                                        fontSize: 8,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                          .map((w) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: w))
                          .toList(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _rideTypeButton('ride', 'Ride', '3 min'),
                      _rideTypeButton('xl', 'XL', '6 min'),
                      _rideTypeButton('luxury', 'Luxury', '10 min'),
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
                            defaultLocation: const LatLng(0.0, 0.0));
                        context.pushNamed(
                          PaymentRide7Widget.routeName,
                          queryParameters: {
                            'estilo': serializeParam(
                                widget.model.rideChoose, ParamType.String),
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
                            kTransitionInfoKey: const TransitionInfo(
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
                          FFLocalizations.of(context)
                              .getText('iv1ii278' /* Confirm Ride   */),
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
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(
                          RideShare6Widget.routeName,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
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
                          FFLocalizations.of(context)
                              .getText('nzvn5ujp' /* Ride Share */),
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
                    ),
                  ],
=======
                    ],
                  ),
                ),
                wrapWithModel(
                  model: _model.navbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const NavbarWidget(),
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                ),
              ].divide(const SizedBox(height: 5)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rideTypeButton(String keyVal, String title, String eta) {
    final selected = widget.model.rideChoose == keyVal;
    final colors = selected
        ? [const Color(0xFFF4B000), const Color(0xFFEE8B05)]
        : [
            FlutterFlowTheme.of(context).primaryText,
            FlutterFlowTheme.of(context).primaryText,
          ];
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        setState(() => widget.model.rideChoose = keyVal);
      },
      child: Container(
        width: 70,
        height: 35,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
                blurRadius: 4, color: Color(0x33000000), offset: Offset(0, 2)),
          ],
          gradient: LinearGradient(
            colors: colors,
            stops: const [0, 1],
            begin: const AlignmentDirectional(0.03, -1),
            end: const AlignmentDirectional(-0.03, 1),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).alternate,
                      fontSize: 8,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
              Text(
                eta,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 8,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======

// --- Extracted widgets from your original code for brevity + minor polish ---
class _HeaderBar extends StatelessWidget {
  const _HeaderBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 35, 18, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  _UserAvatar(),
                  const SizedBox(width: 10),
                  _Greeting(),
                ],
              ),
              _MenuButton(),
            ],
          ),
        ),
        _WhereTo(),
        _NearbyChips(), // Animated version
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryText,
        boxShadow: const [
          BoxShadow(
              blurRadius: 8, color: Color(0x22000000), offset: Offset(0, 3))
        ],
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AuthUserStreamWidget(
          builder: (context) => Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Image.network(currentUserPhoto, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FFAppState().fraseInicial,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                color: const Color(0xFF696C6F),
                fontSize: 12,
              ),
        ),
        AuthUserStreamWidget(
          builder: (context) => Text(
            currentUserDisplayName,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  color: FlutterFlowTheme.of(context).alternate,
                  fontSize: 16,
                ),
          ),
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
            BoxShadow(
                blurRadius: 6, color: Color(0x48FFFFFF), offset: Offset(-2, -1))
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.menu,
            color: FlutterFlowTheme.of(context).secondaryBackground, size: 18),
      ),
    ]);
  }
}

class _WhereTo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
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
                builder: (context) => Padding(
                  padding: MediaQuery.viewInsetsOf(context),
                  child: const SelectLocationWidget(escolha: 'textfield'),
                ),
              );
            },
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.9,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 0, 8),
                    child: Text(
                      FFAppState().locationWhereTo,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                  ),
                ),
              ]),
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
              alignment: Alignment.center,
              child: Text(
                '3 min',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      color: FlutterFlowTheme.of(context).tertiary,
                      fontSize: 10,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NearbyChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // listen for realtime changes in FFAppState
    context.watch<FFAppState>();
    final pertos = FFAppState().locationsPorPerto.toList();
    return Align(
      alignment: const AlignmentDirectional(-1, -1),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(17, 6, 12, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < pertos.length; i++)
                _ChipItem(text: pertos[i])
                    .animate(delay: (50 * i).ms) // stagger
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.1, end: 0, curve: Curves.easeOutBack)
                    .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: 220.ms),
            ].divide(const SizedBox(width: 8)),
          ),
        ),
      ),
    );
  }
}

class _ChipItem extends StatelessWidget {
  const _ChipItem({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final selected = FFAppState().listPerto == text;
    return _GradientChip(
      text: text,
      selected: selected,
      onTap: () async {
        if (selected) {
          FFAppState().update(() {
            FFAppState().latlangAondeVaiIr = null;
            FFAppState().listPerto = '';
            FFAppState().locationWhereTo = 'Where to?';
          });
        } else {
          // Usa lat/lng direto do Nearby (evita geocode e evita null)
          final map = FFAppState().locationsPorPertoMap;
          final ll = map[text];
          if (ll != null) {
            FFAppState().update(() {
              FFAppState().latlangAondeVaiIr = ll;
              FFAppState().listPerto = text;
              FFAppState().locationWhereTo = text;
            });
          } else {
            // fallback: tenta geocode se não achar no mapa
            final geo = await actions.geocodeAddress(
                context, 'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ', text);
            final lat = getJsonField(geo, r'$.lat');
            final lng = getJsonField(geo, r'$.lng');
            if (lat != null && lng != null) {
              FFAppState().update(() {
                FFAppState().latlangAondeVaiIr =
                    LatLng((lat as num).toDouble(), (lng as num).toDouble());
                FFAppState().listPerto = text;
                FFAppState().locationWhereTo = text;
              });
            }
          }
        }
      },
    )
        .animate()
        .fadeIn(duration: 220.ms)
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1));
  }
}

class _GradientChip extends StatefulWidget {
  const _GradientChip(
      {required this.text, required this.selected, required this.onTap});
  final String text;
  final bool selected;
  final Future<void> Function() onTap;
  @override
  State<_GradientChip> createState() => _GradientChipState();
}

class _GradientChipState extends State<_GradientChip> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final gradient = const LinearGradient(
      colors: [Color(0xFFFFC107), Color(0xFFFF7A00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final bg = selected || _pressed
        ? BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(999),
          )
        : BoxDecoration(
            color: FlutterFlowTheme.of(context).primary,
            borderRadius: BorderRadius.circular(999),
          );
    final txtColor = selected || _pressed
        ? const Color(0xFF1E1E1E)
        : const Color(0xFF585858);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        borderRadius: BorderRadius.circular(999),
        splashColor: Colors.white.withOpacity(0.08),
        highlightColor: Colors.transparent,
        onTap: () async {
          setState(() => _pressed = false);
          await widget.onTap();
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: bg,
          child: Text(
            widget.text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.poppins(),
                  color: txtColor,
                  fontSize: 10,
                ),
          ),
        ),
      ),
    );
  }
}

class _BottomCard extends StatefulWidget {
  const _BottomCard({required this.model, this.encoded});
  final Home5Model model;
  final String? encoded;
  @override
  State<_BottomCard> createState() => _BottomCardState();
}

class _BottomCardState extends State<_BottomCard> {
  bool hasContainerTriggered2 = false;
  bool hasContainerTriggered3 = false;
  bool hasContainerTriggered4 = false;
  bool hasContainerTriggered5 = false;
  bool hasContainerTriggered6 = false;
  bool hasContainerTriggered7 = false;

  LatLng? currentUserLocationValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 28),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.86,
        height: 182,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF333333),
              FlutterFlowTheme.of(context).primary
            ],
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
                          FFLocalizations.of(context)
                              .getText('ybwe42qc' /* Ride Estimative */),
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
                            final list = snapshot.data!;
                            return GradientText(
                              formatNumber(
                                functions.mediaCorridaNesseKm(
                                  FFAppState().latlngAtual!,
                                  FFAppState().latlangAondeVaiIr!,
                                  list.toList(),
                                ),
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
                                const Color(0xFFF2E6D5)
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
                          FFLocalizations.of(context)
                              .getText('76w8fz75' /* Time */),
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
                          functions.estimativeTime(
                            FFAppState().latlngAtual!,
                            FFAppState().latlangAondeVaiIr!,
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
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GradientText(
                            valueOrDefault<String>(
                              functions.latlngForKm(
                                FFAppState().latlngAtual!,
                                FFAppState().latlangAondeVaiIr!,
                              ),
                              '2.4 Km',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  color: FlutterFlowTheme.of(context).secondary,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                            colors: [
                              FlutterFlowTheme.of(context).accent1,
                              FlutterFlowTheme.of(context).secondary,
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
                            final picked = await showDatePicker(
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
                            setState(() {
                              if (picked != null) {
                                widget.model.datePicked = DateTime(
                                    picked.year, picked.month, picked.day);
                              } else if (widget.model.datePicked != null) {
                                widget.model.datePicked = getCurrentTimestamp;
                              }
                            });
                          },
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).alternate,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  4, 0, 4, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.date_range,
                                    color: Color(0xC2414141),
                                    size: 14,
                                  ),
                                  Text(
                                    widget.model.datePicked != null
                                        ? dateTimeFormat(
                                            "yMd",
                                            widget.model.datePicked,
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
                                          color: const Color(0xC2242424),
                                          fontSize: 8,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ].map((w) => w).toList(),
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
                            setState(() {
                              if (FFAppState().passangers == 8) {
                                FFAppState().passangers = 1;
                              } else {
                                FFAppState().passangers =
                                    FFAppState().passangers + 1;
                              }
                            });
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
                                const Icon(
                                  Icons.person_outline,
                                  color: Color(0xC2414141),
                                  size: 14,
                                ),
                                Text(
                                  '${valueOrDefault<String>(FFAppState().passangers.toString(), '1')} passengers',
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
                                        color: const Color(0xC2242424),
                                        fontSize: 8,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                          .map((w) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: w))
                          .toList(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _rideTypeButton('ride', 'Ride', '3 min'),
                      _rideTypeButton('xl', 'XL', '6 min'),
                      _rideTypeButton('luxury', 'Luxury', '10 min'),
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
                            defaultLocation: const LatLng(0.0, 0.0));
                        context.pushNamed(
                          PaymentRide7Widget.routeName,
                          queryParameters: {
                            'estilo': serializeParam(
                                widget.model.rideChoose, ParamType.String),
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
                            kTransitionInfoKey: const TransitionInfo(
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
                          FFLocalizations.of(context)
                              .getText('iv1ii278' /* Confirm Ride   */),
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
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(
                          RideShare6Widget.routeName,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
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
                          FFLocalizations.of(context)
                              .getText('nzvn5ujp' /* Ride Share */),
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
                    ),
                  ],
                ),
              ].divide(const SizedBox(height: 5)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rideTypeButton(String keyVal, String title, String eta) {
    final selected = widget.model.rideChoose == keyVal;
    final colors = selected
        ? [const Color(0xFFF4B000), const Color(0xFFEE8B05)]
        : [
            FlutterFlowTheme.of(context).primaryText,
            FlutterFlowTheme.of(context).primaryText,
          ];
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        setState(() => widget.model.rideChoose = keyVal);
      },
      child: Container(
        width: 70,
        height: 35,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
                blurRadius: 4, color: Color(0x33000000), offset: Offset(0, 2)),
          ],
          gradient: LinearGradient(
            colors: colors,
            stops: const [0, 1],
            begin: const AlignmentDirectional(0.03, -1),
            end: const AlignmentDirectional(-0.03, 1),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).alternate,
                      fontSize: 8,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
              Text(
                eta,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 8,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
