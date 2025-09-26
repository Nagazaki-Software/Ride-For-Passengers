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
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:characters/characters.dart';
import 'package:path_provider/path_provider.dart';

import '/flutter_flow/lat_lng.dart';
import 'package:google_maps_native_sdk/google_maps_native_sdk.dart' as nmap;

/// PickerViewMore (native sdk): dark UI + rota âmbar animada + destino PNG +
/// avatar do usuário (foto ou iniciais) + follow-cam
class PickerViewMore extends StatefulWidget {
  const PickerViewMore({
    super.key,
    this.width,
    this.height,
    required this.latlngOrigem,
    required this.latlngDestino,
    this.googleApiKey,
    this.fitPadding = 56,
    this.strokeWidth = 4,
    this.strokeColor = const Color(0xFFFBB125),
    this.interactive = false,
    this.borderRadius = 16,
    this.userName,
    this.userPhotoUrl,
    this.destinationMarkerPngUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png',
    this.userMarkerSize = 56,
    this.destMarkerWidth = 54,
    this.routeAnimationEnabled = true,
    this.routeAnimMinMs = 1600,
    this.routeAnimMaxMs = 18000,
    this.routeAnimMsPerKm = 1100,
    this.runnerDotRadiusMeters = 9.0,
  });

  final double? width;
  final double? height;

  final LatLng latlngOrigem;
  final LatLng latlngDestino;

  final String? googleApiKey;
  final double fitPadding;

  final double strokeWidth;
  final Color strokeColor;

  final double borderRadius;
  final bool interactive;

  final String? userName;
  final String? userPhotoUrl;
  final String destinationMarkerPngUrl;

  final int userMarkerSize;
  final int destMarkerWidth;

  final bool routeAnimationEnabled;
  final int routeAnimMinMs;
  final int routeAnimMaxMs;
  final int routeAnimMsPerKm;
  final double runnerDotRadiusMeters;

  @override
  State<PickerViewMore> createState() => _PickerViewMoreState();
}

