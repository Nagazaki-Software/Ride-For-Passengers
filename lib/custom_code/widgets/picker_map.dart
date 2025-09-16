// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
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
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

import '/flutter_flow/lat_lng.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// PickerMap v9.0-FF — anti-flash real (StaticMaps + SnapshotShield), snake
/// 60fps, sem polygon/param externo, linha bonita.
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
    this.refreshMs = 8000,
    this.routeColor = const Color(0xFFFFC107),
    this.routeWidth = 4,
    this.userMarkerSize = 52,
    this.driverIconWidth = 72,
    this.driverDriverIconAsset,
    this.driverTaxiIconAsset,
    this.driverDriverIconUrl,
    this.driverTaxiIconUrl,
    this.destinationMarkerPngUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png',
    this.borderRadius = 16,
    this.enableRouteSnake = true,
    this.brandSafePaddingBottom = 0,
    this.ultraLowSpecMode = false,
    this.liteModeOnAndroid = false,
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

  final String? driverDriverIconAsset;
  final String? driverTaxiIconAsset;
  final String? driverDriverIconUrl;
  final String? driverTaxiIconUrl;

  final String destinationMarkerPngUrl;
  final double borderRadius;

  final bool enableRouteSnake;
  final double brandSafePaddingBottom;

  final bool ultraLowSpecMode;
  final bool liteModeOnAndroid;

  @override
  State<PickerMap> createState() => _PickerMapState();
}

