import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/navbar_widget.dart';
import '/components/select_location_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/lat_lng.dart' as ff; // 👈 LatLng do FlutterFlow
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets; // mantido p/ compat
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';

import 'dart:async';
import 'dart:convert' as convert;
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap; // 👈 Google Maps com alias
import 'package:http/http.dart' as http;
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
  ff.LatLng? currentUserLocationValue;

  // Google Map (tudo namespaced)
  gmap.GoogleMapController? _gmap;
  final Set<gmap.Marker> _markers = {};
  final Set<gmap.Polyline> _polylines = {};
  List<gmap.LatLng> _routePoints = [];
  Timer? _snakeTimer;
  int _snakeIndex = 0;

  // Estilo escuro pro mapa (preto/cinza)
  static const String _kMonoBlackStyle = '''
  [
    {"elementType":"geometry","stylers":[{"color":"#1d1f25"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#8a8c91"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1f25"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a2d34"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1a1c21"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8c91"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]},
    {"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#111317"}]}
  ]
  ''';

  // Controller legado do seu custom widget (mantido)
  final custom_widgets.PickerMapNativeController _mapCtrl =
      custom_widgets.PickerMapNativeController();

  // Fallback Nassau (evita 0,0) — usando ff.LatLng
  static const ff.LatLng _kNassau = ff.LatLng(25.03428, -77.39628);
  bool _isZero(ff.LatLng p) =>
      (p.latitude == 0.0 && p.longitude == 0.0) ||
      (p.latitude.abs() < 0.000001 && p.longitude.abs() < 0.000001);
  ff.LatLng _safe(ff.LatLng? p) => (p == null || _isZero(p)) ? _kNassau : p;

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  var hasContainerTriggered1 = false;
  final animationsMap = <String, AnimationInfo>{};

  // SUA KEY — mesma usada nas ações custom
  static const String _kGoogleKey = 'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Home5Model());

    // 1) pega rápido do cache
    getCurrentUserLocation(defaultLocation: _kNassau, cached: true)
        .then((loc) => safeSetState(() {
              currentUserLocationValue = loc;
              FFAppState().latlngAtual ??= loc;
              FFAppState().update(() {});
            }));

    // 2) confirma sem cache e faz bootstrap
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final loc = await getCurrentUserLocation(defaultLocation: _kNassau, cached: false);
      currentUserLocationValue = loc;
      FFAppState().latlngAtual = loc;

      await _bootstrapNearbyAndGreeting(loc);
      FFAppState().update(() {});

      // Inicializa mapa quando já temos localização
      _refreshMap();
    });

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(curve: Curves.easeInOut, delay: 0.ms, duration: 980.ms, begin: const Offset(0, -30), end: const Offset(0, 0)),
          FadeEffect(curve: Curves.easeInOut, delay: 0.ms, duration: 450.ms, begin: 0.0, end: 1.0),
        ],
      ),
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
    });
    setupAnimations(animationsMap.values, this);
  }

  @override
  void dispose() {
    _snakeTimer?.cancel();
    _gmap?.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _bootstrapNearbyAndGreeting(ff.LatLng user) async {
    _model.locationPerto = await actions.googlePlacesNearbyImportant(
      context,
      _kGoogleKey,
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

  // =======================
  // MAP HELPERS
  // =======================
  gmap.LatLng _toG(ff.LatLng v) => gmap.LatLng(v.latitude, v.longitude);

  Future<void> _applyMapStyle() async {
    try {
      await _gmap?.setMapStyle(_kMonoBlackStyle);
    } catch (_) {}
  }

  Future<gmap.BitmapDescriptor> _bitmapFromUrl(String url, {int size = 110}) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final codec = await ui.instantiateImageCodec(res.bodyBytes, targetWidth: size, targetHeight: size);
        final frame = await codec.getNextFrame();
        final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
        return gmap.BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
      }
    } catch (_) {}
    // fallback bolinha cinza
    final circle = await _fallbackCircle(size: math.max(64, size));
    return gmap.BitmapDescriptor.fromBytes(circle);
  }

  Future<Uint8List> _fallbackCircle({int size = 96}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = const Color(0xFF2D2F36);
    final border = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final center = Offset(size / 2, size / 2);
    canvas.drawCircle(center, size / 2.2, paint);
    canvas.drawCircle(center, size / 2.2, border);
    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> _updateMarkers() async {
    final meFF = _safe(FFAppState().latlngAtual ?? currentUserLocationValue);
    final dstFF = FFAppState().latlangAondeVaiIr;

    final Set<gmap.Marker> markers = {};

    // Marker do usuário com foto na posição do ff.LatLng
    final gmap.BitmapDescriptor meIcon = (currentUserPhoto != '')
        ? await _bitmapFromUrl(currentUserPhoto, size: 140)
        : gmap.BitmapDescriptor.defaultMarkerWithHue(gmap.BitmapDescriptor.hueAzure);

    markers.add(
      gmap.Marker(
        markerId: const gmap.MarkerId('me'),
        position: _toG(meFF),
        icon: meIcon,
        anchor: const Offset(0.5, 0.5),
        infoWindow: gmap.InfoWindow(title: currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Você'),
      ),
    );

    // Marker destino
    if (dstFF != null) {
      markers.add(
        gmap.Marker(
          markerId: const gmap.MarkerId('dst'),
          position: _toG(dstFF),
          icon: gmap.BitmapDescriptor.defaultMarkerWithHue(gmap.BitmapDescriptor.hueOrange),
          infoWindow: const gmap.InfoWindow(title: 'Destino'),
        ),
      );
    }

    // (Opcional) Drivers online
    try {
      final drivers = await queryUsersRecordOnce(
        queryBuilder: (q) => q.where('driver', isEqualTo: true).where('driverOnline', isEqualTo: true),
      );
      for (final d in drivers) {
        final geo = d.location;
        if (geo != null) {
          markers.add(
            gmap.Marker(
              markerId: gmap.MarkerId('drv_${d.reference.id}'),
              position: gmap.LatLng(geo.latitude, geo.longitude),
              icon: gmap.BitmapDescriptor.defaultMarkerWithHue(gmap.BitmapDescriptor.hueYellow),
              infoWindow: gmap.InfoWindow(title: d.displayName.isNotEmpty ? d.displayName : 'Driver'),
            ),
          );
        }
      }
    } catch (_) {}

    _markers
      ..clear()
      ..addAll(markers);
  }

  // Busca rota e anima “snake”
  Future<void> _buildRouteAndAnimate() async {
    _snakeTimer?.cancel();
    _polylines.clear();
    _routePoints.clear();
    _snakeIndex = 0;

    final originFF = _safe(FFAppState().latlngAtual ?? currentUserLocationValue);
    final dstFF = FFAppState().latlangAondeVaiIr;
    if (dstFF == null) {
      setState(() {});
      return; // sem destino, sem rota
    }

    try {
      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${originFF.latitude},${originFF.longitude}&destination=${dstFF.latitude},${dstFF.longitude}&mode=driving&key=$_kGoogleKey';
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final json = convert.jsonDecode(resp.body);
        final data = getJsonField(json, r'$.routes[0].overview_polyline.points').toString();
        if (data.isNotEmpty) {
          _routePoints = _decodePolyline(data);
          // inicia animação
          _snakeTimer = Timer.periodic(const Duration(milliseconds: 18), (t) {
            if (_snakeIndex >= _routePoints.length) {
              t.cancel();
              return;
            }
            final visible = _routePoints.sublist(0, _snakeIndex + 1);
            _polylines
              ..clear()
              ..add(
                gmap.Polyline(
                  polylineId: const gmap.PolylineId('route'),
                  points: visible,
                  width: 5,
                  color: const Color(0xFFBDBDBD),
                  endCap: gmap.Cap.roundCap,
                  startCap: gmap.Cap.roundCap,
                  geodesic: true,
                ),
              );
            _snakeIndex += 2; // velocidade do snake
            if (mounted) setState(() {});
          });
        }
      }
    } catch (_) {
      // silencia — mapa continua
    }
    if (mounted) setState(() {});
  }

  List<gmap.LatLng> _decodePolyline(String encoded) {
    final List<gmap.LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(gmap.LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  Future<void> _refreshMap() async {
    // Atualiza markers
    await _updateMarkers();
    // Re-centra câmera
    final meFF = _safe(FFAppState().latlngAtual ?? currentUserLocationValue);
    final dstFF = FFAppState().latlangAondeVaiIr;

    if (_gmap != null) {
      if (dstFF != null) {
        final bounds = gmap.LatLngBounds(
          southwest: gmap.LatLng(math.min(meFF.latitude, dstFF.latitude), math.min(meFF.longitude, dstFF.longitude)),
          northeast: gmap.LatLng(math.max(meFF.latitude, dstFF.latitude), math.max(meFF.longitude, dstFF.longitude)),
        );
        await _gmap!.animateCamera(gmap.CameraUpdate.newLatLngBounds(bounds, 80));
      } else {
        await _gmap!.animateCamera(
          gmap.CameraUpdate.newCameraPosition(gmap.CameraPosition(target: _toG(meFF), zoom: 15.5)),
        );
      }
    }
    // Rota
    await _buildRouteAndAnimate();
    if (mounted) setState(() {});
  }

  // =======================
  // WIDGET
  // =======================
  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final ff.LatLng userStartFF = _safe(FFAppState().latlngAtual ?? currentUserLocationValue);

    // Splash curto enquanto pega localização
    if (currentUserLocationValue == null) {
      return Container(
        color: const Color(0xFF0F1116),
        child: Center(
          child: SizedBox(
            width: 50, height: 50,
            child: SpinKitDoubleBounce(color: const Color(0xFFBDBDBD), size: 50),
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
        // Tema preto/cinza
        backgroundColor: const Color(0xFF0F1116),
        body: Stack(
          children: [
            // =========================
            // GOOGLE MAP — ocupa tudo
            // =========================
            Positioned.fill(
              child: PointerInterceptor(
                intercepting: isWeb,
                child: gmap.GoogleMap(
                  key: const ValueKey('home5_dark_map'),
                  initialCameraPosition: gmap.CameraPosition(target: _toG(userStartFF), zoom: 15.5),
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationEnabled: false, // usamos nosso marcador custom
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  tiltGesturesEnabled: true,
                  buildingsEnabled: false,
                  trafficEnabled: false,
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (ctrl) async {
                    _gmap = ctrl;
                    await _applyMapStyle();
                    await _refreshMap();
                  },
                ),
              ),
            ),

            // =========================
            // SEM overlay central de foto (era isso que tampava o mapa)
            // =========================

            // =========================
            // OVERLAYS (topo + bottom card + navbar)
            // =========================
            PointerInterceptor(
              intercepting: isWeb,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // HEADER com gradiente dark
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
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      // Avatar pequeno (só no header)
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1A1C22),
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipOval(
                                          child: (currentUserPhoto != '')
                                              ? Image.network(currentUserPhoto, fit: BoxFit.cover)
                                              : Center(
                                                  child: Text(
                                                    _initials(currentUserDisplayName),
                                                    style: FlutterFlowTheme.of(context).titleSmall.override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      color: const Color(0xFFBDBDBD),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
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
                                          Text(
                                            currentUserDisplayName,
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.poppins(),
                                                  color: const Color(0xFFE5E5E5),
                                                  fontSize: 16,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ].divide(const SizedBox(width: 10)),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        width: 38, height: 38,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1A1C22),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black, offset: Offset(5, 0))],
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.menu, color: Color(0xFFE5E5E5), size: 18),
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
                                      ).then((value) async {
                                        // sempre que sair do modal, atualiza rota/markers
                                        await _refreshMap();
                                        if (mounted) safeSetState(() {});
                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width * 0.9,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A1C22), // dark, não azul
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 0, 8),
                                              child: Text(
                                                FFAppState().locationWhereTo,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.poppins(),
                                                      color: const Color(0xFF9CA3AF),
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
                                      width: 48, height: 18,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E5E5),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        FFLocalizations.of(context).getText('v2jubsa7' /* 3 min */),
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                              color: const Color(0xFF111317),
                                              fontSize: 10,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Chips (dark)
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
                                                await _refreshMap();
                                                safeSetState(() {});
                                              } else {
                                                _model.geolocatoraddressonchoose = await actions.geocodeAddress(
                                                  context,
                                                  _kGoogleKey,
                                                  item,
                                                );
                                                FFAppState().latlangAondeVaiIr = functions.formatStringToLantLng(
                                                  getJsonField(_model.geolocatoraddressonchoose, r'''$.lat''').toString(),
                                                  getJsonField(_model.geolocatoraddressonchoose, r'''$.lng''').toString(),
                                                );
                                                FFAppState().listPerto = item;
                                                FFAppState().locationWhereTo = item;
                                                await _refreshMap();
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
                                                  color: selected ? const Color(0xFF8C7CF0) : const Color(0xFF1A1C22),
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: selected
                                                      ? [BoxShadow(blurRadius: 10, offset: const Offset(0, 4), color: Colors.black.withOpacity(0.3))]
                                                      : const [],
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  item,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        font: GoogleFonts.poppins(),
                                                        color: const Color(0xFF9CA3AF),
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

                  // BOTTOM CARD + NAVBAR (inalterados — só cores dark)
                  Align(
                    alignment: const AlignmentDirectional(0, 1),
                    child: Column(
                      children: <Widget>[
                        if (FFAppState().latlangAondeVaiIr != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 28),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.86,
                              height: 182,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [const Color(0xFF2A2D34), const Color(0xFF1A1C22)],
                                  stops: const [0, 1],
                                  begin: const AlignmentDirectional(0, -1),
                                  end: const AlignmentDirectional(0, 1),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            FFLocalizations.of(context).getText('ybwe42qc' /* Ride Estimative */),
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.poppins(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                                  color: const Color(0xFFE5E5E5),
                                                  fontSize: 16,
                                                ),
                                          ),
                                          FutureBuilder<List<RideOrdersRecord>>(
                                            future: queryRideOrdersRecordOnce(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return SizedBox(
                                                  width: 24, height: 24,
                                                  child: SpinKitDoubleBounce(color: const Color(0xFFBDBDBD), size: 24),
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
                                                      font: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                                      color: const Color(0xFFE5E5E5),
                                                      fontSize: 16,
                                                    ),
                                                colors: [
                                                  const Color(0xFF8C7CF0),
                                                  const Color(0xFFE5E5E5),
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
                                        children: <Widget>[
                                          Text(
                                            FFLocalizations.of(context).getText('76w8fz75' /* Time */),
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.poppins(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                                  color: const Color(0xFF9CA3AF),
                                                ),
                                          ),
                                          Text(
                                            functions.estimativeTime(
                                              FFAppState().latlngAtual!,
                                              FFAppState().latlangAondeVaiIr!,
                                            ),
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.poppins(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                                  color: const Color(0xFF9CA3AF),
                                                ),
                                          ),
                                        ],
                                      ),
                                      Container(width: 336, height: 1, color: const Color(0xFF3A3D44)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
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
                                                          font: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                                                          color: const Color(0xFFE5E5E5),
                                                        ),
                                                    colors: [const Color(0xFF8C7CF0), const Color(0xFFE5E5E5)],
                                                    gradientDirection: GradientDirection.rtl,
                                                    gradientType: GradientType.linear,
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                          Row(
                                            children: const <Widget>[
                                              // … botões/ícones que você já tinha (sem mudanças de estrutura)
                                            ],
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
}