class _PickerViewMoreState extends State<PickerViewMore>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  nmap.GoogleMapController? _controller;

  final Set<String> _markerIds = <String>{};
  final Set<String> _polylineIds = <String>{};

  final Map<String, bool> _polylineCanInplaceUpdate = {};
  final Map<String, String> _markerTitle = {};
  final Map<String, nmap.LatLng> _markerPos = {};

  // rota
  List<nmap.LatLng> _route = <nmap.LatLng>[];
  List<double> _cumDist = <double>[];
  double _totalDist = 0;

  // anima
  late final Ticker _ticker;
  bool _animating = false;
  Duration _prevElapsed = Duration.zero;
  double _headDist = 0.0;
  int _routeDurationMs = 1600;
  int _lastCamUpdateMs = 0;

  // véu anti-flash
  bool _veilVisible = true;

  static const _darkMapStyle = '''
[{"elementType":"geometry","stylers":[{"color":"#121212"}]},
 {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
 {"elementType":"labels.text.fill","stylers":[{"color":"#8E8E8E"}]},
 {"elementType":"labels.text.stroke","stylers":[{"color":"#121212"}]},
 {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1E1E1E"}]},
 {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#272727"}]},
 {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2B2B2B"}]},
 {"featureType":"poi","stylers":[{"visibility":"off"}]},
 {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#1A1A1A"}]},
 {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0B0B0B"}]}]
''';

  nmap.LatLng _gm(LatLng p) => nmap.LatLng(p.latitude, p.longitude);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) async {
      if (!_animating || _controller == null || _totalDist <= 0) return;
      final double dt =
          ((elapsed - _prevElapsed).inMicroseconds / 1e6).clamp(0.0, 0.05);
      _prevElapsed = elapsed;

      final double speedMps =
          (_totalDist / (_routeDurationMs / 1000.0)).clamp(40.0, 400.0);
      _headDist += speedMps * dt;
      if (_headDist > _totalDist) _headDist = _totalDist;

      final int k = _indexAtDistance(_headDist);
      final nmap.LatLng headPos = _posAt(_headDist);
      final List<nmap.LatLng> vis = (k > 0)
          ? (List<nmap.LatLng>.from(_route.getRange(0, k))..add(headPos))
          : <nmap.LatLng>[_route.first, headPos];

      await _updatePolyline(
        id: 'route_shadow',
        points: _route,
        width: (widget.strokeWidth + 2).toDouble().clamp(4, 9),
        color: const Color(0x80000000),
        geodesic: true,
      );
      await _updatePolyline(
        id: 'route_progress',
        points: vis,
        width: (widget.strokeWidth + 1).toDouble().clamp(3, 8),
        color: widget.strokeColor,
        geodesic: true,
      );

      // runner (pequeno marcador sólido)
      await _ensureRunner(headPos);

      // follow-cam leve
      final int now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastCamUpdateMs > 200) {
        _lastCamUpdateMs = now;
        final nmap.LatLng ref = _posAt((_headDist - 80).clamp(0.0, _totalDist));
        final double br = _bearing(ref, headPos);
        try {
          final dynamic dc = _controller;
          await dc.animateCameraTo(
            target: headPos,
            zoom: 16.5,
            bearing: br,
            tilt: 40.0,
            durationMs: 220,
          );
        } catch (_) {}
      }

      if (_headDist >= _totalDist) {
        _animating = false;
        _ticker.stop();
        await _animateFinal3DView();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PickerViewMore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latlngOrigem != widget.latlngOrigem ||
        oldWidget.latlngDestino != widget.latlngDestino ||
        oldWidget.googleApiKey != widget.googleApiKey ||
        oldWidget.strokeColor != widget.strokeColor ||
        oldWidget.strokeWidth != widget.strokeWidth ||
        oldWidget.userName != widget.userName ||
        oldWidget.userPhotoUrl != widget.userPhotoUrl ||
        oldWidget.destinationMarkerPngUrl != widget.destinationMarkerPngUrl ||
        oldWidget.userMarkerSize != widget.userMarkerSize ||
        oldWidget.destMarkerWidth != widget.destMarkerWidth ||
        oldWidget.routeAnimationEnabled != widget.routeAnimationEnabled ||
        oldWidget.routeAnimMinMs != widget.routeAnimMinMs ||
        oldWidget.routeAnimMaxMs != widget.routeAnimMaxMs ||
        oldWidget.routeAnimMsPerKm != widget.routeAnimMsPerKm ||
        oldWidget.runnerDotRadiusMeters != widget.runnerDotRadiusMeters) {
      _rebuildAll();
    }
  }

  Future<void> _rebuildAll() async {
    _animating = false;
    _ticker.stop();
    _headDist = 0;
    _prevElapsed = Duration.zero;
    await _removePolyline('route_shadow');
    await _removePolyline('route_progress');
    await _removeMarker('runner');
    await _removeMarker('origem');
    await _removeMarker('destino');
    if (_controller != null) {
      await _placeMarkers();
      await _prepareRoute();
      _startAnimation();
      await _fitToContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = widget.width ?? double.infinity;
    final height = widget.height ?? 240.0;

    final initialTarget = _gm(widget.latlngOrigem);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
            nmap.GoogleMapView(
              initialCameraPosition: nmap.CameraPosition(
                target: initialTarget,
                zoom: 13.5,
              ),
              myLocationEnabled: false,
              trafficEnabled: false,
              buildingsEnabled: false,
              mapStyleJson: _darkMapStyle,
              padding: const nmap.MapPadding(),
              onMapCreated: (nmap.GoogleMapController c) async {
                _controller = c;
                try {
                  await c.onMapLoaded;
                } catch (_) {}

                // micro-nudge para evitar flash de tiles
                try {
                  final dynamic dc = _controller;
                  await dc.animateCameraBy(dx: 0.1, dy: 0);
                  await Future<void>.delayed(const Duration(milliseconds: 40));
                  await dc.animateCameraBy(dx: -0.1, dy: 0);
                } catch (_) {}

                await _placeMarkers();
                await _prepareRoute();
                _startAnimation();
                await _fitToContent();

                if (mounted) setState(() => _veilVisible = false);
              },
            ),

            // tampa a CTA "ir para o Google Maps" (tap-block)
            Positioned(
              right: 0,
              bottom: 0,
              child: AbsorbPointer(
                absorbing: true,
                child: SizedBox(width: 96, height: 60),
              ),
            ),

            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _veilVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                child: const ColoredBox(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- Marcadores -----------------
  Future<void> _placeMarkers() async {
    if (_controller == null) return;

    // origem (avatar: foto ou iniciais)
    // iOS tends to render markers visually larger; apply a slight downscale.
    final double _platformScale = Platform.isIOS ? 0.85 : 1.0;
    final int size =
        (widget.userMarkerSize * _platformScale).round().clamp(36, 128);
    final Uint8List userBytes = await _makeUserAvatarBytes(
      name: widget.userName ?? 'Você',
      photoUrl: widget.userPhotoUrl,
      diameter: size,
    );
    final nmap.LatLng origem = _gm(widget.latlngOrigem);

    await _addOrUpdateMarker(
      id: 'origem',
      position: origem,
      title: widget.userName ?? 'Você',
      anchorU: 0.5,
      anchorV: 0.5,
      zIndex: 30,
      bytesIcon: userBytes,
    );

    // destino (PNG custom)
    final nmap.LatLng destino = _gm(widget.latlngDestino);
    await _addOrUpdateMarker(
      id: 'destino',
      position: destino,
      title: 'Destino',
      anchorU: 0.5,
      anchorV: 1.0,
      zIndex: 25,
      urlIcon: widget.destinationMarkerPngUrl,
      targetW:
          (widget.destMarkerWidth * _platformScale).round().clamp(24, 128),
    );
  }

  Future<void> _addOrUpdateMarker({
    required String id,
    required nmap.LatLng position,
    String? title,
    required double anchorU,
    required double anchorV,
    required double zIndex,
    Uint8List? bytesIcon,
    String? urlIcon,
    int? targetW,
  }) async {
    if (_markerIds.contains(id)) {
      try {
        await _controller?.updateMarker(id, position: position);
      } catch (_) {}
    } else {
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
        _markerTitle[id] = title ?? '';
      } catch (_) {}
    }
    _markerPos[id] = position;

    if (bytesIcon != null) {
      try {
        final dynamic dc = _controller;
        await dc.setMarkerIconBytes(id: id, bytes: bytesIcon);
      } catch (_) {
        final path = await _writeTempPng(bytesIcon);
        if (path != null) {
          try {
            await _controller?.removeMarker(id);
            _markerIds.remove(id);
            await _controller?.addMarker(nmap.MarkerOptions(
              id: id,
              position: position,
              title: title,
              iconUrl: 'file://$path',
              anchorU: anchorU,
              anchorV: anchorV,
              zIndex: zIndex,
            ));
            _markerIds.add(id);
          } catch (_) {}
        }
      }
    } else if ((urlIcon ?? '').trim().isNotEmpty && targetW != null) {
      await _applyMarkerIconFromUrl(
          id: id,
          url: urlIcon,
          targetW: targetW,
          anchorV: anchorV,
          zIndex: zIndex);
    }
  }

  Future<void> _removeMarker(String id) async {
    if (_markerIds.contains(id)) {
      try {
        await _controller?.removeMarker(id);
      } catch (_) {}
      _markerIds.remove(id);
      _markerPos.remove(id);
      _markerTitle.remove(id);
    }
  }

  // runner dot
  Future<void> _ensureRunner(nmap.LatLng pos) async {
    final int px = 24;
    final Uint8List dot = await _makeDotBytes(
      diameter: px,
      color: widget.strokeColor,
    );
    await _addOrUpdateMarker(
      id: 'runner',
      position: pos,
      title: null,
      anchorU: 0.5,
      anchorV: 0.5,
      zIndex: 26,
      bytesIcon: dot,
    );
  }

  // ----------------- Rota -----------------
  Future<void> _prepareRoute() async {
    _animating = false;
    _headDist = 0;
    _route = [];
    _cumDist = [];
    _totalDist = 0;

    await _removePolyline('route_shadow');
    await _removePolyline('route_progress');

    final a = _gm(widget.latlngOrigem);
    final b = _gm(widget.latlngDestino);
    final key = (widget.googleApiKey ?? '').trim();

    bool ok = false;
    if (key.isNotEmpty) {
      try {
        final res = await nmap.RoutesApi.computeRoutes(
          apiKey: key,
          origin: nmap.Waypoint(location: a),
          destination: nmap.Waypoint(location: b),
          languageCode: 'pt-BR',
          alternatives: false,
        );
        if (res.routes.isNotEmpty) {
          _route = res.routes.first.points
              .map((p) => nmap.LatLng(p.latitude, p.longitude))
              .toList();
          ok = _route.length >= 2;
        }
      } catch (_) {
        ok = false;
      }
    }

    if (!ok) {
      // fallback para Directions v1 (overview_polyline)
      try {
        final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${a.latitude},${a.longitude}'
          '&destination=${b.latitude},${b.longitude}'
          '&mode=driving&language=pt-BR&key=$key',
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

    _route = _decimate(_route, minStepMeters: 5.0, maxPoints: 400);

    _cumDist = List<double>.filled(_route.length, 0.0);
    double acc = 0.0;
    for (int i = 1; i < _route.length; i++) {
      acc += _meters(_route[i - 1], _route[i]);
      _cumDist[i] = acc;
    }
    _totalDist = acc;

    // base inicial (vazia); o ticker vai preenchendo 'route_progress'
    await _updatePolyline(
      id: 'route_shadow',
      points: _route,
      width: (widget.strokeWidth + 2).toDouble().clamp(4, 9),
      color: const Color(0x80000000),
      geodesic: true,
    );
    await _updatePolyline(
      id: 'route_progress',
      points: <nmap.LatLng>[_route.first],
      width: (widget.strokeWidth + 1).toDouble().clamp(3, 8),
      color: widget.strokeColor,
      geodesic: true,
    );

    // duração pela distância
    if (widget.routeAnimationEnabled) {
      final kms = (_totalDist / 1000.0).clamp(0.0, 1e6);
      final ms = (kms * widget.routeAnimMsPerKm)
          .clamp(widget.routeAnimMinMs.toDouble(),
              widget.routeAnimMaxMs.toDouble())
          .round();
      _routeDurationMs = math.max(300, ms);
    } else {
      _routeDurationMs = 300;
    }
  }

  void _startAnimation() {
    if (!widget.routeAnimationEnabled || _route.length < 2) {
      _headDist = _totalDist;
      _animating = false;
      _ticker.stop();
      // desenha tudo de uma vez
      _updatePolyline(
        id: 'route_progress',
        points: _route,
        width: (widget.strokeWidth + 1).toDouble().clamp(3, 8),
        color: widget.strokeColor,
        geodesic: true,
      );
      return;
    }
    _headDist = 0;
    _prevElapsed = Duration.zero;
    _animating = true;
    _ticker.stop();
    _ticker.start();
  }

  Future<void> _animateFinal3DView() async {
    if (_controller == null || _route.length < 2) return;
    final double sampleBack = 120.0;
    final double endD = (_totalDist - sampleBack).clamp(0.0, _totalDist);
    final nmap.LatLng ref = _posAt(endD);
    final nmap.LatLng end = _route.last;
    final double br = _bearing(ref, end);
    try {
      final nmap.LatLng ne = nmap.LatLng(
        math.max(_route.first.latitude, end.latitude),
        math.max(_route.first.longitude, end.longitude),
      );
      final nmap.LatLng sw = nmap.LatLng(
        math.min(_route.first.latitude, end.latitude),
        math.min(_route.first.longitude, end.longitude),
      );
      await _controller!.animateToBounds(ne, sw, padding: widget.fitPadding);
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 150));
    try {
      final dynamic dc = _controller;
      await dc.animateCameraTo(
        target: end,
        zoom: 15.5,
        bearing: br,
        tilt: 42.0,
        durationMs: 900,
      );
    } catch (_) {}
  }

  Future<void> _fitToContent() async {
    if (_controller == null) return;
    final pts = <nmap.LatLng>[];
    if (_route.isNotEmpty) pts.addAll(_route);
    if (_markerPos.containsKey('origem')) pts.add(_markerPos['origem']!);
    if (_markerPos.containsKey('destino')) pts.add(_markerPos['destino']!);
    if (pts.isEmpty) return;

    double minLat = pts.first.latitude, maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;

    for (final p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final ne = nmap.LatLng(maxLat, maxLng);
    final sw = nmap.LatLng(minLat, minLng);
    try {
      await _controller!.animateToBounds(ne, sw, padding: widget.fitPadding);
    } catch (_) {}
  }

  // ----------------- Helpers geom / polyline -----------------
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

    final canInplace = _polylineCanInplaceUpdate[id] ?? true;
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

  int _indexAtDistance(double target) {
    if (_cumDist.isEmpty) return 0;
    int lo = 0, hi = _cumDist.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final v = _cumDist[mid];
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
    if (_route.isEmpty) return _gm(widget.latlngOrigem);
    if (target <= 0) return _route.first;
    if (target >= _totalDist) return _route.last;
    final i = _indexAtDistance(target);
    final i0 = i - 1, i1 = i;
    final d0 = _cumDist[i0], d1 = _cumDist[i1];
    final seg = (d1 - d0) <= 0 ? 1e-6 : (d1 - d0);
    final ft = ((target - d0) / seg).clamp(0.0, 1.0);
    final a = _route[i0], b = _route[i1];
    return nmap.LatLng(
      a.latitude + (b.latitude - a.latitude) * ft,
      a.longitude + (b.longitude - a.longitude) * ft,
    );
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
      points.add(nmap.LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  List<nmap.LatLng> _decimate(List<nmap.LatLng> pts,
      {double minStepMeters = 5.0, int maxPoints = 400}) {
    if (pts.length <= 2) return pts;
    final out = <nmap.LatLng>[];
    nmap.LatLng? last;
    for (final p in pts) {
      if (last == null || _meters(last, p) >= minStepMeters) {
        out.add(p);
        last = p;
      }
    }
    if (out.length <= maxPoints) return out;
    final step = (out.length / maxPoints).ceil();
    final dec = <nmap.LatLng>[];
    for (int i = 0; i < out.length; i += step) dec.add(out[i]);
    if (dec.last != out.last) dec.add(out.last);
    return dec;
  }

  double _meters(nmap.LatLng a, nmap.LatLng b) {
    const R = 6371000.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final la1 = a.latitude * math.pi / 180.0;
    final la2 = b.latitude * math.pi / 180.0;
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * R * math.asin(math.min(1, math.sqrt(h)));
  }

  double _bearing(nmap.LatLng a, nmap.LatLng b) {
    final lat1 = a.latitude * math.pi / 180.0;
    final lat2 = b.latitude * math.pi / 180.0;
    final dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final brng = math.atan2(y, x) * 180.0 / math.pi;
    return (brng + 360.0) % 360.0;
  }

  // ----------------- Ícones -----------------
  bool _looksSvg(String? url) {
    final u = (url ?? '').toLowerCase();
    return u.endsWith('.svg') || u.contains('image/svg');
  }

  Future<Uint8List?> _downloadAndResize(String? url, int targetWidthPx) async {
    final String clean = (url ?? '').trim();
    if (clean.isEmpty || _looksSvg(clean)) return null;
    try {
      final resp =
          await http.get(Uri.parse(clean.replaceFirst('http://', 'https://')));
      if (resp.statusCode < 200 || resp.statusCode >= 300) return null;
      final Uint8List bytes = resp.bodyBytes;
      final ui.Codec codec =
          await ui.instantiateImageCodec(bytes, targetWidth: targetWidthPx);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image img = frame.image;
      final ByteData? out =
          await img.toByteData(format: ui.ImageByteFormat.png);
      if (out == null) return null;
      return out.buffer.asUint8List();
    } catch (_) {
      return null;
    }
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

  Future<void> _applyMarkerIconFromUrl({
    required String id,
    String? url,
    required int targetW,
    required double anchorV,
    required double zIndex,
  }) async {
    if ((url ?? '').trim().isEmpty) return;
    Uint8List? bytes = await _downloadAndResize(url, targetW);
    if (bytes == null) return;
    try {
      final dynamic dc = _controller;
      await dc.setMarkerIconBytes(id: id, bytes: bytes);
    } catch (_) {
      final path = await _writeTempPng(bytes);
      if (path == null) return;
      final nmap.LatLng pos = _markerPos[id] ?? _gm(widget.latlngOrigem);
      final String title = _markerTitle[id] ?? '';
      try {
        if (_markerIds.contains(id)) {
          await _controller?.removeMarker(id);
          _markerIds.remove(id);
        }
        await _controller?.addMarker(nmap.MarkerOptions(
          id: id,
          position: pos,
          title: title.isEmpty ? null : title,
          iconUrl: 'file://$path',
          anchorU: 0.5,
          anchorV: anchorV,
          zIndex: zIndex,
        ));
        _markerIds.add(id);
        _markerPos[id] = pos;
        if (title.isNotEmpty) _markerTitle[id] = title;
      } catch (_) {}
    }
  }

  Future<Uint8List> _makeUserAvatarBytes({
    required String name,
    String? photoUrl,
    int diameter = 64,
  }) async {
    Uint8List? photo;
    if ((photoUrl ?? '').trim().isNotEmpty && !_looksSvg(photoUrl)) {
      photo = await _downloadAndResize(photoUrl, diameter);
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
      final paint = ui.Paint();
      canvas.save();
      canvas.clipPath(ui.Path()..addOval(rect));
      canvas.drawImageRect(
          img,
          ui.Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          rect,
          paint);
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

  String _makeInitials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.take(1).toString() +
            parts.last.characters.take(1).toString())
        .toUpperCase();
  }

  Future<Uint8List> _makeDotBytes({
    required int diameter,
    required Color color,
  }) async {
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    final s = diameter.toDouble();
    final r = s / 2;
    c.drawCircle(
        ui.Offset(r, r),
        r,
        ui.Paint()
          ..color = color
          ..isAntiAlias = true);
    final img = await rec.endRecording().toImage(diameter, diameter);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }
}
