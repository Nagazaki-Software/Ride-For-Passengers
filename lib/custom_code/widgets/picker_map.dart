// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:characters/characters.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

import '/flutter_flow/lat_lng.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_native_sdk/google_maps_native_sdk.dart' as nmap;
import 'icon_global_cache.dart';

class PickerMap extends StatefulWidget {
  const PickerMap({
    Key? key,
    this.width,
    this.height,
    required this.userLocation,
    this.userName,
    this.userPhotoUrl,
    this.destination,
    this.driversRefs,
    this.googleApiKey,

    // Tweaks
    this.refreshMs = 8000,
    this.traceThrottleMs = 90,
    this.routeColor = const Color(0xFFFFC107),
    this.routeWidth = 8,
    this.liveTraceColor = const Color(0xFF00E5FF),
    this.liveTraceWidth = 4,
    this.userMarkerSize = 128,
    this.driverIconWidth = 152,

    // Ãcones
    this.driverDriverIconUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/bgmclb0d2bsd/ChatGPT_Image_3_de_set._de_2025%2C_19_17_48.png',
    this.driverTaxiIconUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
    this.markerDestinationIconUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png', // <â€”â€” novo: destino dedicado

    this.borderRadius = 16,
    this.brandSafePaddingBottom = 0,
    this.fadeInMs = 420,
    this.enableRouteSnake = true,
    this.snakeDurationMsOverride, // se quiser forÃ§ar (ms)
    this.snakeSpeedFactor = 1.0,
    this.driverTweenMs = 320,
    this.ultraLowSpecMode = false,
    this.traceMinStepMeters = 1.5,
  }) : super(key: key);

  final double? width;
  final double? height;
  final LatLng userLocation;
  final String? userName;
  final String? userPhotoUrl;
  final LatLng? destination;
  final List<DocumentReference>? driversRefs;
  final String? googleApiKey;

  final int refreshMs;

  final Color routeColor;
  final int routeWidth;
  final int userMarkerSize;
  final int driverIconWidth;

  final String? driverDriverIconUrl; // usado p/ driver
  final String? driverTaxiIconUrl; // usado p/ driver
  final String? markerDestinationIconUrl; // <â€”â€” usado p/ destino

  final double borderRadius;
  final double brandSafePaddingBottom;

  final bool enableRouteSnake;
  final int? snakeDurationMsOverride;
  final double
      snakeSpeedFactor; // 1.0 = esperto; <1 mais rÃ¡pido; >1 mais lento
  final int driverTweenMs;

  final bool ultraLowSpecMode;

  final int liveTraceWidth;
  final Color liveTraceColor;
  final int traceThrottleMs;
  final double traceMinStepMeters;

  final int fadeInMs;

  @override
  State<PickerMap> createState() => _PickerMapState();
}

