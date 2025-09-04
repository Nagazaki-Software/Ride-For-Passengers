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

// Flutter / Dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

// Firebase / Maps
import '/flutter_flow/lat_lng.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// PickerMap v7.6-FF — menos jank, sem azul do nada, rota dupla + throttle
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

    // Mantido p/ compat
    this.refreshMs = 8000,

    // Estilo da rota
    this.routeColor = const Color(0xFFFFC107),
    this.routeWidth = 4,
    this.userMarkerSize = 52,

    /// Largura do bitmap do ícone do driver (px).
    this.driverIconWidth = 72,

    /// Assets opcionais (driver/taxi)
    this.driverDriverIconAsset,
    this.driverTaxiIconAsset,

    /// URLs dos ícones (driver/taxi) – ex: Firebase Storage
    this.driverDriverIconUrl,
    this.driverTaxiIconUrl,

    /// Marcador de destino (URL PNG)
    this.destinationMarkerPngUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png',
    this.borderRadius = 16,
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

  // Ícones por origem
  final String? driverDriverIconAsset;
  final String? driverTaxiIconAsset;
  final String? driverDriverIconUrl;
  final String? driverTaxiIconUrl;

  final String destinationMarkerPngUrl;
  final double borderRadius;

  @override
  State<PickerMap> createState() => _PickerMapState();
}

class _PickerMapState extends State<PickerMap> with TickerProviderStateMixin {
  final _polylines = <gmaps.Polyline>{};
  final _markers = <gmaps.Marker>{};
  gmaps.GoogleMapController? _controller;

  // cache de ícones
  final Map<String, gmaps.BitmapDescriptor> _iconCache = {};
  gmaps.BitmapDescriptor? _destIcon;
  gmaps.BitmapDescriptor? _userIcon;

  // Ícone do driver por (tipo+tamanho+fonte)
  final Map<String, gmaps.BitmapDescriptor> _driverIconByKey = {};
  final Map<String, String> _driverTypeMemo = {}; // fixa tipo por driver

  // subs/estado dos drivers
  final Map<String, StreamSubscription<DocumentSnapshot>> _subs = {};
  final Map<String, gmaps.LatLng> _driverPos = {};
  final Map<String, double> _driverRot = {};
  final Map<String, _DriverAnim> _anims = {};
  final Map<String, int> _lastDriverTickMs = {}; // throttle por driver

  // rota + animação snake
  List<gmaps.LatLng> _route = [];
  List<gmaps.LatLng> _visibleRoute = [];
  List<double> _cumDist = [];
  double _totalDist = 0;

  AnimationController? _routeAnim;
  Animation<double>? _routeCurve;
  Timer? _routeFailSafe; // <- garante linha mesmo se animação falhar
  int _lastRouteMs = 0; // throttle 30fps

  // véu preto enquanto renderiza
  bool _veilVisible = true;
  bool _styleReady = false;
  bool _firstIdle = false;

  // debounce de “fit to content”
  bool _pendingFit = false;
  bool _mapReady = false;

  static const _darkMapStyle = '''
[{"elementType":"geometry","stylers":[{"color":"#212121"}]},
 {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
 {"elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
 {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
 {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
 {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
 {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
 {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f2f2f"}]},
 {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}]
''';

  gmaps.LatLng _gm(LatLng p) => gmaps.LatLng(p.latitude, p.longitude);