class _PickerMapState extends State<PickerMap>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // GoogleMap
  gmaps.GoogleMapController? _controller;
  Set<gmaps.Polyline> _polylines = const {};
  Set<gmaps.Marker> _markers = const {};

  // caching ícones
  final Map<String, gmaps.BitmapDescriptor> _iconCache = {};
  gmaps.BitmapDescriptor? _destIcon;
  gmaps.BitmapDescriptor? _userIcon;
  final Map<String, gmaps.BitmapDescriptor> _driverIconByKey = {};
  final Map<String, String> _driverTypeMemo = {};

  // drivers
  final Map<String, StreamSubscription<DocumentSnapshot>> _subs = {};
  final Map<String, gmaps.LatLng> _driverPos = {};
  final Map<String, double> _driverRot = {};
  final Map<String, _DriverAnim> _anims = {};
  final Map<String, int> _lastDriverTickMs = {};

  // rota & snake
  List<gmaps.LatLng> _route = [];
  List<double> _cumDist = [];
  double _totalDist = 0;
  AnimationController? _routeAnim;
  Animation<double>? _routeCurve;
  int _lastRouteCommitMs = 0;
  late final int _SNAKE_FPS_MS;
  late final int _COMMIT_MS;

  // anti-flash
  bool _veilVisible = true; // véu preto inicial
  Uint8List? _staticPng; // Static Maps PNG (pré-render)
  Uint8List? _snapshotShieldBytes; // print do mapa para updates
  bool _shieldOn = false;

  // fit
  bool _fitNeeded = false;

  // cache de rotas
  static final Map<String, List<gmaps.LatLng>> _routeCache = {};

  // camera inicial
  late final gmaps.CameraPosition _initialCamera;

  static const _darkMapStyle = '''
[{"elementType":"geometry","stylers":[{"color":"#212121"}]},
 {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
 {"elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
 {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
 {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#2b2b2b"}]},
 {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1e1e1e"}]},
 {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
 {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
 {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
 {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f2f2f"}]},
 {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}]
''';

  gmaps.LatLng _gm(LatLng p) => gmaps.LatLng(p.latitude, p.longitude);

  @override
  void initState() {
    super.initState();
    _SNAKE_FPS_MS = widget.ultraLowSpecMode ? 32 : 16; // 30/60
    _COMMIT_MS = widget.ultraLowSpecMode ? 32 : 16;

    final center = widget.destination == null
        ? _gm(widget.userLocation)
        : gmaps.LatLng(
            (widget.userLocation.latitude + widget.destination!.latitude) / 2.0,
            (widget.userLocation.longitude + widget.destination!.longitude) /
                2.0,
          );
    _initialCamera = gmaps.CameraPosition(
      target: center,
      zoom: widget.destination == null ? 13.0 : 12.5,
      tilt: 0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Pré-carrega imagem estática (anti-flash de primeiro frame)
      _staticPng = await _tryBuildStaticMapPng();
      setState(() {}); // pinta estático por cima
      _ensureUserMarker();
      _subscribeDrivers();
      _loadRouteAndMaybeAnimate();
    });
  }

  @override
  void didUpdateWidget(covariant PickerMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userLocation != widget.userLocation ||
        oldWidget.userPhotoUrl != widget.userPhotoUrl ||
        oldWidget.userName != widget.userName ||
        oldWidget.userMarkerSize != widget.userMarkerSize) {
      _userIcon = null;
      _ensureUserMarker();
      _markDirty();
      _requestFit();
    }

    if (oldWidget.destination != widget.destination ||
        oldWidget.googleApiKey != widget.googleApiKey ||
        oldWidget.routeWidth != widget.routeWidth ||
        oldWidget.routeColor != widget.routeColor ||
        oldWidget.enableRouteSnake != widget.enableRouteSnake) {
      _applyShield(asyncWork: _loadRouteAndMaybeAnimate);
      // Atualiza também a imagem estática (para um reveal perfeito)
      _refreshStaticLater();
    }

    if (oldWidget.driversRefs != widget.driversRefs ||
        oldWidget.driverIconWidth != widget.driverIconWidth ||
        oldWidget.driverDriverIconAsset != widget.driverDriverIconAsset ||
        oldWidget.driverTaxiIconAsset != widget.driverTaxiIconAsset ||
        oldWidget.driverDriverIconUrl != widget.driverDriverIconUrl ||
        oldWidget.driverTaxiIconUrl != widget.driverTaxiIconUrl) {
      _driverIconByKey.clear();
      _subscribeDrivers();
    }

    if (oldWidget.brandSafePaddingBottom != widget.brandSafePaddingBottom) {
      _markDirty();
      _requestFit();
    }
  }

  @override
  void dispose() {
    for (final a in _anims.values) {
      a.dispose();
    }
    _anims.clear();
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
    _routeCurve?.removeListener(_onSnakeTick);
    _routeAnim?.dispose();
    super.dispose();
  }

  // ------------- util -------------
  void _markDirty() {
    Future<void>.delayed(Duration(milliseconds: _COMMIT_MS), () {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _requestFit() {
    _fitNeeded = true;
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      _maybeFitNow();
    });
  }

  Future<void> _maybeFitNow({double padding = 60}) async {
    if (_controller == null || _veilVisible || _shieldOn) return;
    if (!_fitNeeded) return;
    _fitNeeded = false;

    final pts = <gmaps.LatLng>[];
    for (final pl in _polylines) pts.addAll(pl.points);
    for (final m in _markers) pts.add(m.position);
    if (pts.isEmpty) return;

    double minLat = pts.first.latitude, maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = (minLat == maxLat || minLng == maxLng)
        ? gmaps.LatLngBounds(
            southwest: gmaps.LatLng(minLat - 0.001, minLng - 0.001),
            northeast: gmaps.LatLng(maxLat + 0.001, maxLng + 0.001),
          )
        : gmaps.LatLngBounds(
            southwest: gmaps.LatLng(minLat, minLng),
            northeast: gmaps.LatLng(maxLat, maxLng),
          );

    try {
      await _controller!
          .animateCamera(gmaps.CameraUpdate.newLatLngBounds(bounds, padding));
    } catch (_) {
      Future<void>.delayed(const Duration(milliseconds: 150), () async {
        if (!mounted || _controller == null) return;
        try {
          await _controller!.animateCamera(
              gmaps.CameraUpdate.newLatLngBounds(bounds, padding));
        } catch (_) {}
      });
    }
  }

  Future<void> _applyShield(
      {required Future<void> Function() asyncWork}) async {
    try {
      final bytes = await _controller?.takeSnapshot();
      if (bytes != null) {
        _snapshotShieldBytes = bytes;
        _shieldOn = true;
        setState(() {});
      }
    } catch (_) {}
    await asyncWork();
    await _waitTilesReady(maxTries: 10, intervalMs: 120);
    if (!mounted) return;
    _shieldOn = false;
    _snapshotShieldBytes = null;
    setState(() {});
  }

  Future<void> _waitTilesReady(
      {int maxTries = 12, int intervalMs = 120}) async {
    int ok = 0;
    for (int i = 0; i < maxTries; i++) {
      try {
        final r = await _controller?.getVisibleRegion();
        if (r != null) {
          final valid = r.northeast.latitude != r.southwest.latitude ||
              r.northeast.longitude != r.southwest.longitude;
          if (valid) ok++;
          if (ok >= 2) break;
        }
      } catch (_) {}
      await Future<void>.delayed(Duration(milliseconds: intervalMs));
    }
  }

  // ------------- Static Maps -------------
  Future<void> _refreshStaticLater() async {
    // dá um respiro pra câmera/rota atualizarem
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _staticPng = await _tryBuildStaticMapPng();
    if (mounted) setState(() {});
  }

  Future<Uint8List?> _tryBuildStaticMapPng() async {
    final key = (widget.googleApiKey ?? '').trim();
    if (key.isEmpty) return null;

    // tamanho padrão (ajusta automático pelo LayoutBuilder mais tarde)
    final w = 640, h = 360;
    final center = widget.destination == null
        ? '${widget.userLocation.latitude},${widget.userLocation.longitude}'
        : '${(widget.userLocation.latitude + widget.destination!.latitude) / 2},'
            '${(widget.userLocation.longitude + widget.destination!.longitude) / 2}';
    final zoom = widget.destination == null ? 13 : 12;

    // estilo escuro equivalente
    final style = [
      'element:geometry|color:0x212121',
      'feature:road|element:geometry|color:0x2c2c2c',
      'feature:water|element:geometry|color:0x000000',
      'feature:poi|element:geometry|color:0x2b2b2b',
      'feature:road.arterial|element:geometry|color:0x373737',
      'feature:road.highway|element:geometry|color:0x3c3c3c',
      'feature:transit|element:geometry|color:0x2f2f2f',
      'element:labels.text.fill|color:0x9e9e9e',
      'element:labels.text.stroke|color:0x212121',
    ].map((s) => 'style=${Uri.encodeComponent(s)}').join('&');

    final markers = <String>[
      // user
      'markers=size:mid|color:0xFFC107|${widget.userLocation.latitude},${widget.userLocation.longitude}',
      // dest (se houver)
      if (widget.destination != null)
        'markers=size:mid|color:0xFFEA4335|${widget.destination!.latitude},${widget.destination!.longitude}',
    ].join('&');

    final url =
        'https://maps.googleapis.com/maps/api/staticmap?center=$center&zoom=$zoom'
        '&size=${w}x$h&scale=2&$markers&$style&key=$key';

    try {
      final r = await http.get(Uri.parse(url));
      if (r.statusCode >= 200 && r.statusCode < 300) return r.bodyBytes;
    } catch (_) {}
    return null;
  }

  // ------------- ícones -------------
  String _initials(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '•';
    final parts = n.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    final a = parts[0][0];
    final b = parts.length > 1
        ? parts[1][0]
        : (parts[0].length > 1 ? parts[0][1] : a);
    return (a + b).toUpperCase();
  }

  Future<Uint8List?> _fetchBytes(String rawUrl) async {
    if (rawUrl.trim().isEmpty) return null;
    var url = rawUrl.trim();
    if (url.startsWith('http://'))
      url = url.replaceFirst('http://', 'https://');
    try {
      final r = await http.get(Uri.parse(url));
      if (r.statusCode >= 200 && r.statusCode < 300) return r.bodyBytes;
    } catch (_) {}
    return null;
  }

  Future<gmaps.BitmapDescriptor> _buildUserAvatar({
    required int size,
    required String? photoUrl,
    required String initials,
    Color borderColor = const Color(0xFFFFC107),
    Color bg = const Color(0xFF212121),
    Color txt = Colors.white,
  }) async {
    final key = 'userAvatar::$size::$photoUrl::$initials';
    if (_iconCache.containsKey(key)) return _iconCache[key]!;

    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    final s = size.toDouble(), r = s / 2;

    c.drawCircle(
        ui.Offset(r, r),
        r,
        ui.Paint()
          ..color = bg
          ..isAntiAlias = true);

    bool drewPhoto = false;
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      final bytes = await _fetchBytes(photoUrl);
      if (bytes != null) {
        try {
          final codec = await ui.instantiateImageCodec(bytes,
              targetWidth: size, targetHeight: size);
          final frame = await codec.getNextFrame();
          final img = frame.image;
          c.save();
          final clip = ui.Path()
            ..addOval(ui.Rect.fromCircle(center: ui.Offset(r, r), radius: r));
          c.clipPath(clip);
          c.drawImageRect(
            img,
            ui.Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
            ui.Rect.fromLTWH(0, 0, s, s),
            ui.Paint()..isAntiAlias = true,
          );
          c.restore();
          drewPhoto = true;
        } catch (_) {}
      }
    }

    if (!drewPhoto) {
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w700,
          fontSize: s * 0.38))
        ..pushStyle(ui.TextStyle(color: txt))
        ..addText(initials);
      final para = pb.build()..layout(ui.ParagraphConstraints(width: s));
      c.drawParagraph(para, ui.Offset(0, (s - para.height) / 2));
    }

    final b = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = math.max(3.0, s * 0.06)
      ..color = borderColor
      ..isAntiAlias = true;
    c.drawCircle(ui.Offset(r, r), r - b.strokeWidth / 2, b);

    final img = await rec.endRecording().toImage(size, size);
    final data = (await img.toByteData(format: ui.ImageByteFormat.png))!;
    final desc = gmaps.BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    _iconCache[key] = desc;
    return desc;
  }

  Future<gmaps.BitmapDescriptor> _bitmapFromAsset({
    required String assetPath,
    required int targetWidth,
  }) async {
    final key = 'asset::$assetPath::$targetWidth';
    if (_iconCache.containsKey(key)) return _iconCache[key]!;
    final data = await DefaultAssetBundle.of(context).load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: targetWidth);
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!;
    final desc = gmaps.BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
    _iconCache[key] = desc;
    return desc;
  }

  Future<gmaps.BitmapDescriptor> _bitmapFromUrl({
    required String url,
    required int targetWidth,
    required String type,
  }) async {
    final key = 'url::$url::$targetWidth';
    if (_iconCache.containsKey(key)) return _iconCache[key]!;
    final bytes = await _fetchBytes(url);
    if (bytes == null) {
      return await _buildUserAvatar(
        size: targetWidth,
        photoUrl: null,
        initials: type == 'taxi' ? 'TX' : (type == 'driver' ? 'DR' : '•'),
        borderColor: widget.routeColor,
      );
    }
    final codec =
        await ui.instantiateImageCodec(bytes, targetWidth: targetWidth);
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final data = (await img.toByteData(format: ui.ImageByteFormat.png))!;
    final desc = gmaps.BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    _iconCache[key] = desc;
    return desc;
  }

  Future<gmaps.BitmapDescriptor> _pngIconFromUrl(String url,
      {int width = 108}) async {
    return _bitmapFromUrl(url: url, targetWidth: width, type: 'dest');
  }

  // ------------- rota -------------
  List<gmaps.LatLng> _decodePolyline(String encoded) {
    final List<gmaps.LatLng> points = [];
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
      points.add(gmaps.LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  List<gmaps.LatLng> _decimate(List<gmaps.LatLng> pts,
      {double minStepMeters = 4.0, int maxPoints = 420}) {
    if (widget.ultraLowSpecMode) {
      minStepMeters = 6.0;
      maxPoints = 300;
    }
    if (pts.length <= 2) return pts;
    final out = <gmaps.LatLng>[];
    gmaps.LatLng? last;
    for (final p in pts) {
      if (last == null || _meters(last, p) >= minStepMeters) {
        out.add(p);
        last = p;
      }
    }
    if (out.length <= maxPoints) return out;
    final step = (out.length / maxPoints).ceil();
    final dec = <gmaps.LatLng>[];
    for (int i = 0; i < out.length; i += step) dec.add(out[i]);
    if (dec.last != out.last) dec.add(out.last);
    return dec;
  }

  void _buildCumDist(List<gmaps.LatLng> pts) {
    _cumDist = List<double>.filled(pts.length, 0.0);
    double acc = 0.0;
    for (int i = 1; i < pts.length; i++) {
      acc += _meters(pts[i - 1], pts[i]);
      _cumDist[i] = acc;
    }
    _totalDist = acc;
  }

  int _indexAtDistance(double target) {
    int lo = 0, hi = _cumDist.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final v = _cumDist[mid];
      if (v < target)
        lo = mid + 1;
      else
        hi = mid - 1;
    }
    return lo.clamp(1, _cumDist.length - 1);
  }

  double _meters(gmaps.LatLng a, gmaps.LatLng b) {
    const R = 6371000.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final la1 = a.latitude * math.pi / 180.0;
    final la2 = b.latitude * math.pi / 180.0;
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * R * math.asin(math.min(1, math.sqrt(h)));
  }

  Future<List<gmaps.LatLng>> _fetchDrivingRoute(
      gmaps.LatLng origin, gmaps.LatLng dest) async {
    final key = (widget.googleApiKey ?? '').trim();
    final cacheKey =
        '${origin.latitude},${origin.longitude}|${dest.latitude},${dest.longitude}|$key';
    if (_routeCache.containsKey(cacheKey)) return _routeCache[cacheKey]!;

    if (key.isEmpty) {
      final fb = <gmaps.LatLng>[origin, dest];
      _routeCache[cacheKey] = fb;
      return fb;
    }

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${dest.latitude},${dest.longitude}'
      '&mode=driving&language=pt-BR&key=$key',
    );

    try {
      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        final fb = <gmaps.LatLng>[origin, dest];
        _routeCache[cacheKey] = fb;
        return fb;
      }
      final data = json.decode(resp.body) as Map<String, dynamic>;
      if ((data['status'] ?? '') != 'OK') {
        final fb = <gmaps.LatLng>[origin, dest];
        _routeCache[cacheKey] = fb;
        return fb;
      }
      final routes = (data['routes'] as List?) ?? const [];
      if (routes.isEmpty) {
        final fb = <gmaps.LatLng>[origin, dest];
        _routeCache[cacheKey] = fb;
        return fb;
      }
      final overview = routes.first['overview_polyline']?['points']?.toString();
      if (overview == null || overview.isEmpty) {
        final fb = <gmaps.LatLng>[origin, dest];
        _routeCache[cacheKey] = fb;
        return fb;
      }
      final pts = _decimate(_decodePolyline(overview));
      _routeCache[cacheKey] = pts;
      return pts;
    } catch (_) {
      final fb = <gmaps.LatLng>[origin, dest];
      _routeCache[cacheKey] = fb;
      return fb;
    }
  }

  // ------------- drivers -------------
  double _bearing(gmaps.LatLng a, gmaps.LatLng b) {
    final lat1 = a.latitude * math.pi / 180.0;
    final lat2 = b.latitude * math.pi / 180.0;
    final dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final brng = math.atan2(y, x) * 180.0 / math.pi;
    return (brng + 360.0) % 360.0;
  }

  double _bearingLerp(double a, double b, double t) {
    final diff = ((b - a + 540) % 360) - 180;
    return (a + diff * t + 360) % 360;
  }

  String _driverTypeFromData(String id, Map<String, dynamic>? data) {
    dynamic raw =
        (data?['users'] is Map) ? (data?['users']?['plataform']) : null;
    raw ??= data?['plataform'];
    raw ??= data?['platform'];
    raw ??= data?['type'];
    final List<String> items = (raw is List)
        ? raw.map((e) => e?.toString() ?? '').toList()
        : raw is String
            ? [raw]
            : <String>[];
    final hasTaxi = items.any((s) => s.toLowerCase().contains('taxi'));
    final hasDriver = items.any((s) => s.toLowerCase().contains('driver'));
    final resolved = hasTaxi
        ? 'taxi'
        : (hasDriver ? 'driver' : (_driverTypeMemo[id] ?? 'driver'));
    _driverTypeMemo[id] = resolved;
    return resolved;
  }

  Future<gmaps.BitmapDescriptor> _getDriverIconFor(String type) async {
    final width = widget.driverIconWidth.clamp(36, 128);
    final url =
        (type == 'taxi' ? widget.driverTaxiIconUrl : widget.driverDriverIconUrl)
            ?.trim();
    final asset = (type == 'taxi'
            ? widget.driverTaxiIconAsset
            : widget.driverDriverIconAsset)
        ?.trim();

    final key =
        'driverIcon::$type::${url ?? ''}::${asset ?? ''}::$width::${widget.routeColor.value}';
    if (_driverIconByKey.containsKey(key)) return _driverIconByKey[key]!;

    gmaps.BitmapDescriptor desc;
    if (url != null && url.isNotEmpty) {
      desc = await _bitmapFromUrl(url: url, targetWidth: width, type: type);
    } else if (asset != null && asset.isNotEmpty && mounted) {
      desc = await _bitmapFromAsset(assetPath: asset, targetWidth: width);
    } else {
      desc = await _buildUserAvatar(
        size: width,
        photoUrl: null,
        initials: type == 'taxi' ? 'TX' : 'DR',
        borderColor:
            type == 'taxi' ? const Color(0xFFFFC107) : widget.routeColor,
      );
    }

    _driverIconByKey[key] = desc;
    return desc;
  }

  void _subscribeDrivers() {
    for (final a in _anims.values) {
      a.dispose();
    }
    _anims.clear();
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();

    final refs = widget.driversRefs;
    if (refs == null) return;

    for (final ref in refs) {
      final id = ref.id;
      _subs[id] = ref.snapshots().listen((snap) async {
        if (!mounted) return;

        if (!snap.exists) {
          final nextMarkers = Set<gmaps.Marker>.from(_markers)
            ..removeWhere((m) => m.markerId.value == 'driver_$id');
          if (nextMarkers.length != _markers.length) {
            _markers = nextMarkers;
            _markDirty();
          }
          _driverPos.remove(id);
          _driverRot.remove(id);
          _driverTypeMemo.remove(id);
          _anims.remove(id)?.dispose();
          return;
        }

        final data = snap.data() as Map<String, dynamic>?;
        gmaps.LatLng? newPos;
        final loc = data?['location'];
        if (loc is GeoPoint) {
          newPos = gmaps.LatLng(loc.latitude, loc.longitude);
        } else {
          final lat = (data?['lat'] as num?)?.toDouble();
          final lng = (data?['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) newPos = gmaps.LatLng(lat, lng);
        }
        if (newPos == null) return;

        final type = _driverTypeFromData(id, data);
        final icon = await _getDriverIconFor(type);

        final last = _driverPos[id];
        final lastRot = _driverRot[id] ?? 0;

        if (last == null) {
          _driverPos[id] = newPos;
          _driverRot[id] = lastRot;
          _upsertDriverMarker(id, newPos, lastRot, icon,
              title: (data?['display_name'] ?? 'Driver').toString());
          _markDirty();
          _requestFit();
          return;
        }

        final dist = _meters(last, newPos);
        if (dist < 0.6) return;

        final targetRot = _bearing(last, newPos);
        final durMs =
            (dist.clamp(8, 90).toDouble() * 10 + 280).clamp(280, 1100).toInt();

        _anims[id]?.dispose();
        final anim = _DriverAnim(
          vsync: this,
          from: last,
          to: newPos,
          fromRot: lastRot,
          toRot: targetRot,
          duration: Duration(milliseconds: durMs),
          curve: Curves.easeOutCubic,
          minFrameMs: widget.ultraLowSpecMode ? 32 : 16,
          onTick: (pos, rot) {
            final now = DateTime.now().millisecondsSinceEpoch;
            final lastMs = _lastDriverTickMs[id] ?? 0;
            final cap =
                widget.ultraLowSpecMode ? 28 : 14; // ~35fps vs ~70fps cap
            if (now - lastMs < cap) return;
            _lastDriverTickMs[id] = now;

            _driverPos[id] = pos;
            _driverRot[id] = rot;
            _upsertDriverMarker(id, pos, rot, icon,
                title: (data?['display_name'] ?? 'Driver').toString());
            _markDirty();
          },
          bearingLerp: _bearingLerp,
        );
        _anims[id] = anim;
        anim.start();
      });
    }
  }

  void _upsertDriverMarker(
      String id, gmaps.LatLng pos, double rotation, gmaps.BitmapDescriptor icon,
      {required String title}) {
    final marker = gmaps.Marker(
      markerId: gmaps.MarkerId('driver_$id'),
      position: pos,
      zIndex: 22,
      icon: icon,
      anchor: const Offset(0.5, 0.62),
      rotation: rotation,
      flat: true,
      infoWindow: gmaps.InfoWindow(title: title),
    );
    final next = Set<gmaps.Marker>.from(_markers)
      ..removeWhere((m) => m.markerId.value == 'driver_$id')
      ..add(marker);
    _markers = next;
  }

  // ------------- snake -------------
  gmaps.LatLng _posAt(double t) {
    if (_route.isEmpty) return _gm(widget.userLocation);
    if (t <= 0) return _route.first;
    if (t >= 1) return _route.last;
    final target = t * _totalDist;
    final i = _indexAtDistance(target);
    final i0 = (i - 1).clamp(0, _route.length - 2);
    final i1 = i0 + 1;
    final d0 = _cumDist[i0], d1 = _cumDist[i1];
    final seg = (d1 - d0).clamp(1e-6, double.infinity);
    final ft = ((target - d0) / seg).clamp(0.0, 1.0);
    final a = _route[i0], b = _route[i1];
    return gmaps.LatLng(
      a.latitude + (b.latitude - a.latitude) * ft,
      a.longitude + (b.longitude - a.longitude) * ft,
    );
  }

  void _onSnakeTick() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastRouteCommitMs < _SNAKE_FPS_MS) return;
    _lastRouteCommitMs = now;

    final t = _routeCurve!.value;
    final pos = _posAt(t);
    final target = t * _totalDist;
    final k = _indexAtDistance(target);

    final vis = List<gmaps.LatLng>.from(_route.getRange(0, k))..add(pos);

    final bgId = const gmaps.PolylineId('route_bg');
    final mainId = const gmaps.PolylineId('route_main');

    final next = Set<gmaps.Polyline>.from(_polylines)
      ..removeWhere((pl) => pl.polylineId == mainId);

    next.add(gmaps.Polyline(
      polylineId: mainId,
      points: vis,
      width: widget.routeWidth.clamp(3, 7),
      color: widget.routeColor,
      zIndex: 8,
      startCap: gmaps.Cap.roundCap,
      endCap: gmaps.Cap.roundCap,
      jointType: gmaps.JointType.round,
      geodesic: true, // deixa a linha bonita
    ));

    // mantém bg inteiro (não pisca)
    if (!next.any((pl) => pl.polylineId == bgId)) {
      next.add(gmaps.Polyline(
        polylineId: bgId,
        points: _route,
        width: (widget.routeWidth + 2).clamp(4, 9),
        color: widget.routeColor.withOpacity(0.30),
        zIndex: 7,
        startCap: gmaps.Cap.roundCap,
        endCap: gmaps.Cap.roundCap,
        jointType: gmaps.JointType.round,
        geodesic: true,
      ));
    }

    _polylines = next;
    _markDirty();
  }

  void _startSnake() {
    if (!widget.enableRouteSnake || _route.length < 2) return;

    final dist = _totalDist;
    final durMs = (1500 + (dist / 1200) * 2400).clamp(1500, 5200).toInt();

    _routeAnim ??= AnimationController(vsync: this);
    _routeAnim!.duration = Duration(milliseconds: durMs);

    _routeCurve?.removeListener(_onSnakeTick);
    _routeCurve =
        CurvedAnimation(parent: _routeAnim!, curve: Curves.easeInOutCubic)
          ..addListener(_onSnakeTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _routeAnim!
        ..reset()
        ..forward(from: 0);
    });
  }

  Future<void> _loadRouteAndMaybeAnimate() async {
    // reset anima
    _routeAnim?.stop();
    _routeCurve?.removeListener(_onSnakeTick);
    _routeAnim?.reset();

    _route = [];
    _cumDist = [];
    _totalDist = 0;

    final dest = widget.destination;
    if (dest == null) {
      _polylines = Set<gmaps.Polyline>.from(_polylines)
        ..removeWhere((pl) => pl.polylineId.value.startsWith('route_'));
      _markers = Set<gmaps.Marker>.from(_markers)
        ..removeWhere((m) => m.markerId.value == 'dest');
      _markDirty();
      return;
    }

    final origin = _gm(widget.userLocation);
    final d = _gm(dest);

    final pts = await _fetchDrivingRoute(origin, d);
    _route = _decimate(pts);
    if (_route.length < 2) {
      _polylines = Set<gmaps.Polyline>.from(_polylines)
        ..removeWhere((pl) => pl.polylineId.value.startsWith('route_'));
      _markDirty();
      return;
    }
    _buildCumDist(_route);

    _destIcon ??=
        await _pngIconFromUrl(widget.destinationMarkerPngUrl, width: 108);
    _markers = Set<gmaps.Marker>.from(_markers)
      ..removeWhere((m) => m.markerId.value == 'dest')
      ..add(gmaps.Marker(
        markerId: const gmaps.MarkerId('dest'),
        position: d,
        icon: _destIcon!,
        anchor: const Offset(0.5, 1.0),
        zIndex: 25,
        infoWindow: const gmaps.InfoWindow(title: 'Destino'),
      ));

    // BG estático (rota inteira)
    final bg = gmaps.Polyline(
      polylineId: const gmaps.PolylineId('route_bg'),
      points: _route,
      width: (widget.routeWidth + 2).clamp(4, 9),
      color: widget.routeColor.withOpacity(0.30),
      zIndex: 7,
      startCap: gmaps.Cap.roundCap,
      endCap: gmaps.Cap.roundCap,
      jointType: gmaps.JointType.round,
      geodesic: true,
    );

    // Snake começa curtinha
    final main = gmaps.Polyline(
      polylineId: const gmaps.PolylineId('route_main'),
      points: [_route.first, _route.first],
      width: widget.routeWidth.clamp(3, 7),
      color: widget.routeColor,
      zIndex: 8,
      startCap: gmaps.Cap.roundCap,
      endCap: gmaps.Cap.roundCap,
      jointType: gmaps.JointType.round,
      geodesic: true,
    );

    _polylines = {
      ..._polylines.where((pl) => !pl.polylineId.value.startsWith('route_')),
      bg,
      main,
    };

    _markDirty();
    _requestFit();
    _startSnake();
  }

  // ------------- UI -------------
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final width = widget.width ?? double.infinity;
    final height = widget.height ?? 320;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.black)),

            gmaps.GoogleMap(
              key: const PageStorageKey('PickerMap_gm'),
              initialCameraPosition: _initialCamera,
              polylines: _polylines,
              markers: _markers,
              compassEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              buildingsEnabled: false,
              indoorViewEnabled: false,
              trafficEnabled: false,
              mapToolbarEnabled: false,
              liteModeEnabled:
                  Platform.isAndroid ? widget.liteModeOnAndroid : false,
              padding: EdgeInsets.only(bottom: widget.brandSafePaddingBottom),
              onMapCreated: (c) async {
                _controller = c;
                try {
                  await c.setMapStyle(_darkMapStyle);
                } catch (_) {}

                // Dá uma cutucada e espera tiles pra revelar
                try {
                  await c.moveCamera(gmaps.CameraUpdate.scrollBy(1, 0));
                  await Future<void>.delayed(const Duration(milliseconds: 60));
                  await c.moveCamera(gmaps.CameraUpdate.scrollBy(-1, 0));
                } catch (_) {}

                await _waitTilesReady(maxTries: 12, intervalMs: 120);
                if (!mounted) return;
                setState(() => _veilVisible = false);
                // Tira o estático da frente
                if (_staticPng != null) setState(() => _staticPng = null);
                _requestFit();
              },
              onCameraIdle: () {
                _maybeFitNow();
              },
              mapType: gmaps.MapType.normal,
            ),

            // SnapshotShield durante updates pesados (zero flash)
            if (_shieldOn && _snapshotShieldBytes != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Image.memory(
                    _snapshotShieldBytes!,
                    gaplessPlayback: true,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Static Maps cobrindo o primeiro frame (sem branco)
            if (_staticPng != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Image.memory(
                    _staticPng!,
                    gaplessPlayback: true,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // véu preto só até os tiles escuros aparecerem
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _veilVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                child: const ColoredBox(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------- user marker --------
  Future<void> _ensureUserMarker() async {
    _userIcon ??= await _buildUserAvatar(
      size: widget.userMarkerSize,
      photoUrl: widget.userPhotoUrl,
      initials: _initials(widget.userName),
    );

    final userPos = _gm(widget.userLocation);
    final userMarker = gmaps.Marker(
      markerId: const gmaps.MarkerId('user'),
      position: userPos,
      icon: _userIcon!,
      zIndex: 30,
      anchor: const Offset(0.5, 0.5),
      flat: true,
      infoWindow: const gmaps.InfoWindow(title: 'Você'),
    );

    final next = Set<gmaps.Marker>.from(_markers)
      ..removeWhere((x) => x.markerId.value == 'user')
      ..add(userMarker);
    _markers = next;
  }
}

/// anima driver com frame-skip adaptativo
class _DriverAnim {
  _DriverAnim({
    required TickerProvider vsync,
    required this.from,
    required this.to,
    required this.fromRot,
    required this.toRot,
    required Duration duration,
    required Curve curve,
    required this.onTick,
    required this.bearingLerp,
    this.minFrameMs = 16,
  })  : _ctrl = AnimationController(vsync: vsync, duration: duration),
        _curve = curve {
    _anim = CurvedAnimation(parent: _ctrl, curve: _curve)
      ..addListener(() {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastMs < minFrameMs) return;
        _lastMs = now;

        final t = _anim.value;
        final lat = _lerp(from.latitude, to.latitude, t);
        final lng = _lerp(from.longitude, to.longitude, t);
        final rot = bearingLerp(fromRot, toRot, t);
        onTick(gmaps.LatLng(lat, lng), rot);
      });
  }

  final gmaps.LatLng from;
  final gmaps.LatLng to;
  final double fromRot;
  final double toRot;
  final void Function(gmaps.LatLng pos, double rotation) onTick;
  final double Function(double a, double b, double t) _lerp = _numLerp;
  final double Function(double a, double b, double t) bearingLerp;
  final Curve _curve;
  final int minFrameMs;

  late final AnimationController _ctrl;
  late final CurvedAnimation _anim;
  int _lastMs = 0;

  void start() {
    _ctrl
      ..reset()
      ..forward(from: 0);
  }

  void dispose() {
    _ctrl.dispose();
  }

  static double _numLerp(double a, double b, double t) => a + (b - a) * t;
}