class _PickerMapState extends State<PickerMap>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  nmap.GoogleMapController? _controller;
  bool _mapReady = false;

  final Set<String> _markerIds = <String>{};
  final Set<String> _polylineIds = <String>{};

  bool _veilVisible = true;

  final Map<String, nmap.LatLng> _markerPos = {};
  final Map<String, String?> _markerTitle = {};

  final Map<String, StreamSubscription<DocumentSnapshot>> _subs = {};
  final Map<String, nmap.LatLng> _driverPos = {};
  final Map<String, _TweenRunner> _driverTween = {};
  final Map<String, double> _driverRot = {};

  final Map<String, Future<Uint8List?>> _iconInFlight = {};
  static final Map<String, Uint8List> _iconMemCache = {};
  static final Uint8List _transparentPixel = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=');

  final Map<String, List<nmap.LatLng>> _driverTrace = {};
  final Map<String, int> _lastTraceUpdateMs = {};

  // Cache de rotas simples (origem|destino) para evitar recomputo frequente.
  static final Map<String, List<nmap.LatLng>> _routeCache =
      <String, List<nmap.LatLng>>{};

  List<nmap.LatLng> _route = <nmap.LatLng>[];
  List<double> _cumDist = <double>[];
  double _totalDist = 0.0;

  // Snake
  late final Ticker _ticker;
  bool _snaking = false;
  double _snakeT = 0.0;
  int _snakeDurationMs = 9000; // mais rÃ¡pido por padrÃ£o
  int _lastCamUpdateMs = 0;

  // Idle camera quando destination == null
  Timer? _idleCamTimer;
  double _idleBearing = 0;

  // IDs de polylines
  static const String _kBaseOutline = 'route_base_outline';
  static const String _kBaseMain = 'route_base_main';
  static const String _kSnakeOutline = 'route_snake_outline';
  static const String _kSnakeMain = 'route_snake_main';

  final Map<String, bool> _polylineCanInplaceUpdate = {};

  static const String _darkMapStyle =
      '[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#2b2b2b"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1e1e1e"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f2f2f"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}]';

  nmap.LatLng _gm(LatLng p) => nmap.LatLng(p.latitude, p.longitude);

  double get _adaptiveSnakePadding {
    final double dist = _totalDist;
    if (dist <= 0) {
      return 80.0;
    }
    if (dist < 800) {
      return 100.0;
    }
    if (dist < 2500) {
      return 120.0;
    }
    if (dist < 8000) {
      return 140.0;
    }
    if (dist < 16000) {
      return 160.0;
    }
    return 180.0;
  }

  int _boostedDriverIconSize({bool forDestination = false}) {
    final double base = widget.driverIconWidth.toDouble().clamp(64.0, 208.0);
    final double factor = forDestination ? 1.22 : 1.12;
    final double scaled = base * factor;
    final double minSize = forDestination ? 84.0 : 72.0;
    final double maxSize = forDestination ? 224.0 : 208.0;
    return scaled.clamp(minSize, maxSize).round();
  }

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((elapsed) async {
      if (!_snaking || !_mapReady || _controller == null || _totalDist <= 0)
        return;

      // velocidade do snake
      final int dur = (widget.snakeDurationMsOverride ??
              _autoDurationMs(_totalDist, factor: widget.snakeSpeedFactor))
          .clamp(6000, 14000); // rÃ¡pido/esperto
      _snakeDurationMs = dur;

      final double raw = (elapsed.inMilliseconds / dur).clamp(0.0, 1.0);
      // easing suave
      _snakeT = raw <= 0.5
          ? 4 * raw * raw * raw
          : 1 - math.pow(-2 * raw + 2, 3) / 2.0;

      final double headDist = _totalDist * _snakeT;
      final int k = _indexAtDistance(headDist);
      final nmap.LatLng headPos = _posAt(headDist);
      final List<nmap.LatLng> vis = (k > 0)
          ? (List<nmap.LatLng>.from(_route.getRange(0, k))..add(headPos))
          : <nmap.LatLng>[_route.first, headPos];

      // Contorno preto embaixo + amarelo por cima
      final double mainW = widget.routeWidth.toDouble().clamp(6.0, 20.0);
      final double outlineW = (mainW + 8.0).clamp(mainW + 6.0, mainW + 16.0);

      await _updatePolyline(
        id: _kSnakeOutline,
        points: vis,
        width: outlineW,
        color: const Color(0xFF0A0A0A),
        geodesic: true,
      );
      await _updatePolyline(
        id: _kSnakeMain,
        points: vis,
        width: mainW,
        color: widget.routeColor,
        geodesic: true,
      );

      // Follow de cÃ¢mera mais amplo
      final int now = DateTime.now().millisecondsSinceEpoch;
      if (false) {
        _lastCamUpdateMs = now;
        final nmap.LatLng ref = _posAt((headDist - 120).clamp(0.0, _totalDist));
        final double br = _bearing(ref, headPos);
        try {
          final dynamic dc = _controller;
          await dc.animateCameraTo(
            target: headPos,
            zoom: _zoomForDistance(_totalDist),
            bearing: br,
            tilt: 54.0,
            durationMs: 240,
          );
        } catch (_) {}
      }

      if (raw >= 1.0) {
        _snaking = false;
        _ticker.stop();

        // Fixa rota inteira (base)
        await _updatePolyline(
          id: _kBaseOutline,
          points: _route,
          width: (widget.routeWidth + 8).toDouble(),
          color: const Color(0xFF0A0A0A),
          geodesic: true,
        );
        await _updatePolyline(
          id: _kBaseMain,
          points: _route,
          width: widget.routeWidth.toDouble(),
          color: widget.routeColor.withOpacity(.98),
          geodesic: true,
        );
        await _fadeOutPolylines(base: false, snake: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant PickerMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If any marker icon URLs changed, try to refresh markers (will no-op if map not ready)
    if (oldWidget.markerDestinationIconUrl != widget.markerDestinationIconUrl ||
        oldWidget.driverDriverIconUrl != widget.driverDriverIconUrl ||
        oldWidget.driverTaxiIconUrl != widget.driverTaxiIconUrl) {
      // attempt async update but don't await here
      SchedulerBinding.instance
          .addPostFrameCallback((_) => _placeCoreMarkers());
    }

    // Mudou o destino? alterna modos e (re)planeja
    if (oldWidget.destination == null && widget.destination != null) {
      // came from no-destination -> plan route
      _stopIdleCam();
      _prepareRoute().then((_) => _startSnake());
    } else if (oldWidget.destination != null && widget.destination == null) {
      // went to no-destination -> clear immediately, then cinematic return
      _snaking = false;
      _stopIdleCam();
      _returnToUserCinematic();
    } else if (oldWidget.destination != null &&
        widget.destination != null &&
        (oldWidget.destination!.latitude != widget.destination!.latitude ||
            oldWidget.destination!.longitude !=
                widget.destination!.longitude)) {
      // destination changed to a different LatLng -> replan route
      _stopIdleCam();
      _prepareRoute().then((_) => _startSnake());
    } else {
      // no significant change to destination: update markers and optionally snap
      _placeCoreMarkers();
      if (widget.destination == null) _snapToUser();
    }
  }

  @override
  void dispose() {
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
    for (final t in _driverTween.values) {
      t.dispose();
    }
    _driverTween.clear();
    _ticker.dispose();
    _stopIdleCam();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final double w = widget.width ?? double.infinity;
    final double h = widget.height ?? 320.0;

    final nmap.CameraPosition initialCamera = nmap.CameraPosition(
      target: nmap.LatLng(
          widget.userLocation.latitude, widget.userLocation.longitude),
      zoom: widget.destination == null ? 15.6 : 12.8,
    );

    return SizedBox(
      width: w,
      height: h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
            nmap.GoogleMapView(
              key: const ValueKey('PickerMapNative'),
              initialCameraPosition: initialCamera,
              myLocationEnabled: false,
              trafficEnabled: false,
              buildingsEnabled: false,
              mapStyleJson: _darkMapStyle,
              padding: nmap.MapPadding(bottom: widget.brandSafePaddingBottom),
              onMapCreated: (nmap.GoogleMapController c) async {
                _controller = c;
                try {
                  await c.onMapLoaded;
                } catch (_) {}
                _mapReady = true;

                // micro-nudge removido para evitar cortes visuais
                try {
                  final dynamic dc = _controller;
                  await dc.animateCameraBy(dx: 0.0, dy: 0.0);
                } catch (_) {}

                SchedulerBinding.instance.addPostFrameCallback((_) async {
                  await _placeCoreMarkers(); // cria jÃ¡ com Ã­cone (sem vermelho)
                  _subscribeDrivers();

                  if (widget.destination != null) {
                    await _prepareRoute();
                    _startSnake();
                  } else {
                    _snapToUser();
                  }
                  if (mounted) setState(() => _veilVisible = false);
                });
              },
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: AbsorbPointer(
                  absorbing: true,
                  child: const SizedBox(width: 96.0, height: 60.0)),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _veilVisible ? 1.0 : 0.0,
                duration: Duration(milliseconds: widget.fadeInMs),
                curve: Curves.easeOutCubic,
                child: const ColoredBox(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Idle camera / Snap para usuÃ¡rio =====
  void _startIdleCam() {
    _stopIdleCam();
    if (!_mapReady || _controller == null) return;
    _idleCamTimer =
        Timer.periodic(const Duration(milliseconds: 1400), (_) async {
      if (!_mapReady ||
          _controller == null ||
          widget.destination != null ||
          _snaking) return;
      _idleBearing = (_idleBearing + 28) % 360;
      try {
        final dynamic dc = _controller;
        await dc.animateCameraTo(
          target: _gm(widget.userLocation),
          zoom: 16.5,
          bearing: _idleBearing,
          tilt: 58.0,
          durationMs: 650,
        );
      } catch (_) {}
    });
  }

  void _stopIdleCam() {
    _idleCamTimer?.cancel();
    _idleCamTimer = null;
  }

  Future<void> _snapToUser() async {
    if (!_mapReady || _controller == null) return;
    final nmap.LatLng user = _targetForUserWithPadding(17.2);
    try {
      final dynamic dc = _controller;
      await dc.animateCameraTo(
        target: user,
        zoom: 17.2,
        bearing: 0.0,
        tilt: 58.0,
        durationMs: 420,
      );
    } catch (_) {
      try {
        await _controller?.moveCamera(user, zoom: 17.2);
      } catch (_) {}
    }
  }

  // Limpa rota e polylines
  Future<void> _clearRoute() async {
    _snaking = false;
    _snakeT = 0.0;
    try {
      _ticker.stop();
    } catch (_) {}
    _route = <nmap.LatLng>[];
    _cumDist = <double>[];
    _totalDist = 0.0;
    for (final id in [_kBaseOutline, _kBaseMain, _kSnakeOutline, _kSnakeMain]) {
      await _removePolyline(id);
    }
    // ForÃ§a um "redraw" do mapa com micro-nudge para garantir remoÃ§Ã£o visual
    try {
      final dynamic dc = _controller;
      await dc.animateCameraBy(dx: 0.0, dy: 0.0);
      await Future<void>.delayed(const Duration(milliseconds: 24));
      await dc.animateCameraBy(dx: 0.0, dy: 0.0);
    } catch (_) {}
  }

  Future<void> _removeDestMarker() async {
    if (_markerIds.contains('dest')) {
      try {
        await _controller?.removeMarker('dest');
      } catch (_) {}
      _markerIds.remove('dest');
      _markerPos.remove('dest');
      _markerTitle.remove('dest');
    }
  }

  Future<void> _fadeOutPolylines(
      {bool base = false, bool snake = false}) async {
    if (_controller == null) return;
    final bool hasBaseMain =
        base && _polylineIds.contains(_kBaseMain) && _route.length >= 2;
    final bool hasBaseOutline =
        base && _polylineIds.contains(_kBaseOutline) && _route.length >= 2;
    final bool hasSnakeMain =
        snake && _polylineIds.contains(_kSnakeMain) && _route.length >= 2;
    final bool hasSnakeOutline =
        snake && _polylineIds.contains(_kSnakeOutline) && _route.length >= 2;

    if (!(hasBaseMain || hasBaseOutline || hasSnakeMain || hasSnakeOutline)) {
      if (snake) {
        if (_polylineIds.contains(_kSnakeMain)) {
          await _removePolyline(_kSnakeMain);
        }
        if (_polylineIds.contains(_kSnakeOutline)) {
          await _removePolyline(_kSnakeOutline);
        }
      }
      if (base) {
        if (_polylineIds.contains(_kBaseMain)) {
          await _removePolyline(_kBaseMain);
        }
        if (_polylineIds.contains(_kBaseOutline)) {
          await _removePolyline(_kBaseOutline);
        }
      }
      return;
    }

    final List<nmap.LatLng> pts = List<nmap.LatLng>.from(_route);
    const int steps = 5;
    for (int i = 1; i <= steps; i++) {
      final double t = i / steps;
      final double fade = math.pow(1.0 - t, 1.2).toDouble();
      final double widthFactor = math.max(0.18, 1.0 - (0.65 * t));
      final double mainWidth =
          math.max(2.2, widget.routeWidth.toDouble() * widthFactor);
      final double outlineWidth = math.max(
        mainWidth + 2.0,
        (widget.routeWidth + 8).toDouble() * widthFactor,
      );

      if (hasBaseOutline) {
        await _updatePolyline(
          id: _kBaseOutline,
          points: pts,
          width: outlineWidth,
          color: const Color(0xFF0A0A0A).withOpacity(0.85 * fade),
          geodesic: true,
        );
      }
      if (hasBaseMain) {
        await _updatePolyline(
          id: _kBaseMain,
          points: pts,
          width: mainWidth,
          color: widget.routeColor.withOpacity(0.92 * fade),
          geodesic: true,
        );
      }
      if (hasSnakeOutline) {
        await _updatePolyline(
          id: _kSnakeOutline,
          points: pts,
          width: outlineWidth,
          color: const Color(0xFF0A0A0A).withOpacity(0.68 * fade),
          geodesic: true,
        );
      }
      if (hasSnakeMain) {
        await _updatePolyline(
          id: _kSnakeMain,
          points: pts,
          width: mainWidth,
          color: widget.routeColor.withOpacity(0.78 * fade),
          geodesic: true,
        );
      }

      await Future<void>.delayed(const Duration(milliseconds: 36));
    }

    if (hasBaseMain) {
      await _removePolyline(_kBaseMain);
    }
    if (hasBaseOutline) {
      await _removePolyline(_kBaseOutline);
    }
    if (hasSnakeMain) {
      await _removePolyline(_kSnakeMain);
    }
    if (hasSnakeOutline) {
      await _removePolyline(_kSnakeOutline);
    }
  }

  // ===== Volta cinematogrÃ¡fica quando destination == null =====
  Future<void> _returnToUserCinematic() async {
    _stopIdleCam();
    _snaking = false;
    try {
      _ticker.stop();
    } catch (_) {}
    final bool hadRoute = _route.length >= 2;
    final bool hadDest = _markerIds.contains('dest');
    final nmap.LatLng userCentered16 = _targetForUserWithPadding(16.1);
    final nmap.LatLng userCentered17 = _targetForUserWithPadding(17.2);

    // Remove destination marker early to prevent residual flash
    if (hadDest) {
      await _removeDestMarker();
    }

    // Small wide shot first (when there was a route), similar to when
    // destination is present, then fade lines away.
    if (hadRoute && _mapReady && _controller != null) {
      await _playCameraSequence(<_CameraMove>[
        _CameraMove(
          target: userCentered16,
          zoom: 16.1,
          bearing: (_idleBearing + 12) % 360,
          tilt: 50.0,
          durationMs: 520,
          pauseAfterMs: 60,
        ),
      ]);
    }

    await _fadeOutPolylines(base: true, snake: true);
    await _clearRoute();
    if (mounted) setState(() {});

    if (_mapReady && _controller != null) {
      await _playCameraSequence(<_CameraMove>[
        _CameraMove(
          target: userCentered16,
          zoom: 16.1,
          bearing: 6.0,
          tilt: 50.0,
          durationMs: 520,
          pauseAfterMs: 120,
        ),
        _CameraMove(
          target: userCentered17,
          zoom: 17.2,
          bearing: 0.0,
          tilt: 64.0,
          durationMs: 680,
        ),
      ]);
    } else {
      try {
        await _controller?.moveCamera(userCentered17, zoom: 17.0);
      } catch (_) {}
    }

    // (sem pulso/idle) mantemos apenas o retorno animado
  }

  Future<void> _pulseUserOnce() async {
    try {
      final int size = widget.userMarkerSize.clamp(48, 168);
      final Uint8List pulse = await _makeUserAvatarBytes(
        name: widget.userName ?? 'VocÃª',
        photoUrl: widget.userPhotoUrl,
        diameter: size,
      ).then((base) => _withPulseRing(base, size));

      final Uint8List normal = await _makeUserAvatarBytes(
        name: widget.userName ?? 'VocÃª',
        photoUrl: widget.userPhotoUrl,
        diameter: size,
      );

      final dynamic dc = _controller;
      await dc.setMarkerIconBytes(id: 'user', bytes: pulse);
      await Future<void>.delayed(const Duration(milliseconds: 360));
      await dc.setMarkerIconBytes(id: 'user', bytes: normal);
    } catch (_) {}
  }

  Future<Uint8List> _withPulseRing(Uint8List base, int size) async {
    final ui.Codec codec = await ui.instantiateImageCodec(base,
        targetWidth: size, targetHeight: size);
    final ui.Image img = (await codec.getNextFrame()).image;

    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    final s = size.toDouble();
    final center = ui.Offset(s / 2, s / 2);

    // glow
    c.drawCircle(
        center,
        s * 0.55,
        ui.Paint()
          ..color = widget.routeColor.withOpacity(.28)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 18));

    // base
    c.drawImageRect(
      img,
      ui.Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, s, s),
      ui.Paint(),
    );

    // anel
    c.drawCircle(
        center,
        s * 0.50,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = widget.routeColor.withOpacity(.95));

    final ui.Image out = await rec.endRecording().toImage(size, size);
    final ByteData? bytes =
        await out.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<Uint8List> _drawCirclePinPng({
    int size = 96,
    Color? color,
    double stroke = 4.0,
    Color? strokeColor,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    final double s = size.toDouble();
    final ui.Offset center = ui.Offset(s / 2, s / 2);
    final Color fill = (color ?? widget.routeColor).withOpacity(1.0);
    final Color border = stroke > 0
        ? (strokeColor ?? Colors.white.withOpacity(0.95))
        : Colors.transparent;

    // soft shadow to match existing markers
    canvas.drawCircle(
      center,
      s / 2.4,
      ui.Paint()
        ..color = Colors.black.withOpacity(0.20)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 12.0),
    );

    // filled circle pin
    canvas.drawCircle(center, s / 2.6, ui.Paint()..color = fill);

    if (stroke > 0) {
      canvas.drawCircle(
        center,
        s / 2.6 - stroke / 2,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = border,
      );
    }

    final ui.Image image = await recorder.endRecording().toImage(size, size);
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  // ================= MARKERS (sem pin vermelho) =================

  Future<void> _placeCoreMarkers() async {
    if (!_mapReady || _controller == null) return;

    final nmap.LatLng user = _gm(widget.userLocation);
    if (!_markerIds.contains('user')) {
      final Uint8List userBytes = await _makeUserAvatarBytes(
        name: widget.userName ?? 'VocÃª',
        photoUrl: widget.userPhotoUrl,
        diameter: widget.userMarkerSize.clamp(48, 168),
      );
      await _addOrUpdateMarker(
        id: 'user',
        position: user,
        title: widget.userName ?? 'VocÃª',
        anchorU: 0.5,
        anchorV: 0.5,
        zIndex: 30.0,
        bytesIcon: userBytes,
      );
    } else {
      try {
        await _controller!.updateMarker('user', position: user);
      } catch (_) {}
      _markerPos['user'] = user;
      _markerTitle['user'] = widget.userName ?? 'VocÃª';
    }

    if (widget.destination != null) {
      final nmap.LatLng dest = _gm(widget.destination!);
      if (!_markerIds.contains('dest')) {
        final int iconSize = _boostedDriverIconSize(forDestination: true);
        final String? prefUrl =
            ((widget.markerDestinationIconUrl ?? '').trim().isNotEmpty)
                ? widget.markerDestinationIconUrl
                : ((widget.driverTaxiIconUrl ?? '').trim().isNotEmpty)
                    ? widget.driverTaxiIconUrl
                    : ((widget.driverDriverIconUrl ?? '').trim().isNotEmpty)
                        ? widget.driverDriverIconUrl
                        : null;

        Uint8List? bytes;
        String? iconUrl;

        if (prefUrl != null) {
          final String? assetPath = _assetPathFromUrlOrName(prefUrl);
          if (assetPath != null) {
            bytes = await _tryLoadAssetPng(prefUrl, iconSize);
            if (bytes != null) {
              iconUrl = _bytesToDataUrl(bytes);
            } else {
              iconUrl = 'asset://$assetPath';
            }
          }

          if (bytes == null && !_looksSvg(prefUrl)) {
            bytes = await _downloadAndResize(_massageUrl(prefUrl), iconSize);
            if (bytes != null) {
              iconUrl = _bytesToDataUrl(bytes);
            }
          }

          iconUrl ??= _normalizeIconUrl(prefUrl);
        }

        bytes ??= await _drawCirclePinPng(
            size: _boostedDriverIconSize(forDestination: true),
            color: widget.routeColor,
            stroke: 4.0);
        iconUrl ??= _bytesToDataUrl(bytes!);

        await _addOrUpdateMarker(
          id: 'dest',
          position: dest,
          title: 'Destino',
          anchorU: 0.5,
          anchorV: 0.5,
          zIndex: 25.0,
          bytesIcon: bytes,
          iconUrl: iconUrl,
        );
      } else {
        try {
          await _controller!.updateMarker('dest', position: dest);
        } catch (_) {}
        _markerPos['dest'] = dest;
        _markerTitle['dest'] = 'Destino';
      }
    } else {
      await _removeDestMarker();
    }
  }

  // ================= DRIVERS =================

  // Nova versÃ£o: adiciona marcador usando asset (se houver) e reforÃ§a com bytes para nitidez.
  Future<void> _addOrUpdateMarker({
    required String id,
    required nmap.LatLng position,
    String? title,
    required double anchorU,
    required double anchorV,
    required double zIndex,
    Uint8List? bytesIcon,
    String? iconUrl,
  }) async {
    if (_controller == null) return;

    final String? effectiveIconUrl =
        iconUrl ?? (bytesIcon != null ? _bytesToDataUrl(bytesIcon) : null);

    Uint8List? resolvedBytes = bytesIcon;
    String? resolvedIconUrl = effectiveIconUrl;
    if (resolvedBytes == null &&
        (resolvedIconUrl == null || resolvedIconUrl.isEmpty)) {
      resolvedBytes = _transparentPixel;
      resolvedIconUrl = _bytesToDataUrl(_transparentPixel);
    }

    if (_markerIds.contains(id)) {
      try {
        await _controller!.updateMarker(id, position: position);
      } catch (_) {}
    } else {
      try {
        await _controller!.addMarker(nmap.MarkerOptions(
          id: id,
          position: position,
          title: title,
          iconUrl: resolvedIconUrl,
          anchorU: anchorU,
          anchorV: anchorV,
          zIndex: zIndex,
        ));
        _markerIds.add(id);
      } catch (_) {
        return;
      }
    }

    _markerPos[id] = position;
    _markerTitle[id] = title;

    if (resolvedBytes != null) {
      try {
        final dynamic dc = _controller;
        await dc.setMarkerIconBytes(
          id: id,
          bytes: resolvedBytes,
          anchorU: anchorU,
          anchorV: anchorV,
        );
      } catch (_) {}
    }
  }

  void _subscribeDrivers() {
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
    for (final t in _driverTween.values) {
      t.dispose();
    }
    _driverTween.clear();
    final refs = widget.driversRefs;
    if (refs == null) return;

    for (final ref in refs) {
      final id = ref.id;
      _subs[id] = ref.snapshots().listen((snap) async {
        if (!mounted) return;

        if (!snap.exists) {
          if (_markerIds.contains('driver_$id')) {
            try {
              await _controller?.removeMarker('driver_$id');
            } catch (_) {}
            _markerIds.remove('driver_$id');
          }
          final tid = 'trace_$id';
          for (final pid in [tid, '${tid}_shadow']) {
            if (_polylineIds.contains(pid)) {
              try {
                await _controller?.removePolyline(pid);
              } catch (_) {}
              _polylineIds.remove(pid);
            }
          }
          _driverTrace.remove(tid);
          _driverPos.remove(id);
          _driverRot.remove(id);
          _driverTween.remove(id)?.dispose();
          _markerPos.remove('driver_$id');
          _markerTitle.remove('driver_$id');
          return;
        }

        final data = snap.data() as Map<String, dynamic>?;

        nmap.LatLng? p;
        final loc = data?['location'];
        if (loc is GeoPoint) {
          p = nmap.LatLng(loc.latitude, loc.longitude);
        } else {
          final lat = (data?['lat'] as num?)?.toDouble();
          final lng = (data?['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) p = nmap.LatLng(lat, lng);
        }
        if (p == null) return;

        final String title = (data?['display_name'] ??
                data?['name'] ??
                data?['driverName'] ??
                'Motorista')
            .toString();

        final _DriverVisualChoice visual = _resolveDriverVisual(data);
        String? rawUrl = _cleanUrl(visual.url);
        final bool forceBrandIcon = visual.forceBrandIcon;
        if (!forceBrandIcon) {
          rawUrl ??= _firstNonEmpty([
            data?['photoUrl'],
            data?['photo_url'],
            data?['avatar'],
            data?['avatar_url'],
            data?['image'],
          ]);
        }
        if (rawUrl == null || _looksSvg(rawUrl)) {
          rawUrl = _cleanUrl(visual.fallback);
        }
        rawUrl ??= _cleanUrl(visual.isTaxi
            ? widget.driverTaxiIconUrl
            : widget.driverDriverIconUrl);

        final last = _driverPos[id];
        if (last == null) {
          Uint8List? bytes;
          String? iconUrl;
          final int iconSize = _boostedDriverIconSize();
          if ((rawUrl ?? '').trim().isNotEmpty) {
            final String? assetPath = _assetPathFromUrlOrName(rawUrl);
            if (assetPath != null) {
              bytes = await _tryLoadAssetPng(rawUrl, iconSize);
              if (bytes != null) {
                iconUrl = _bytesToDataUrl(bytes);
              } else {
                iconUrl = 'asset://$assetPath';
              }
            }

            if (bytes == null && !_looksSvg(rawUrl)) {
              final Uint8List? fetched =
                  await _downloadAndResize(_massageUrl(rawUrl!), iconSize);
              if (fetched != null) {
                bytes = fetched;
                iconUrl = _bytesToDataUrl(fetched);
              }
            }

            iconUrl ??= _normalizeIconUrl(rawUrl);
          }

          if (forceBrandIcon) {
            if (bytes == null) {
              final String? fallbackUrl = _cleanUrl(visual.fallback) ?? rawUrl;
              if ((fallbackUrl ?? '').trim().isNotEmpty &&
                  fallbackUrl != rawUrl) {
                final String? assetPath = _assetPathFromUrlOrName(fallbackUrl);
                if (assetPath != null) {
                  bytes = await _tryLoadAssetPng(fallbackUrl, iconSize);
                  if (bytes != null) {
                    iconUrl = _bytesToDataUrl(bytes);
                  } else {
                    iconUrl = 'asset://$assetPath';
                  }
                }
                if (bytes == null && !_looksSvg(fallbackUrl)) {
                  final Uint8List? fetched = await _downloadAndResize(
                      _massageUrl(fallbackUrl!), iconSize);
                  if (fetched != null) {
                    bytes = fetched;
                    iconUrl = _bytesToDataUrl(fetched);
                  }
                }
                iconUrl ??= _normalizeIconUrl(fallbackUrl);
              }
            }
            iconUrl ??= _normalizeIconUrl(rawUrl);
          } else {
            bytes ??= await _initialsAvatarPng(
                name: title, size: _boostedDriverIconSize());
            iconUrl ??= _bytesToDataUrl(bytes);
          }

          await _addOrUpdateMarker(
            id: 'driver_$id',
            position: p,
            title: title,
            anchorU: 0.5,
            anchorV: 0.62,
            zIndex: 22.0,
            bytesIcon: bytes,
            iconUrl: iconUrl,
          );

          _driverPos[id] = p;
          _markerPos['driver_$id'] = p;
          _markerTitle['driver_$id'] = title;

          await _updateDriverTrace(id, p, force: true);
          return;
        }

        final double distMeters = _meters(last, p);
        if (distMeters < 0.5) {
          final double rot = _bearing(last, p);
          _driverPos[id] = p;
          _driverRot[id] = rot;
          try {
            await _controller?.updateMarker('driver_$id',
                position: p, rotation: rot);
          } catch (_) {}
          _markerPos['driver_$id'] = p;
          _markerTitle['driver_$id'] = title;
          await _updateDriverTrace(id, p);
          return;
        }

        _driverTween[id]?.dispose();
        final double brFrom = _driverRot[id] ?? _bearing(last, p);
        final double brTo = _bearing(last, p);
        final int baseDur = math.max(160, math.min(1600, widget.driverTweenMs));
        final int dynamicMs =
            math.min(baseDur + 1400, baseDur + (distMeters * 28).round());
        _driverTween[id] = _TweenRunner(
          from: last,
          to: p,
          durationMs: dynamicMs,
          curve: Curves.easeInOutCubic,
          vsync: this,
          onStep: (pos, t) async {
            _driverPos[id] = pos;
            final rot = _bearingLerp(brFrom, brTo, t);
            _driverRot[id] = rot;
            try {
              await _controller?.updateMarker('driver_$id',
                  position: pos, rotation: rot);
            } catch (_) {}
            _markerPos['driver_$id'] = pos;
            _markerTitle['driver_$id'] = title;
            await _updateDriverTrace(id, pos);
          },
        )..start();
      });
    }
  }

  String _driverTypeFromData(Map<String, dynamic>? data) {
    final _PlatformInfo info = _platformInfoFromData(data);
    if (info.isRideTaxi || info.hasTaxiKeyword) return 'taxi';
    return 'driver';
  }

  _DriverVisualChoice _resolveDriverVisual(Map<String, dynamic>? data) {
    final _PlatformInfo info = _platformInfoFromData(data);
    final Map<String, String> markerUrls = _markerUrlsFromData(data);
    final Map<String, dynamic>? usersMap =
        (data?['users'] is Map<String, dynamic>)
            ? (data?['users'] as Map<String, dynamic>?)
            : null;

    final String? driverFallback = _cleanUrl(widget.driverDriverIconUrl);
    final String? taxiFallback =
        _cleanUrl(widget.driverTaxiIconUrl) ?? driverFallback;

    if (info.isRideDriver) {
      return _DriverVisualChoice(
        url: driverFallback,
        fallback: driverFallback ?? taxiFallback,
        isTaxi: false,
        forceBrandIcon: true,
      );
    }

    if (info.isRideTaxi || info.hasTaxiKeyword) {
      String? url = _markerUrlForKeys(markerUrls, const <String>[
        'ride taxi',
        'ride_taxi',
        'taxi',
        'car',
        'vehicle',
      ]);
      url ??= _firstNonEmpty(<dynamic>[
        data?['markerUrl'],
        data?['marker_url'],
        usersMap?['markerUrl'],
        usersMap?['marker_url'],
        data?['vehiclePhoto'],
        data?['vehicle_photo'],
        data?['carPhoto'],
        data?['car_photo'],
        data?['photoVehicle'],
        data?['photo_vehicle'],
        data?['photoCar'],
        data?['photo_car'],
        data?['vehicleImage'],
        data?['vehicle_image'],
        data?['carImage'],
        data?['car_image'],
        usersMap?['vehiclePhoto'],
        usersMap?['carPhoto'],
      ]);
      return _DriverVisualChoice(
        url: url,
        fallback: taxiFallback ?? driverFallback,
        isTaxi: true,
        forceBrandIcon: info.isRideTaxi,
      );
    }

    String? url = _markerUrlForKeys(markerUrls, const <String>[
      'ride driver',
      'driver',
      'default',
      'principal',
      'main',
      'primary',
    ]);
    url ??= _firstNonEmpty(<dynamic>[
      data?['markerUrl'],
      data?['marker_url'],
      usersMap?['markerUrl'],
      usersMap?['marker_url'],
    ]);

    return _DriverVisualChoice(
      url: url,
      fallback: driverFallback ?? taxiFallback,
      isTaxi: false,
      forceBrandIcon: false,
    );
  }

  _PlatformInfo _platformInfoFromData(Map<String, dynamic>? data) {
    final Set<String> values = <String>{};
    void add(dynamic source) {
      if (source == null) return;
      if (source is String) {
        final String trimmed = source.trim();
        if (trimmed.isNotEmpty) values.add(trimmed);
      } else if (source is Iterable) {
        for (final dynamic item in source) {
          add(item);
        }
      }
    }

    if (data?['users'] is Map) {
      final Map users = data?['users'] as Map;
      add(users['plataform']);
      add(users['plataforms']);
      add(users['platform']);
      add(users['platforms']);
      add(users['type']);
    }
    add(data?['plataform']);
    add(data?['plataforms']);
    add(data?['platform']);
    add(data?['platforms']);
    add(data?['type']);

    return _PlatformInfo(values.toList());
  }

  Map<String, String> _markerUrlsFromData(Map<String, dynamic>? data) {
    final Map<String, String> result = <String, String>{};

    void absorb(String? key, dynamic value) {
      if (value == null) return;
      if (value is String) {
        final String trimmed = value.trim();
        if (trimmed.isEmpty) return;
        result[key ?? 'default'] = trimmed;
        return;
      }
      if (value is Iterable) {
        for (final dynamic item in value) {
          if (item is Map) {
            final dynamic innerKey = item['key'] ?? item['name'] ?? key;
            final dynamic innerValue =
                item['url'] ?? item['value'] ?? item['src'];
            if (innerKey != null || innerValue != null) {
              absorb(innerKey?.toString() ?? key, innerValue);
            } else {
              absorb(key, item);
            }
          } else {
            absorb(key, item);
          }
        }
        return;
      }
      if (value is Map) {
        if (value.containsKey('url') || value.containsKey('value')) {
          final dynamic innerKey = value['key'] ?? value['name'] ?? key;
          final dynamic innerValue = value['url'] ?? value['value'];
          absorb(innerKey?.toString() ?? key, innerValue);
          return;
        }
        value.forEach((dynamic k, dynamic v) {
          absorb(k?.toString(), v);
        });
      }
    }

    void readField(dynamic source) {
      if (source == null) return;
      if (source is Map) {
        source.forEach((dynamic k, dynamic v) {
          absorb(k?.toString(), v);
        });
      } else if (source is Iterable) {
        for (final dynamic item in source) {
          if (item is Map) {
            final dynamic innerKey = item['key'] ?? item['name'];
            final dynamic innerValue =
                item['url'] ?? item['value'] ?? item['src'];
            if (innerKey != null || innerValue != null) {
              absorb(innerKey?.toString(), innerValue);
            } else {
              absorb(null, item);
            }
          } else {
            absorb(null, item);
          }
        }
      } else if (source is String) {
        absorb(null, source);
      }
    }

    readField(data?['markersUrls']);
    readField(data?['markerUrls']);
    readField(data?['markers_url']);
    readField(data?['marker_url']);
    readField(data?['markers']);

    final dynamic users = data?['users'];
    if (users is Map<String, dynamic>) {
      readField(users['markersUrls']);
      readField(users['markerUrls']);
      readField(users['markers_url']);
      readField(users['marker_url']);
    }

    return result;
  }

  String? _markerUrlForKeys(Map<String, String> map, List<String> keys) {
    if (map.isEmpty) return null;
    String normalize(String value) =>
        value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    final Map<String, String> normalized = <String, String>{};
    map.forEach((String key, String value) {
      final String norm = normalize(key);
      if (norm.isNotEmpty && value.trim().isNotEmpty) {
        normalized[norm] = value.trim();
      }
    });
    for (final String key in keys) {
      final String normKey = normalize(key);
      final String? candidate = normalized[normKey];
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }
    return null;
  }

  String? _cleanUrl(String? url) {
    if (url == null) return null;
    final String trimmed = url.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _firstNonEmpty(Iterable<dynamic> values) {
    for (final dynamic value in values) {
      if (value == null) continue;
      if (value is String) {
        final String trimmed = value.trim();
        if (trimmed.isNotEmpty) return trimmed;
      } else if (value is num) {
        final String s = value.toString();
        if (s.isNotEmpty) return s;
      }
    }
    return null;
  }

  // ================= ROTA / LINHA =================

  Future<void> _prepareRoute() async {
    _snaking = false;
    _snakeT = 0.0;
    for (final id in [_kBaseOutline, _kBaseMain, _kSnakeOutline, _kSnakeMain]) {
      await _removePolyline(id);
    }
    _route = <nmap.LatLng>[];
    _cumDist = <double>[];
    _totalDist = 0.0;

    if (widget.destination == null || !_mapReady) return;

    final a = _gm(widget.userLocation);
    final b = _gm(widget.destination!);
    final String cacheKey =
        '${a.latitude.toStringAsFixed(6)},${a.longitude.toStringAsFixed(6)}|${b.latitude.toStringAsFixed(6)},${b.longitude.toStringAsFixed(6)}';
    final String apiKey = (widget.googleApiKey ?? '').trim();
    bool routed = false;

    // Tenta cache primeiro
    final cached = _routeCache[cacheKey];
    if (cached != null && cached.length >= 2) {
      _route = List<nmap.LatLng>.from(cached);
      routed = true;
    }

    if (apiKey.isNotEmpty) {
      try {
        final res = await nmap.RoutesApi.computeRoutes(
          apiKey: apiKey,
          origin: nmap.Waypoint(location: a),
          destination: nmap.Waypoint(location: b),
          languageCode: 'pt-BR',
          alternatives: false,
        );
        if (!routed && res.routes.isNotEmpty) {
          _route = res.routes.first.points
              .map((p) => nmap.LatLng(p.latitude, p.longitude))
              .toList();
          routed = _route.length >= 2;
        }
      } catch (_) {
        routed = false;
      }
    }

    if (!routed) {
      try {
        final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${a.latitude},${a.longitude}'
          '&destination=${b.latitude},${b.longitude}'
          '&mode=driving&language=pt-BR&key=$apiKey',
        );
        final resp = await http.get(uri);
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body) as Map<String, dynamic>;
          final routes = (data['routes'] as List?) ?? const [];
          final String? overview = (routes.isNotEmpty)
              ? (routes.first['overview_polyline']?['points']?.toString())
              : null;
          _route = (overview != null && overview.isNotEmpty)
              ? _decodePolyline(overview)
              : <nmap.LatLng>[a, b];
        } else {
          _route = <nmap.LatLng>[a, b];
        }
      } catch (_) {
        _route = <nmap.LatLng>[a, b];
      }
    }

    if (_route.length < 2) return;

    _route = _decimate(
      _route,
      minStepMeters: widget.ultraLowSpecMode ? 8.0 : 4.0,
      maxPoints: widget.ultraLowSpecMode ? 200 : 360,
    );

    _cumDist = List<double>.filled(_route.length, 0.0);
    double acc = 0.0;
    for (int i = 1; i < _route.length; i++) {
      acc += _meters(_route[i - 1], _route[i]);
      _cumDist[i] = acc;
    }
    _totalDist = acc;

    // Armazena no cache (LRU simples: limita 16 entradas)
    if (_route.length >= 2) {
      _routeCache[cacheKey] = List<nmap.LatLng>.from(_route);
      if (_routeCache.length > 16) {
        // Remove a primeira chave arbitrária (não estritamente LRU, mas suficiente)
        _routeCache.remove(_routeCache.keys.first);
      }
    }

    // Inicializa as camadas do snake
    final List<nmap.LatLng> start = <nmap.LatLng>[_route.first, _route.first];

    await _updatePolyline(
      id: _kSnakeOutline,
      points: start,
      width: (widget.routeWidth + 8).toDouble(),
      color: const Color(0xFF0A0A0A),
      geodesic: true,
    );
    await _updatePolyline(
      id: _kSnakeMain,
      points: start,
      width: widget.routeWidth.toDouble(),
      color: widget.routeColor,
      geodesic: true,
    );

    await _fitRouteBounds(padding: _adaptiveSnakePadding);
  }

  void _startSnake() async {
    if (!_mapReady || !mounted) return;
    if (!widget.enableRouteSnake || _route.length < 2) return;
    _snakeT = 0.0;
    _snaking = true;
    _ticker.stop();

    // Enquadra bem aberto e comeÃ§a
    await _fitRouteBounds(padding: _adaptiveSnakePadding);
    await Future<void>.delayed(const Duration(milliseconds: 220));
    _ticker.start();
  }

  Future<void> _animateFinal3DView() async {
    if (_controller == null || _route.length < 2) return;
    final nmap.LatLng start = _route.first;
    final nmap.LatLng end = _route.last;
    final nmap.LatLng midOne = _posAt(_totalDist * 0.45);
    final nmap.LatLng midTwo = _posAt(_totalDist * 0.78);
    final double baseZoom = _zoomForDistance(_totalDist);
    final double brStart = _bearing(start, midOne);
    final double brMid = _bearing(midOne, midTwo);
    final double brEnd = _bearing(_route[_route.length - 2], end);
    // Evita um "corte" brusco de enquadramento antes da sequência final.
    if (_controller == null) return;

    final List<_CameraMove> moves = <_CameraMove>[
      _CameraMove(
        target: midOne,
        zoom: math.max(11.8, baseZoom - 1.4),
        bearing: brStart,
        tilt: 44.0,
        durationMs: 560,
        pauseAfterMs: 140,
      ),
      _CameraMove(
        target: midTwo,
        zoom: math.min(18.0, baseZoom + 0.1),
        bearing: brMid,
        tilt: 58.0,
        durationMs: 640,
        pauseAfterMs: 140,
      ),
      _CameraMove(
        target: end,
        zoom: math.min(18.5, baseZoom + 0.7),
        bearing: brEnd,
        tilt: 66.0,
        durationMs: 780,
      ),
    ];

    await _playCameraSequence(moves);
  }

  // ================= ÃCONES / BYTES =================

  // URLs mais resilientes (gs://, firebasestorage, storage.googleapis.com, http->https, acentos/espacos)
  String _massageUrl(String url) {
    String s = url.trim();
    if (s.startsWith('http://')) s = 'https://${s.substring(7)}';

    // gs://bucket/obj -> firebasestorage + alt=media
    if (s.startsWith('gs://')) {
      final noGs = s.substring(5);
      final slash = noGs.indexOf('/');
      if (slash > 0) {
        final bucket = noGs.substring(0, slash);
        final path = noGs.substring(slash + 1);
        final encodedPath = Uri.encodeComponent(path);
        s = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
      }
    }

    // firebasestorage: garante alt=media (download direto)
    if (s.contains('firebasestorage.googleapis.com') &&
        !s.contains('alt=media')) {
      s += s.contains('?') ? '&alt=media' : '?alt=media';
    }

    // storage.googleapis.com (GCS path-style): apenas garante encoding â€œseguroâ€
    // evita double-encode se jÃ¡ tiver %
    if (s.contains('storage.googleapis.com') && !s.contains('%')) {
      try {
        // Reconstroi preservando query, codificando path
        final u = Uri.parse(s);
        final fixed = Uri(
          scheme: u.scheme.isEmpty ? 'https' : u.scheme,
          host: u.host,
          port: u.hasPort ? u.port : null,
          pathSegments: u.pathSegments.map(Uri.encodeComponent).toList(),
          query: u.query.isEmpty ? null : u.query,
        );
        s = fixed.toString();
      } catch (_) {
        // fallback leve
        s = Uri.encodeFull(s);
      }
    }

    return s;
  }

  String _bytesToDataUrl(Uint8List bytes) {
    final String b64 = base64Encode(bytes);
    return 'data:image/png;base64,$b64';
  }

  String? _normalizeIconUrl(String? raw) {
    final String? cleaned = _cleanUrl(raw);
    if (cleaned == null) return null;
    final String lower = cleaned.toLowerCase();
    if (lower.startsWith('data:') || lower.startsWith('asset://')) {
      return cleaned;
    }
    if (lower.startsWith('file://')) {
      return cleaned;
    }
    if (lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('gs://')) {
      return _massageUrl(cleaned);
    }
    if (cleaned.contains('://')) {
      return _massageUrl(cleaned);
    }
    final String? assetPath = _assetPathFromUrlOrName(cleaned);
    if (assetPath != null) {
      return 'asset://$assetPath';
    }
    return null;
  }

  // Tenta mapear uma URL ou nome para um asset local em assets/images/<basename>.png
  String? _assetPathFromUrlOrName(String? urlOrName) {
    final s = (urlOrName ?? '').trim();
    if (s.isEmpty) return null;
    try {
      final uri = Uri.parse(s);
      final seg = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : s;
      final decoded = Uri.decodeComponent(seg);
      final name = decoded.endsWith('.png') ? decoded : '$decoded.png';
      return 'assets/images/$name';
    } catch (_) {
      final base = s.endsWith('.png') ? s : '$s.png';
      return 'assets/images/$base';
    }
  }

  Future<Uint8List?> _tryLoadAssetPng(
      String? urlOrName, int targetWidthPx) async {
    final String? asset = _assetPathFromUrlOrName(urlOrName);
    if (asset == null) return null;
    try {
      final data = await rootBundle.load(asset);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: targetWidthPx,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image img = frame.image;
      final ByteData? out =
          await img.toByteData(format: ui.ImageByteFormat.png);
      return out?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  bool _looksSvg(String? url) {
    final u = (url ?? '').toLowerCase();
    return u.endsWith('.svg') || u.contains('image/svg');
  }

  Future<Uint8List?> _downloadAndResize(String? url, int targetWidthPx) async {
    final String clean = (url ?? '').trim();
    if (clean.isEmpty || _looksSvg(clean)) return null;
    // Global warmup cache first (url+size)
    final gHit = IconGlobalCache.get(clean, targetWidthPx);
    if (gHit != null) return gHit;
    final hit = _iconMemCache[clean];
    if (hit != null) return hit;
    if (_iconInFlight.containsKey(clean)) return await _iconInFlight[clean]!;
    Future<Uint8List?> task() async {
      try {
        final Uri uri = Uri.parse(_massageUrl(clean));
        final Map<String, String> baseHeaders = {
          'accept': 'image/*,*/*;q=0.8',
          'user-agent': 'PickerMap/1.0',
        };
        Future<http.Response> doGet([Map<String, String>? extra]) {
          final headers = Map<String, String>.from(baseHeaders);
          if (extra != null) headers.addAll(extra);
          return http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 8));
        }

        http.Response resp = await doGet();

        if ((resp.statusCode == 401 || resp.statusCode == 403) &&
            _looksFirebaseStorageUrl(uri.toString())) {
          final auth = await _authHeadersForFirebaseIfAny();
          if (auth.isNotEmpty) {
            resp = await doGet(auth);
          }
        }

        if (resp.statusCode < 200 || resp.statusCode >= 300) return null;
        final Uint8List bytes = resp.bodyBytes;
        final ui.Codec codec =
            await ui.instantiateImageCodec(bytes, targetWidth: targetWidthPx);
        final ui.FrameInfo frame = await codec.getNextFrame();
        final ui.Image img = frame.image;
        final ByteData? out =
            await img.toByteData(format: ui.ImageByteFormat.png);
        if (out == null) return null;
        final result = out.buffer.asUint8List();
        IconGlobalCache.put(clean, targetWidthPx, result);
        _iconMemCache[clean] = result;
        return result;
      } catch (_) {
        return null;
      }
    }

    final fut = task();
    _iconInFlight[clean] = fut;
    final res = await fut;
    _iconInFlight.remove(clean);
    return res;
  }

  bool _looksFirebaseStorageUrl(String s) {
    final u = s.toLowerCase();
    return u.contains('firebasestorage.googleapis.com') ||
        u.contains('storage.googleapis.com');
  }

  Future<Map<String, String>> _authHeadersForFirebaseIfAny() async {
    try {
      final user = fa.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String? token = await user.getIdToken();
        if ((token ?? '').isNotEmpty) {
          return {'Authorization': 'Bearer ${token!}'};
        }
      }
    } catch (_) {}
    return const {};
  }

  Future<Uint8List> _makeUserAvatarBytes({
    required String name,
    String? photoUrl,
    int diameter = 64,
  }) async {
    Uint8List? photo;
    if ((photoUrl ?? '').trim().isNotEmpty && !_looksSvg(photoUrl)) {
      photo = await _downloadAndResize(_massageUrl(photoUrl!), diameter);
    }
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final double s = diameter.toDouble();
    final center = ui.Offset(s / 2, s / 2);
    canvas.drawCircle(
        center,
        s * 0.50,
        ui.Paint()
          ..color = Colors.black.withOpacity(0.35)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8));
    final bg = ui.Paint()..color = const Color(0xFF30343C);
    canvas.drawCircle(center, s * 0.46, bg);
    if (photo != null) {
      final codec = await ui.instantiateImageCodec(photo,
          targetWidth: diameter, targetHeight: diameter);
      final frame = await codec.getNextFrame();
      final ui.Image img = frame.image;
      final rect = ui.Rect.fromCircle(center: center, radius: s * 0.46);
      canvas.save();
      canvas.clipPath(ui.Path()..addOval(rect));
      canvas.drawImageRect(
          img,
          ui.Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          rect,
          ui.Paint());
      canvas.restore();
    } else {
      final initials = _makeInitials(name);
      final textStyle = ui.TextStyle(
          fontSize: s * 0.38,
          color: Colors.white,
          fontWeight: ui.FontWeight.w700);
      final paragraphStyle = ui.ParagraphStyle(textAlign: TextAlign.center);
      final builder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText(initials);
      final paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: s));
      canvas.drawParagraph(
          paragraph, ui.Offset(0, center.dy - paragraph.height / 2));
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(diameter, diameter);
    final png = await img.toByteData(format: ui.ImageByteFormat.png);
    return png!.buffer.asUint8List();
  }

  Future<Uint8List> _initialsAvatarPng(
      {required String name, int size = 112}) async {
    final rec = ui.PictureRecorder();
    final canvas = ui.Canvas(rec);
    final r = size / 2.0;
    final bg = _colorFromString(name);
    canvas.drawCircle(ui.Offset(r, r), r, ui.Paint()..color = bg);
    canvas.drawCircle(
        ui.Offset(r, r),
        r - 3.0,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 6.0
          ..color = const Color(0xFFFFFFFF).withOpacity(.9));
    final initials = _nameToInitials(name);
    // Escolhe cor do texto com bom contraste
    final bool isBgBright = bg.computeLuminance() > 0.5;
    final Color textColor =
        isBgBright ? const Color(0xFF111111) : const Color(0xFFFFFFFF);

    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: size * 0.38,
          fontFamily: 'Roboto',
          fontWeight: ui.FontWeight.w700),
    )
      ..pushStyle(ui.TextStyle(color: textColor))
      ..addText(initials);
    final paragraph = pb.build()
      ..layout(ui.ParagraphConstraints(width: size.toDouble()));
    canvas.drawParagraph(paragraph, ui.Offset(0, r - paragraph.height / 2));
    final img = await rec.endRecording().toImage(size, size);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  String _nameToInitials(String name) {
    final parts = name.trim().split(RegExp(r"\s+")).where((s) => s.isNotEmpty);
    final s = parts.take(2).map((w) => w.characters.first.toUpperCase()).join();
    return s.isEmpty ? 'U' : s;
  }

  Color _colorFromString(String s) {
    int h = 0;
    for (final c in s.codeUnits) {
      h = 0x1f * h + c;
    }
    final hue = (h % 360).toDouble();
    return HSVColor.fromAHSV(1.0, hue, 0.55, 0.85).toColor();
  }

  // ================= TRACE (motoristas) =================

  Future<void> _updateDriverTrace(String id, nmap.LatLng p,
      {bool force = false}) async {
    final String tid = 'trace_$id';
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (!force) {
      final last = _lastTraceUpdateMs[id] ?? 0;
      if (now - last < widget.traceThrottleMs) return;
    }
    _lastTraceUpdateMs[id] = now;

    final List<nmap.LatLng> list = _driverTrace[tid] ?? <nmap.LatLng>[];
    if (list.isEmpty || _meters(list.last, p) > widget.traceMinStepMeters) {
      list.add(p);
      if (list.length > 900) list.removeAt(0);
      _driverTrace[tid] = list;

      await _updatePolyline(
        id: '${tid}_shadow',
        points: list,
        width: (widget.liveTraceWidth.toDouble() + 3.0).clamp(2.0, 18.0),
        color: Colors.black.withOpacity(.45),
        geodesic: true,
      );
      await _updatePolyline(
        id: tid,
        points: list,
        width: widget.liveTraceWidth.toDouble().clamp(2.0, 18.0),
        color: widget.liveTraceColor.withOpacity(0.95),
        geodesic: true,
      );
    }
  }

  Future<void> _playCameraSequence(List<_CameraMove> moves) async {
    if (_controller == null || moves.isEmpty) return;
    final dynamic dc = _controller;
    for (final _CameraMove move in moves) {
      try {
        await dc.animateCameraTo(
          target: move.target,
          zoom: move.zoom,
          bearing: move.bearing,
          tilt: move.tilt,
          durationMs: move.durationMs,
        );
      } catch (_) {
        try {
          await _controller?.moveCamera(move.target, zoom: move.zoom);
        } catch (_) {}
        break;
      }
      if (move.pauseAfterMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: move.pauseAfterMs));
      }
    }
  }

  // ================= HELPERS & MATH =================

  // Computes a slightly south-shifted target so the user marker is not
  // visually cut by bottom padding/overlays when tilting. Uses zoom to
  // estimate meters-per-pixel for a consistent offset.
  nmap.LatLng _targetForUserWithPadding(double zoom) {
    final double lat = widget.userLocation.latitude;
    final double lng = widget.userLocation.longitude;
    final double latRad = lat * math.pi / 180.0;
    final double metersPerPixel =
        156543.03392 * math.cos(latRad) / math.pow(2.0, zoom);
    final double pxBottom = math.max(0.0, widget.brandSafePaddingBottom);
    final double pxMarker = widget.userMarkerSize.toDouble().clamp(32.0, 240.0);
    // push up: 70% of bottom padding + 30% of marker + small margin
    final double pxShift = pxBottom * 0.70 + pxMarker * 0.30 + 20.0;
    final double metersShift = pxShift * metersPerPixel;
    final double latDelta = metersShift / 111320.0; // ~meters per deg lat
    return nmap.LatLng(lat - latDelta, lng);
  }

  Future<void> _fitRouteBounds({double padding = 64.0}) async {
    if (_controller == null || _route.isEmpty) return;
    double minLat = _route.first.latitude, maxLat = _route.first.latitude;
    double minLng = _route.first.longitude, maxLng = _route.first.longitude;
    for (final p in _route) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final ne = nmap.LatLng(maxLat, maxLng);
    final sw = nmap.LatLng(minLat, minLng);
    bool moved = false;
    try {
      await _controller!.animateToBounds(ne, sw, padding: padding);
      moved = true;
    } catch (_) {}
    if (!moved) {
      final double midLat = (minLat + maxLat) / 2.0;
      final double midLng = (minLng + maxLng) / 2.0;
      final nmap.LatLng center = nmap.LatLng(midLat, midLng);
      final double boundsDistance = _meters(sw, ne);
      final double zoom = _zoomForDistance(boundsDistance * 1.2);
      try {
        final dynamic dc = _controller;
        await dc.animateCameraTo(
          target: center,
          zoom: zoom,
          bearing: 0.0,
          tilt: 52.0,
          durationMs: 520,
        );
      } catch (_) {
        try {
          await _controller!.moveCamera(center, zoom: zoom);
        } catch (_) {}
      }
    }
  }

  Future<void> _removePolyline(String id) async {
    if (_polylineIds.contains(id)) {
      try {
        await _controller?.removePolyline(id);
      } catch (_) {}
      _polylineIds.remove(id);
    }
    _polylineCanInplaceUpdate.remove(id);
  }

  Future<void> _updatePolyline({
    required String id,
    required List<nmap.LatLng> points,
    required double width,
    required Color color,
    bool geodesic = true,
  }) async {
    if (_controller == null) return;
    if (!_polylineIds.contains(id)) {
      try {
        await _controller?.addPolyline(nmap.PolylineOptions(
          id: id,
          points: points.isEmpty ? const [] : points,
          width: width,
          color: color,
          geodesic: geodesic,
        ));
        _polylineIds.add(id);
        _polylineCanInplaceUpdate[id] = true;
        return;
      } catch (_) {
        return;
      }
    }
    final bool canInplace = _polylineCanInplaceUpdate[id] ?? true;
    if (canInplace) {
      try {
        await _controller?.updatePolylinePoints(id, points);
        return;
      } catch (_) {
        _polylineCanInplaceUpdate[id] = false;
      }
    }
    try {
      await _controller?.removePolyline(id);
      await _controller?.addPolyline(nmap.PolylineOptions(
        id: id,
        points: points,
        width: width,
        color: color,
        geodesic: geodesic,
      ));
    } catch (_) {}
  }

  double _zoomForDistance(double meters) {
    if (meters > 150000) return 10.8;
    if (meters > 70000) return 12.0;
    if (meters > 20000) return 13.2;
    if (meters > 8000) return 14.2;
    if (meters > 3000) return 14.8;
    return 15.8;
  }

  int _autoDurationMs(double meters, {double factor = 1.0}) {
    // menor duration = mais rÃ¡pido
    double base = 9000.0 + (meters / 1000.0) * 800.0;
    base = base * factor.clamp(0.6, 2.0);
    return base.clamp(6000.0, 14000.0).toInt();
  }

  String _makeInitials(String name) {
    final parts =
        name.trim().split(RegExp(r"\s+")).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1)
      return parts.first.characters.take(2).toString().toUpperCase();
    return (parts.first.characters.take(1).toString() +
            parts.last.characters.take(1).toString())
        .toUpperCase();
  }

  List<nmap.LatLng> _decodePolyline(String encoded) {
    final List<nmap.LatLng> points = <nmap.LatLng>[];
    int index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;
      points.add(nmap.LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  List<nmap.LatLng> _decimate(List<nmap.LatLng> pts,
      {double minStepMeters = 6.0, int maxPoints = 300}) {
    if (pts.length <= 2) return pts;
    final List<nmap.LatLng> out = <nmap.LatLng>[];
    nmap.LatLng? last;
    for (final p in pts) {
      if (last == null || _meters(last, p) >= minStepMeters) {
        out.add(p);
        last = p;
      }
    }
    if (out.length <= maxPoints) return out;
    final int step = (out.length / maxPoints).ceil();
    final List<nmap.LatLng> dec = <nmap.LatLng>[];
    for (int i = 0; i < out.length; i += step) {
      dec.add(out[i]);
    }
    if (dec.last != out.last) dec.add(out.last);
    return dec;
  }

  double _meters(nmap.LatLng a, nmap.LatLng b) {
    const double R = 6371000.0;
    final double dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final double dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final double la1 = a.latitude * math.pi / 180.0;
    final double la2 = b.latitude * math.pi / 180.0;
    final double h = math.sin(dLat / 2.0) * math.sin(dLat / 2.0) +
        math.cos(la1) *
            math.cos(la2) *
            math.sin(dLon / 2.0) *
            math.sin(dLon / 2.0);
    return 2.0 * R * math.asin(math.min(1.0, math.sqrt(h)));
  }

  int _indexAtDistance(double target) {
    if (_cumDist.isEmpty) return 0;
    int lo = 0, hi = _cumDist.length - 1;
    while (lo <= hi) {
      final int mid = (lo + hi) ~/ 2;
      final double v = _cumDist[mid];
      if (v < target)
        lo = mid + 1;
      else
        hi = mid - 1;
    }
    if (lo < 1) return 1;
    if (lo >= _cumDist.length) return _cumDist.length - 1;
    return lo;
  }

  nmap.LatLng _posAt(double target) {
    if (_route.isEmpty) return _gm(widget.userLocation);
    if (target <= 0.0) return _route.first;
    if (target >= _totalDist) return _route.last;
    final int i = _indexAtDistance(target);
    final int i0 = i - 1, i1 = i;
    final double d0 = _cumDist[i0], d1 = _cumDist[i1];
    final double seg = (d1 - d0) <= 0.0 ? 1e-6 : (d1 - d0);
    final double ft = ((target - d0) / seg).clamp(0.0, 1.0);
    final nmap.LatLng a = _route[i0], b = _route[i1];
    return nmap.LatLng(
      a.latitude + (b.latitude - a.latitude) * ft,
      a.longitude + (b.longitude - a.longitude) * ft,
    );
  }

  double _bearing(nmap.LatLng a, nmap.LatLng b) {
    final double lat1 = a.latitude * math.pi / 180.0;
    final double lat2 = b.latitude * math.pi / 180.0;
    final double dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final double brng = math.atan2(y, x) * 180.0 / math.pi;
    return (brng + 360.0) % 360.0;
  }

  double _bearingLerp(double a, double b, double t) {
    final double diff = ((b - a + 540.0) % 360.0) - 180.0;
    return (a + diff * t + 360.0) % 360.0;
  }
}

class _DriverVisualChoice {
  const _DriverVisualChoice({
    required this.url,
    required this.fallback,
    required this.isTaxi,
    this.forceBrandIcon = false,
  });

  final String? url;
  final String? fallback;
  final bool isTaxi;
  final bool forceBrandIcon;
}

class _CameraMove {
  const _CameraMove({
    required this.target,
    required this.zoom,
    required this.bearing,
    required this.tilt,
    required this.durationMs,
    this.pauseAfterMs = 0,
  });

  final nmap.LatLng target;
  final double zoom;
  final double bearing;
  final double tilt;
  final int durationMs;
  final int pauseAfterMs;
}

class _PlatformInfo {
  _PlatformInfo(this._rawValues);

  final List<String> _rawValues;

  late final List<String> _normalized = _rawValues
      .map((String value) => value.trim().toLowerCase())
      .where((String value) => value.isNotEmpty)
      .toList();

  bool get isRideDriver => _normalized
      .any((value) => value == 'ride driver' || value == 'ridedriver');

  bool get isRideTaxi =>
      _normalized.any((value) => value == 'ride taxi' || value == 'ridetaxi');

  bool get hasTaxiKeyword => _normalized.any((value) => value.contains('taxi'));

  bool get hasDriverKeyword =>
      _normalized.any((value) => value.contains('driver'));
}

// ===== Tween helper =====
class _TweenRunner {
  _TweenRunner({
    required this.from,
    required this.to,
    required this.durationMs,
    required this.onStep,
    required TickerProvider vsync,
    this.curve = Curves.linear,
  }) : _controller = AnimationController(
          vsync: vsync,
          duration: Duration(milliseconds: math.max(16, durationMs)),
        ) {
    _statusListener = (status) {
      if (status == AnimationStatus.completed) {
        _dispatch(1.0);
      }
    };
    _controller.addListener(_handleTick);
    _controller.addStatusListener(_statusListener);
  }

  final nmap.LatLng from;
  final nmap.LatLng to;
  final int durationMs;
  final Curve curve;
  final Future<void> Function(nmap.LatLng pos, double t) onStep;

  final AnimationController _controller;
  late final void Function(AnimationStatus) _statusListener;

  bool _busy = false;
  double? _pendingLinear;

  void start() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _pendingLinear = null;
    _dispatch(0.0);
    _controller.forward(from: 0.0);
  }

  void _handleTick() => _dispatch(_controller.value);

  void _dispatch(double linearT) {
    if (_busy) {
      _pendingLinear = linearT;
      return;
    }
    _busy = true;
    final double eased = curve.transform(linearT.clamp(0.0, 1.0));
    final double lat = _lerp(from.latitude, to.latitude, eased);
    final double lng = _lerp(from.longitude, to.longitude, eased);
    onStep(nmap.LatLng(lat, lng), eased).whenComplete(() {
      _busy = false;
      final double? pending = _pendingLinear;
      _pendingLinear = null;
      if (pending != null && (pending - linearT).abs() > 1e-4) {
        _dispatch(pending);
      }
    });
  }

  void dispose() {
    _controller.removeListener(_handleTick);
    _controller.removeStatusListener(_statusListener);
    _controller.dispose();
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
