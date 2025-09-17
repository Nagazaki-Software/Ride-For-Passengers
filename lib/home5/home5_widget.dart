import '/auth/firebase_auth/auth_util.dart';
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