  // ---------------- ÍCONES ----------------

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
    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'https://'); // iOS ATS
    }
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
    final rect = ui.Rect.fromLTWH(0, 0, s, s);

    // fundo
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
              ui.Rect.fromLTWH(
                  0, 0, img.width.toDouble(), img.height.toDouble()),
              rect,
              ui.Paint()..isAntiAlias = true);
          c.restore();
          drewPhoto = true;
        } catch (_) {}
      }
    }

    if (!drewPhoto) {
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontWeight: FontWeight.w700,
        fontSize: s * 0.38,
      ))
        ..pushStyle(ui.TextStyle(color: txt))
        ..addText(initials);
      final para = pb.build()..layout(ui.ParagraphConstraints(width: s));
      c.drawParagraph(para, ui.Offset(0, (s - para.height) / 2));
    }

    // borda
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

  // Fallback desenhado (cor seguindo a rota)
  Future<gmaps.BitmapDescriptor> _buildFallbackCar({
    required int width,
    required String type, // "driver" | "taxi"
    Color? bodyColor,
  }) async {
    final cBody = bodyColor ??
        (type == 'taxi' ? const Color(0xFFFFC107) : widget.routeColor);
    final key = 'fallbackCar::$type::$width::${cBody.value}';
    if (_driverIconByKey.containsKey(key)) return _driverIconByKey[key]!;

    final w = width.toDouble();
    final h = (width * 1.9).toDouble();
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);

    // Sombra barata
    c.drawOval(
      ui.Rect.fromCenter(
          center: ui.Offset(w * .50, h * .88), width: w * .70, height: h * .16),
      ui.Paint()..color = const Color(0x40000000),
    );

    final stroke = const Color(0xFF0F0F0F);

    // Corpo
    final bodyR = ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(w * 0.10, h * 0.10, w * 0.80, h * 0.78),
      ui.Radius.circular(w * 0.36),
    );
    c.drawRRect(bodyR, ui.Paint()..color = cBody);
    c.drawRRect(
        bodyR,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = w * 0.08
          ..color = stroke);

    // Para-brisa
    final glass = ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(w * 0.26, h * 0.18, w * 0.48, h * 0.20),
      ui.Radius.circular(w * 0.18),
    );
    c.drawRRect(glass, ui.Paint()..color = const Color(0xCC2B6FFF));

    // Rodas
    final wheelPaint = ui.Paint()..color = stroke;
    final rw = w * 0.14;
    c.drawCircle(ui.Offset(w * 0.24, h * 0.70), rw, wheelPaint);
    c.drawCircle(ui.Offset(w * 0.76, h * 0.70), rw, wheelPaint);

    // Plaqueta táxi
    if (type == 'taxi') {
      final signR = ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(w * 0.40, h * 0.02, w * 0.20, h * 0.10),
        ui.Radius.circular(w * 0.08),
      );
      c.drawRRect(signR, ui.Paint()..color = Colors.white);
      c.drawRRect(
          signR,
          ui.Paint()
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = w * 0.02
            ..color = stroke);
    }

    final img = await rec.endRecording().toImage(w.toInt(), h.toInt());
    final data = (await img.toByteData(format: ui.ImageByteFormat.png))!;
    final desc = gmaps.BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    _driverIconByKey[key] = desc;
    return desc;
  }

  Future<gmaps.BitmapDescriptor> _bitmapFromAsset({
    required String assetPath,
    required int targetWidth,
  }) async {
    final key = 'asset::$assetPath::$targetWidth';
    if (_iconCache.containsKey(key)) return _iconCache[key]!;

    final data = await DefaultAssetBundle.of(context).load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: targetWidth,
    );
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
      return await _buildFallbackCar(width: targetWidth, type: type);
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

  // ---------------- ROTA (user->dest) ----------------
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

  Future<List<gmaps.LatLng>?> _fetchDrivingRoute(
    gmaps.LatLng origin,
    gmaps.LatLng dest,
  ) async {
    final key = (widget.googleApiKey ?? '').trim();
    if (key.isEmpty) return <gmaps.LatLng>[origin, dest];

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${dest.latitude},${dest.longitude}'
      '&mode=driving&language=pt-BR&key=$key',
    );

    try {
      final resp = await http.get(uri);
      if (resp.statusCode != 200) return <gmaps.LatLng>[origin, dest];
      final data = json.decode(resp.body) as Map<String, dynamic>;
      if ((data['status'] ?? '') != 'OK') return <gmaps.LatLng>[origin, dest];
      final routes = (data['routes'] as List?) ?? const [];
      if (routes.isEmpty) return <gmaps.LatLng>[origin, dest];
      final overview = routes.first['overview_polyline']?['points']?.toString();
      if (overview == null || overview.isEmpty) {
        return <gmaps.LatLng>[origin, dest];
      }
      return _decodePolyline(overview);
    } catch (_) {
      return <gmaps.LatLng>[origin, dest];
    }
  }

  List<gmaps.LatLng> _decimate(List<gmaps.LatLng> pts,
      {double minStepMeters = 2.2, int maxPoints = 900}) {
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

  // ---------------- DRIVERS (animação suave) ----------------

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
    final diff = ((b - a + 540) % 360) - 180; // menor arco
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
    String resolved = hasTaxi
        ? 'taxi'
        : (hasDriver ? 'driver' : (_driverTypeMemo[id] ?? 'driver'));
    _driverTypeMemo[id] = resolved; // memoriza
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
      desc = await _buildFallbackCar(
          width: width,
          type: type,
          bodyColor:
              type == 'taxi' ? const Color(0xFFFFC107) : widget.routeColor);
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
          final before = _markers.length;
          _markers.removeWhere((m) => m.markerId.value == 'driver_$id');
          final removed = _markers.length != before;

          _driverPos.remove(id);
          _driverRot.remove(id);
          _driverTypeMemo.remove(id);

          final anim = _anims.remove(id);
          anim?.dispose();

          if (removed) setState(() {});
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
          setState(() {});
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
          minFrameMs: 66, // ~15 fps
          onTick: (pos, rot) {
            final now = DateTime.now().millisecondsSinceEpoch;
            final lastMs = _lastDriverTickMs[id] ?? 0;
            if (now - lastMs < 60) return;
            _lastDriverTickMs[id] = now;

            _driverPos[id] = pos;
            _driverRot[id] = rot;
            _upsertDriverMarker(id, pos, rot, icon,
                title: (data?['display_name'] ?? 'Driver').toString());
            if (mounted) setState(() {});
          },
          bearingLerp: _bearingLerp,
        );
        _anims[id] = anim;
        anim.start();
      });
    }
  }

  void _upsertDriverMarker(
    String id,
    gmaps.LatLng pos,
    double rotation,
    gmaps.BitmapDescriptor icon, {
    required String title,
  }) {
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
    _markers.removeWhere((m) => m.markerId.value == 'driver_$id');
    _markers.add(marker);
  }

  // ---------------- USER ----------------
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

    _markers.removeWhere((x) => x.markerId.value == 'user');
    _markers.add(userMarker);
  }

  // ---------------- FIT / debounce ----------------
  void _scheduleFit() {
    if (!_mapReady || _controller == null) return;
    if (_pendingFit) return;
    _pendingFit = true;
    Future<void>.delayed(const Duration(milliseconds: 120), () async {
      _pendingFit = false;
      await _fitToContent(padding: 60);
    });
  }

  Future<void> _fitToContent({double padding = 60}) async {
    if (_controller == null) return;
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
      await _controller!.animateCamera(
        gmaps.CameraUpdate.newLatLngBounds(bounds, padding),
      );
    } catch (_) {
      Future<void>.delayed(const Duration(milliseconds: 180), () async {
        if (!mounted || _controller == null) return;
        try {
          await _controller!.animateCamera(
            gmaps.CameraUpdate.newLatLngBounds(bounds, padding),
          );
        } catch (_) {}
      });
    }
  }

  // ---------------- ROTA USER->DEST ----------------
  gmaps.LatLng _posAt(double t) {
    if (_route.isEmpty) return _gm(widget.userLocation);
    if (t <= 0) return _route.first;
    if (t >= 1) return _route.last;
    final target = t * _totalDist;
    int i = 1;
    while (i < _cumDist.length && _cumDist[i] < target) i++;
    final i0 = (i - 1).clamp(0, _route.length - 2);
    final i1 = i0 + 1;
    final d0 = _cumDist[i0];
    final d1 = _cumDist[i1];
    final seg = (d1 - d0).clamp(1e-6, double.infinity);
    final ft = ((target - d0) / seg).clamp(0.0, 1.0);
    final a = _route[i0];
    final b = _route[i1];
    return gmaps.LatLng(
      a.latitude + (b.latitude - a.latitude) * ft,
      a.longitude + (b.longitude - a.longitude) * ft,
    );
  }

  Future<void> _loadRouteAndAnimate() async {
    _polylines.removeWhere((pl) =>
        pl.polylineId.value == 'route_main' ||
        pl.polylineId.value == 'route_bg');
    _route = [];
    _visibleRoute = [];
    _cumDist = [];
    _totalDist = 0;
    _routeFailSafe?.cancel();

    final dest = widget.destination;

    if (dest == null) {
      final before = _markers.length;
      _markers.removeWhere((m) => m.markerId.value == 'dest');

      _routeAnim?.stop();
      _routeAnim?.dispose();
      _routeAnim = null;
      _routeCurve = null;

      setState(() {});
      return;
    }

    final origin = _gm(widget.userLocation);
    final d = _gm(dest);

    final pts =
        await _fetchDrivingRoute(origin, d) ?? <gmaps.LatLng>[origin, d];
    _route = _decimate(pts);
    if (_route.length < 2) {
      setState(() {});
      return;
    }
    _buildCumDist(_route);

    // destino
    _destIcon ??=
        await _pngIconFromUrl(widget.destinationMarkerPngUrl, width: 108);
    _markers.removeWhere((m) => m.markerId.value == 'dest');
    _markers.add(gmaps.Marker(
      markerId: const gmaps.MarkerId('dest'),
      position: d,
      icon: _destIcon!,
      anchor: const Offset(0.5, 1.0),
      zIndex: 25,
      infoWindow: const gmaps.InfoWindow(title: 'Destino'),
    ));

    // 1) BACKGROUND estático: rota inteira
    _polylines.add(_poly(
      _route,
      id: 'route_bg',
      zIndex: 7,
      color: widget.routeColor.withOpacity(0.35),
      width: (widget.routeWidth + 2).clamp(4, 9),
    ));

    // 2) Snake animada
    _visibleRoute = [_route.first, _route.first];
    _polylines.add(_poly(
      _visibleRoute,
      id: 'route_main',
      zIndex: 8,
      color: widget.routeColor,
      width: widget.routeWidth.clamp(3, 7),
    ));
    setState(() {});

    final dist = _totalDist;
    final durMs = (1600 + (dist / 1200) * 2400).clamp(1600, 5000).toInt();

    _routeAnim ??= AnimationController(vsync: this);
    _routeAnim!.duration = Duration(milliseconds: durMs);

    _routeCurve?.removeListener(_routeCurveListener);
    _routeCurve =
        CurvedAnimation(parent: _routeAnim!, curve: Curves.easeInOutCubic)
          ..addListener(_routeCurveListener);

    // failsafe
    _routeFailSafe = Timer(Duration(milliseconds: durMs + 600), () {
      if (!mounted) return;
      _polylines.removeWhere((pl) => pl.polylineId.value == 'route_main');
      _polylines.add(_poly(
        _route,
        id: 'route_main',
        zIndex: 8,
        color: widget.routeColor,
        width: widget.routeWidth.clamp(3, 7),
      ));
      setState(() {});
    });

    _routeAnim!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _routeFailSafe?.cancel();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _routeAnim!
          ..reset()
          ..forward(from: 0);
      }
    });
  }

  void _routeCurveListener() {
    // Throttle a ~30fps
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastRouteMs < 33) return;
    _lastRouteMs = now;

    final t = _routeCurve!.value;
    final pos = _posAt(t);
    _visibleRoute = _collectVisible(t, pos);

    _polylines.removeWhere((pl) => pl.polylineId.value == 'route_main');
    _polylines.add(_poly(
      _visibleRoute,
      id: 'route_main',
      zIndex: 8,
      color: widget.routeColor,
      width: widget.routeWidth.clamp(3, 7),
    ));

    setState(() {});
  }

  List<gmaps.LatLng> _collectVisible(double t, gmaps.LatLng pos) {
    if (_route.isEmpty) return [];
    final target = t * _totalDist;
    int k = 1;
    while (k < _cumDist.length && _cumDist[k] < target) k++;
    final vis = <gmaps.LatLng>[];
    if (k > 0) vis.addAll(_route.sublist(0, k));
    vis.add(pos);
    if (vis.length < 2 && _route.length >= 2) {
      vis.add(_route[1]);
    }
    return vis;
  }

  gmaps.Polyline _poly(
    List<gmaps.LatLng> pts, {
    required String id,
    required int zIndex,
    required Color color,
    required int width,
  }) =>
      gmaps.Polyline(
        polylineId: gmaps.PolylineId(id),
        points: pts,
        width: width,
        color: color,
        zIndex: zIndex,
        startCap: gmaps.Cap.roundCap,
        endCap: gmaps.Cap.roundCap,
        jointType: gmaps.JointType.round,
        geodesic: true,
        patterns: const [
          gmaps.PatternItem.dash(20),
          gmaps.PatternItem.gap(10),
        ],
      );

  // ---------------- Lifecycle ----------------
  @override
  void initState() {
    super.initState();
    _ensureUserMarker();
    _subscribeDrivers();
    _loadRouteAndAnimate();
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
      setState(() {});
    }
    if (oldWidget.destination != widget.destination ||
        oldWidget.googleApiKey != widget.googleApiKey ||
        oldWidget.routeWidth != widget.routeWidth ||
        oldWidget.routeColor != widget.routeColor) {
      _loadRouteAndAnimate();
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
    _routeCurve?.removeListener(_routeCurveListener);
    _routeAnim?.dispose();
    _routeFailSafe?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? double.infinity;
    final height = widget.height ?? 320;

    final center = widget.destination == null
        ? _gm(widget.userLocation)
        : gmaps.LatLng(
            (widget.userLocation.latitude + widget.destination!.latitude) / 2.0,
            (widget.userLocation.longitude + widget.destination!.longitude) /
                2.0,
          );

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: Colors.black)),
            gmaps.GoogleMap(
              initialCameraPosition: gmaps.CameraPosition(
                target: center,
                zoom: widget.destination == null ? 13.0 : 12.5,
                tilt: 0,
              ),
              polylines: _polylines,
              markers: _markers,
              compassEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              buildingsEnabled: true,
              mapToolbarEnabled: false,
              onMapCreated: (c) async {
                _controller = c;
                try {
                  await c.setMapStyle(_darkMapStyle);
                } catch (_) {}
                _styleReady = true;
                _mapReady = true;
                _maybeReveal();
                _scheduleFit();
              },
              onCameraIdle: () {
                _firstIdle = true;
                _maybeReveal();
              },
              mapType: gmaps.MapType.normal,
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _veilVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: const ColoredBox(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _maybeReveal() {
    if (!_veilVisible) return;
    if (_styleReady && _firstIdle && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _veilVisible = false);
      });
    }
  }
}

/// Helper para animar posição/rotação do driver (com throttle)
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
    this.minFrameMs = 66, // ~15 fps
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
