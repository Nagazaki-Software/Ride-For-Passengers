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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:characters/characters.dart';
import 'package:path_provider/path_provider.dart';

import '/flutter_flow/lat_lng.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_native_sdk/google_maps_native_sdk.dart' as nmap;

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
    this.routeWidth = 14,
    this.liveTraceColor = const Color(0xFF00E5FF),
    this.liveTraceWidth = 4,
    this.userMarkerSize = 64,
    this.driverIconWidth = 72,
    this.driverDriverIconUrl,
    this.driverTaxiIconUrl,
    this.borderRadius = 16,
    this.brandSafePaddingBottom = 0,
    this.fadeInMs = 420,
    this.enableRouteSnake = true,
    this.snakeDurationMsOverride, // se quiser forçar (ms)
    this.snakeSpeedFactor = 1.4,
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

  final String? driverDriverIconUrl; // usado p/ driver ou destino (driver)
  final String? driverTaxiIconUrl; // usado p/ driver ou destino (taxi)

  final double borderRadius;
  final double brandSafePaddingBottom;

  final bool enableRouteSnake;
  final int? snakeDurationMsOverride;
  final double snakeSpeedFactor; // 1.0 = esperto; <1 mais rápido; >1 mais lento
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
  final Map<String, String> _markerTitle = {};

  final Map<String, StreamSubscription<DocumentSnapshot>> _subs = {};
  final Map<String, nmap.LatLng> _driverPos = {};
  final Map<String, _TweenRunner> _driverTween = {};
  final Map<String, double> _driverRot = {};

  final Map<String, Future<Uint8List?>> _iconInFlight = {};
  static final Map<String, Uint8List> _iconMemCache = {};

  final Map<String, List<nmap.LatLng>> _driverTrace = {};
  final Map<String, int> _lastTraceUpdateMs = {};

  List<nmap.LatLng> _route = <nmap.LatLng>[];
  List<double> _cumDist = <double>[];
  double _totalDist = 0.0;

  // Snake
  late final Ticker _ticker;
  bool _snaking = false;
  double _snakeT = 0.0;
  int _snakeDurationMs = 9000; // mais rápido por padrão
  int _lastCamUpdateMs = 0;

  // Follow suave do usu�rio quando sem destino
  nmap.LatLng? _lastUserCamTarget;
  int _lastUserFollowMs = 0;

  // Re-roteamento (debounce) e controle de concorr�ncia
  Timer? _rerouteDebounce;
  int _routeReqSeq = 0;

  // Idle camera quando destination == null
  Timer? _idleCamTimer;
  double _idleBearing = 0;

  // IDs de polylines
  static const String _kBaseOutline = 'route_base_outline';
  static const String _kBaseMain = 'route_base_main';
  static const String _kSnakeOutline = 'route_snake_outline';
  static const String _kSnakeMain = 'route_snake_main';
  static const String _kDestIconUrl = 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png';

  final Map<String, bool> _polylineCanInplaceUpdate = {};

  static const String _darkMapStyle =
      '[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#2b2b2b"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1e1e1e"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f2f2f"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}]';

  nmap.LatLng _gm(LatLng p) => nmap.LatLng(p.latitude, p.longitude);

  // Enquadramento mais aberto quando a linha entra
  static const double _kSnakeFitPadding = 560.0;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((elapsed) async {
      if (!_snaking || !_mapReady || _controller == null || _totalDist <= 0)
        return;

      // velocidade do snake
      // velocidade do snake
      // Se override for fornecido, respeita-o (dentro de limites mais amplos),
      // sen�o usa c�lculo autom�tico em uma faixa mais r�pida.
      final int dur = (widget.snakeDurationMsOverride != null
              ? widget.snakeDurationMsOverride!
                  .clamp(500, 30000) // permite anima��es bem r�pidas
              : _autoDurationMs(_totalDist, factor: widget.snakeSpeedFactor)
                  .clamp(2000, 12000))
          .toInt();
      final int dur = (widget.snakeDurationMsOverride ??
              _autoDurationMs(_totalDist, factor: widget.snakeSpeedFactor))
          .clamp(6000, 14000); // rápido/esperto
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

      // Follow de câmera mais amplo
      final int now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastCamUpdateMs > 140) {
        _lastCamUpdateMs = now;
        final nmap.LatLng ref = _posAt((headDist - 120).clamp(0.0, _totalDist));
        final double br = _bearing(ref, headPos);
        try {
          final dynamic dc = _controller;
          await dc.animateCameraTo(
            target: headPos,
            zoom: _zoomForDistance(_totalDist),
            bearing: br,
            tilt: 24.0,
            durationMs: 380,
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
        await _removePolyline(_kSnakeOutline);
        await _removePolyline(_kSnakeMain);

        await _animateFinal3DView();
      }
    });
  }

  @override
  void didUpdateWidget(covariant PickerMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Mudou o destino? alterna modos e (re)planeja
    if (oldWidget.destination == null && widget.destination != null) {
      _stopIdleCam();
      _prepareRoute().then((_) => _startSnake());
    } else if (oldWidget.destination != null && widget.destination == null) {
      _clearRoute();
      try { _controller?.removeMarker('dest'); } catch (_) {}
      _markerIds.remove('dest');
      _markerPos.remove('dest');
      _markerTitle.remove('dest');
      _returnToUserFromRoute();
      _snapToUser();
      _startIdleCam();
    } else if (oldWidget.destination != null && widget.destination != null) {
      // Ambos n�o nulos: se coordenadas mudarem, reagenda o re-roteamento
      final LatLng a = oldWidget.destination!;
      final LatLng b = widget.destination!;
      final bool changed = (a.latitude - b.latitude).abs() > 1e-6 ||
          (a.longitude - b.longitude).abs() > 1e-6;
      if (changed) {
        _stopIdleCam();
        _scheduleReroute();
        return;
      }
    } else {
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

                // micro-nudge
                try {
                  final dynamic dc = _controller;
                  await dc.animateCameraBy(dx: 0.1, dy: 0.0);
                  await Future<void>.delayed(const Duration(milliseconds: 24));
                  await dc.animateCameraBy(dx: -0.1, dy: 0.0);
                } catch (_) {}

                SchedulerBinding.instance.addPostFrameCallback((_) async {
                  await _placeCoreMarkers(); // cria já com ícone (sem vermelho)
                  _subscribeDrivers();

                  if (widget.destination != null) {
                    await _prepareRoute();
                    _startSnake();
                  } else {
                    _snapToUser();
                    _startIdleCam();
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

  // ===== Idle camera / Snap para usuário =====
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
    try {
      final dynamic dc = _controller;
      await dc.animateCameraTo(
        target: _gm(widget.userLocation),
        zoom: 16.8,
        bearing: 0,
        tilt: 58,
        durationMs: 420,
      );
    } catch (_) {}
  }

  Future<void> _returnToUserFromRoute() async {
    if (!_mapReady || _controller == null) return;
    try {
      final dynamic dc = _controller;
      await dc.animateCameraTo(
        target: _gm(widget.userLocation),
        zoom: 16.2,
        bearing: 0,
        tilt: 0,
        durationMs: 520,
      );
      _lastUserCamTarget = _gm(widget.userLocation);
      _lastUserFollowMs = DateTime.now().millisecondsSinceEpoch;
    } catch (_) {}
  }

  // ===== Limpa rota quando destination == null =====
  Future<void> _clearRoute() async {
    _snaking = false;
    _snakeT = 0.0;
    _route = <nmap.LatLng>[];
    _cumDist = <double>[];
    _totalDist = 0.0;
    for (final id in [_kBaseOutline, _kBaseMain, _kSnakeOutline, _kSnakeMain]) {
      await _removePolyline(id);
    }
  }

  // ================= MARKERS (sem pin vermelho) =================

  Future<void> _placeCoreMarkers() async {
    if (!_mapReady || _controller == null) return;

    // USER — só adiciona quando o PNG estiver pronto
    final nmap.LatLng user = _gm(widget.userLocation);
    if (!_markerIds.contains('user')) {
      final Uint8List userBytes = await _makeUserAvatarBytes(
        name: widget.userName ?? 'Você',
        photoUrl: widget.userPhotoUrl,
        diameter: widget.userMarkerSize.clamp(36, 128),
      );
      await _addMarkerWithIconFile(
        id: 'user',
        position: user,
        title: null,
        title: widget.userName ?? 'Você',
        anchorU: 0.5,
        anchorV: 0.5,
        zIndex: 30.0,
        bytesIcon: userBytes,
      );
      _markerPos['user'] = user;
      _markerTitle['user'] = widget.userName ?? 'Você';
    } else {
      try {
        await _controller!.updateMarker('user', position: user);
      } catch (_) {}
      _markerPos['user'] = user;
    }

    // DESTINO — usa suas URLs (taxi/driver) p/ não criar prop nova
    if (widget.destination != null) {
      final nmap.LatLng dest = _gm(widget.destination!);
      if (!_markerIds.contains('dest')) {
        // �cone fixo do destino (for�ado)
        Uint8List? bytes = await _downloadAndResize(_kDestIconUrl, widget.driverIconWidth.clamp(36, 128));
        // fallback: bolinha estilizada (n�o vermelho)
        // preferir taxi p/ destino; senão driver
        final String? prefUrl =
            ((widget.driverTaxiIconUrl ?? '').trim().isNotEmpty)
                ? widget.driverTaxiIconUrl
                : ((widget.driverDriverIconUrl ?? '').trim().isNotEmpty)
                    ? widget.driverDriverIconUrl
                    : null;

        Uint8List? bytes;
        if (prefUrl != null && !_looksSvg(prefUrl)) {
          bytes = await _downloadAndResize(
              _massageUrl(prefUrl), widget.driverIconWidth.clamp(36, 128));
        }
        // fallback: bolinha estilizada (não vermelho)
        bytes ??= await _drawCirclePinPng(
            size: 96, color: widget.routeColor, stroke: 4.0);

        await _addMarkerWithIconFile(
          id: 'dest',
          position: dest,
          title: null,
          anchorU: 0.5,
          anchorV: 0.5,
          zIndex: 25.0,
          bytesIcon: bytes,
        );
        _markerPos['dest'] = dest;
      } else {
        try {
          await _controller!.updateMarker('dest', position: dest);
        } catch (_) {}
        _markerPos['dest'] = dest;
      }
    }
  }

  // Adiciona COM ícone de arquivo local e reforça com bytes (sem flicker vermelho)
  Future<void> _addMarkerWithIconFile({
    required String id,
    required nmap.LatLng position,
    String? title,
    required double anchorU,
    required double anchorV,
    required double zIndex,
    required Uint8List bytesIcon,
  }) async {
    final path = await _writeTempPng(bytesIcon);
    if (path == null) return;

    if (_markerIds.contains(id)) {
      try {
        await _controller?.removeMarker(id);
      } catch (_) {}
      _markerIds.remove(id);
    }

    bool added = false;
    Future<bool> tryAdd(String iconUrl) async {
      try {
        await _controller?.addMarker(nmap.MarkerOptions(
          id: id,
          position: position,
          title: null,
          iconUrl: iconUrl,
          anchorU: anchorU,
          anchorV: anchorV,
          zIndex: zIndex,
        ));
        _markerIds.add(id);
        return true;
      } catch (_) {
        return false;
      }
    }

    // Tenta com file:// e sem prefixo
    if (await tryAdd('file://$path') || await tryAdd(path)) {
      added = true;
      try {
        await _applyMarkerBytesWithRetry(id, bytesIcon);
        final dynamic dc = _controller;
        await dc.setMarkerIconBytes(id: id, bytes: bytesIcon);
      } catch (_) {}
    }

    if (!added) {
      // Fallback: cria com PNG transparente para evitar flicker vermelho, depois aplica bytes reais
      try {
        final transparent = await _transparentPng();
        final tpath = await _writeTempPng(transparent);
        if (tpath != null) {
          await _controller?.addMarker(nmap.MarkerOptions(
            id: id,
            position: position,
            title: null,
            iconUrl: 'file://' + tpath,
            anchorU: anchorU,
            anchorV: anchorV,
            zIndex: zIndex,
          ));
          _markerIds.add(id);
          try {
            await _applyMarkerBytesWithRetry(id, bytesIcon);
          } catch (_) {}
        }
      } catch (_) {}
    }
  }

  void _scheduleReroute() {
    _rerouteDebounce?.cancel();
    _rerouteDebounce = Timer(const Duration(milliseconds: 360), () async {
      if (!mounted || widget.destination == null) return;
      // marca nova requisi��o de rota
      _routeReqSeq++;
      await _clearRoute();
      await _placeCoreMarkers();
      await _prepareRoute();
      if (mounted) _startSnake();
    });
  }

  Future<void> _applyMarkerBytesWithRetry(String id, Uint8List bytes,
      {int attempts = 5}) async {
    for (int i = 0; i < attempts; i++) {
      try {
        final dynamic dc = _controller;
        await Future<void>.delayed(Duration(milliseconds: 24 * (i + 1)));
        await dc.setMarkerIconBytes(id: id, bytes: bytes);
        return;
      // fallback absoluto: adiciona sem ícone e depois aplica bytes
      try {
        await _controller?.addMarker(nmap.MarkerOptions(
          id: id,
          position: position,
          title: title,
          anchorU: anchorU,
          anchorV: anchorV,
          zIndex: zIndex,
        ));
        _markerIds.add(id);
        try {
          final dynamic dc = _controller;
          await dc.setMarkerIconBytes(id: id, bytes: bytesIcon);
        } catch (_) {}
      } catch (_) {}
    }
  }

  Future<Uint8List> _transparentPng({int size = 4}) async {
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    final img = await rec.endRecording().toImage(size, size);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<Uint8List> _drawCirclePinPng({
    int size = 96,
    Color color = const Color(0xFFFFC107),
    double stroke = 4.0,
  }) async {
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    final s = size.toDouble();
    final center = ui.Offset(s / 2, s / 2);
    c.drawCircle(
        center,
        s * 0.32,
        ui.Paint()
          ..color = Colors.black.withOpacity(.28)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8));
    c.drawCircle(
        center,
        s * 0.30,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = const Color(0xFF000000));
    c.drawCircle(center, s * 0.28, ui.Paint()..color = color);
    final img = await rec.endRecording().toImage(size, size);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  // ================= DRIVERS =================

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

        String? rawUrl = (data?['photoUrl'] ??
                data?['avatar'] ??
                data?['avatar_url'] ??
                data?['image'])
            ?.toString();
        if (rawUrl == null || rawUrl.trim().isEmpty || _looksSvg(rawUrl)) {
          final type = _driverTypeFromData(data);
          rawUrl = type == 'taxi'
              ? widget.driverTaxiIconUrl
              : widget.driverDriverIconUrl;
        }

        final last = _driverPos[id];
        if (last == null) {
          Uint8List? bytes;
          if ((rawUrl ?? '').trim().isNotEmpty && !_looksSvg(rawUrl)) {
            bytes = await _downloadAndResize(
                _massageUrl(rawUrl!), widget.driverIconWidth.clamp(36, 128));
          }
          bytes ??= await _initialsAvatarPng(
              name: title, size: widget.driverIconWidth);

          await _addMarkerWithIconFile(
            id: 'driver_$id',
            position: p,
            title: null,
            anchorU: 0.5,
            anchorV: 0.62,
            zIndex: 22.0,
            bytesIcon: bytes,
          );

          _driverPos[id] = p;
          _markerPos['driver_$id'] = p;
          _markerTitle['driver_$id'] = title;

          await _updateDriverTrace(id, p, force: true);
          return;
        }

        _driverTween[id]?.dispose();
        final double brFrom = _driverRot[id] ?? _bearing(last, p);
        final double brTo = _bearing(last, p);
        _driverTween[id] = _TweenRunner(
          from: last,
          to: p,
          durationMs: widget.driverTweenMs,
          curve: Curves.easeInOutCubic,
          onStep: (pos, t) async {
            _driverPos[id] = pos;
            final rot = _bearingLerp(brFrom, brTo, t);
            _driverRot[id] = rot;
            try {
              await _controller?.updateMarker('driver_$id',
                  position: pos, rotation: rot);
            } catch (_) {}
            _markerPos['driver_$id'] = pos;
            await _updateDriverTrace(id, pos);
          },
        )..start();
      });
    }
  }

  String _driverTypeFromData(Map<String, dynamic>? data) {
    dynamic raw = (data?['users'] is Map) ? data?['users']?['plataform'] : null;
    raw ??= data?['plataform'];
    raw ??= data?['platform'];
    raw ??= data?['type'];
    final List<String> items = (raw is List)
        ? raw.map((e) => (e?.toString() ?? '')).toList()
        : (raw is String)
            ? <String>[raw]
            : <String>[];
    final bool isTaxi = items.any((s) => s.toLowerCase().contains('taxi'));
    final bool isDriver = items.any((s) => s.toLowerCase().contains('driver'));
    return isTaxi ? 'taxi' : (isDriver ? 'driver' : 'driver');
  }

  // ================= ROTA / LINHA =================

  Future<void> _prepareRoute() async {
    final int req = ++_routeReqSeq;
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
    final String apiKey = (widget.googleApiKey ?? '').trim();
    bool routed = false;

    if (apiKey.isNotEmpty) {
      try {
        final res = await nmap.RoutesApi.computeRoutes(
          apiKey: apiKey,
          origin: nmap.Waypoint(location: a),
          destination: nmap.Waypoint(location: b),
          languageCode: 'pt-BR',
          alternatives: false,
        );
        if (res.routes.isNotEmpty) {
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

    // Inicializa as camadas do snake
    final List<nmap.LatLng> start = <nmap.LatLng>[_route.first, _route.first];

    if (!mounted || req != _routeReqSeq) return;

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

    if (!mounted || req != _routeReqSeq) return;
    await _fitRouteBounds(padding: _kSnakeFitPadding);
  }

  void _startSnake() async {
    if (!_mapReady || !mounted) return;
    if (!widget.enableRouteSnake || _route.length < 2) return;
    _snakeT = 0.0;
    _snaking = true;
    _ticker.stop();

    // Enquadra bem aberto e começa
    await _fitRouteBounds(padding: _kSnakeFitPadding);
    await Future<void>.delayed(const Duration(milliseconds: 220));
    _ticker.start();
  }

  // ================= Accessibility helpers =================
  Future<void> _maybeAnnouncePlace(String label, nmap.LatLng pos) async {
    if (!FFAppState().accessStreetNamesAudio) return;
    try {
      final String? addr = await _reverseGeocodeForAudio(pos);
      final String msg = (addr == null || addr.isEmpty)
          ? '$label definido'
          : '$label: $addr';
      SemanticsService.announce(msg, ui.TextDirection.ltr);
    } catch (_) {}
  }

  Future<void> _maybeAnnounceRouteSummary() async {
    if (!FFAppState().accessStreetNamesAudio) return;
    if (_route.length < 2) return;
    try {
      final String? a = await _reverseGeocodeForAudio(_route.first);
      final String? b = await _reverseGeocodeForAudio(_route.last);
      final String msg =
          'Rota pronta.' + (a != null && a.isNotEmpty ? ' Sa�da: $a.' : '') + (b != null && b.isNotEmpty ? ' Destino: $b.' : '');
      SemanticsService.announce(msg, ui.TextDirection.ltr);
    } catch (_) {}
  }

  Future<String?> _reverseGeocodeForAudio(nmap.LatLng pos) async {
    final key = (widget.googleApiKey ?? '').trim();
    if (key.isEmpty) return null;
    try {
      final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&language=pt-BR&key=$key');
      final resp = await http.get(uri);
      if (resp.statusCode != 200) return null;
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? const [];
      if (results.isEmpty) return null;
      final first = results.first as Map<String, dynamic>;
      return (first['formatted_address'] ?? '').toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _animateFinal3DView() async {
    if (_controller == null || _route.length < 2) return;
    final nmap.LatLng end = _route.last;
    final double br = _bearing(_route[_route.length - 2], end);
    try {
      await _fitRouteBounds(padding: _kSnakeFitPadding);
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 180));
    try {
      final dynamic dc = _controller;
      await dc.animateCameraTo(
        target: end,
        zoom: _zoomForDistance(_totalDist),
        bearing: br,
        tilt: 8.0,
        durationMs: 680,
        tilt: 56.0,
        durationMs: 800,
      );
    } catch (_) {
      try {
        await _controller!.moveCamera(end, zoom: _zoomForDistance(_totalDist));
      } catch (_) {}
    }
  }

  // ================= ÍCONES / BYTES =================

  String _massageUrl(String url) {
    String s = url.trim().replaceFirst('http://', 'https://');
    // Firebase Storage: força download direto
    if (s.startsWith('gs://')) {
      final noGs = s.substring(5);
      final slash = noGs.indexOf('/');
      if (slash > 0) {
        final bucket = noGs.substring(0, slash);
        final path = Uri.encodeComponent(noGs.substring(slash + 1));
        s = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$path?alt=media';
      }
    }
    if (s.contains('firebasestorage.googleapis.com') &&
        !s.contains('alt=media')) {
      s += s.contains('?') ? '&alt=media' : '?alt=media';
    }
    return s;
  }

  Future<String?> _writeTempPng(Uint8List bytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/marker_${DateTime.now().microsecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
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
    final hit = _iconMemCache[clean];
    if (hit != null) return hit;
    if (_iconInFlight.containsKey(clean)) return await _iconInFlight[clean]!;
    Future<Uint8List?> task() async {
      try {
        final resp = await http.get(Uri.parse(_massageUrl(clean)));
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
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: size * 0.38,
          fontFamily: 'Roboto',
          fontWeight: ui.FontWeight.w700),
    )
      ..pushStyle(ui.TextStyle(color: const Color(0xFF111111)))
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

  // ================= HELPERS & MATH =================

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
    try {
      await _controller!.animateToBounds(ne, sw, padding: padding);
    } catch (_) {}
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
    // menor duration = mais r�pido e proporcional � dist�ncia
    double base = 5200.0 + (meters / 1000.0) * 420.0;
    base = base * factor.clamp(0.5, 1.8);
    return base.clamp(2000.0, 12000.0).toInt();
    // menor duration = mais rápido
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

// ===== Tween helper =====
class _TweenRunner {
  _TweenRunner({
    required this.from,
    required this.to,
    required this.durationMs,
    required this.onStep,
    this.curve = Curves.linear,
  });

  final nmap.LatLng from;
  final nmap.LatLng to;
  final int durationMs;
  final Curve curve;
  final Future<void> Function(nmap.LatLng pos, double t) onStep;

  Timer? _timer;
  int _startMs = 0;

  void start() {
    _timer?.cancel();
    _startMs = DateTime.now().millisecondsSinceEpoch;
    const int frameMs = 16;
    _timer = Timer.periodic(const Duration(milliseconds: frameMs), (t) async {
      final int now = DateTime.now().millisecondsSinceEpoch;
      final double uRaw =
          ((now - _startMs) / durationMs).clamp(0.0, 1.0).toDouble();
      final double u = curve.transform(uRaw);
      final double lat = _lerp(from.latitude, to.latitude, u);
      final double lng = _lerp(from.longitude, to.longitude, u);
      await onStep(nmap.LatLng(lat, lng), u);
      if (uRaw >= 1.0) t.cancel();
    });
  }

  void dispose() => _timer?.cancel();
  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
