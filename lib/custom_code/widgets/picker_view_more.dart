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
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

// Maps
import '/flutter_flow/lat_lng.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// PickerViewMore v4.0 — dark UI + rota âmbar + destino PNG + animações de
/// pulso e progresso
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
    this.strokeColor = const Color(0xFFFBB125), // âmbar da rota
    this.interactive = false,
    this.borderRadius = 16,

    // Dados p/ marcadores
    this.userName,
    this.userPhotoUrl,
    this.destinationMarkerPngUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png',

    // Tamanhos
    this.userMarkerSize = 56,
    this.destMarkerWidth = 54,

    // ==== NOVO: Animação da rota ====
    this.routeAnimationEnabled = true,
    // duração ~ min..max, calculada por km com clamp
    this.routeAnimMinMs = 1600,
    this.routeAnimMaxMs = 18000,
    this.routeAnimMsPerKm = 1100,
    // raio do “dot” (em metros)
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

  // animação de progresso
  final bool routeAnimationEnabled;
  final int routeAnimMinMs;
  final int routeAnimMaxMs;
  final int routeAnimMsPerKm;
  final double runnerDotRadiusMeters;

  @override
  State<PickerViewMore> createState() => _PickerViewMoreState();
}

class _PickerViewMoreState extends State<PickerViewMore>
    with TickerProviderStateMixin {
  gmaps.GoogleMapController? _controller;
  final _polylines = <gmaps.Polyline>{};
  final _markers = <gmaps.Marker>{};
  final _circles = <gmaps.Circle>{}; // pulso no destino + runner

  // Fade-in do mapa (sem flash branco)
  bool _mapVisible = false;

  // Rota (ou linha reta)
  List<gmaps.LatLng> _route = [];

  // Lista cumulativa de distâncias (m) ao longo da rota
  List<double> _cumDist = [];
  double _totalDist = 0; // em metros

  // cache de ícones
  final Map<String, gmaps.BitmapDescriptor> _iconCache = {};
  gmaps.BitmapDescriptor? _userIcon; // origem
  gmaps.BitmapDescriptor? _destIcon; // destino

  // animação de pulso no destino
  late final AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  // NOVO: animação do progresso da rota
  AnimationController? _routeCtrl;
  double _routeT = 0.0; // 0..1

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

  gmaps.LatLng _gm(LatLng p) => gmaps.LatLng(p.latitude, p.longitude);

  // tracejado só no Android
  List<gmaps.PatternItem> get _dashPattern =>
      defaultTargetPlatform == TargetPlatform.android
          ? <gmaps.PatternItem>[
              gmaps.PatternItem.dash(18),
              gmaps.PatternItem.gap(10)
            ]
          : const <gmaps.PatternItem>[];

  @override
  void initState() {
    super.initState();
    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _pulseCtrl.addListener(_updatePulse);
    _pulseCtrl.repeat(reverse: true);

    _buildAll(); // rota + marcadores + fit + animação
  }

  @override
  void dispose() {
    _pulseCtrl.removeListener(_updatePulse);
    _pulseCtrl.dispose();
    _routeCtrl?.removeListener(_onRouteTick);
    _routeCtrl?.dispose();
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
      _iconCache.clear();
      _userIcon = null;
      _destIcon = null;
      _routeCtrl?.stop();
      _routeCtrl?.removeListener(_onRouteTick);
      _routeCtrl?.dispose();
      _routeCtrl = null;
      _buildAll();
    }
  }

  Future<void> _buildAll() async {
    await _buildRoute(); // calcula rota + distâncias
    await _buildMarkers(); // origem/destino
    _rebuildPolylineBase(); // sombra + prévia tracejada
    _startRouteAnimation(); // progresso crescendo
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitToContent());
  }

  // ================== ÍCONES ==================

  Future<Uint8List?> _fetchBytes(String rawUrl,
      {Duration timeout = const Duration(seconds: 6)}) async {
    if (rawUrl.trim().isEmpty) return null;
    var url = rawUrl.trim();
    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'https://'); // iOS ATS
    }
    try {
      final resp = await http.get(Uri.parse(url)).timeout(timeout);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return resp.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  String _initialsFromName(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '•';
    final parts = n.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) {
      return n.substring(0, math.min(2, n.length)).toUpperCase();
    }
    final a = parts[0][0];
    final b = parts.length > 1
        ? parts[1][0]
        : (parts[0].length > 1 ? parts[0][1] : a);
    return (a + b).toUpperCase();
  }

  Future<gmaps.BitmapDescriptor> _buildUserAvatar({
    required int size,
    required String? photoUrl,
    required String initials,
    Color borderColor = const Color(0xFFFBB125), // borda âmbar
    Color bg = const Color(0xFF1B1B1B),
    Color txt = Colors.white,
  }) async {
    final key = 'userAvatar::$size::$photoUrl::$initials';
    if (_iconCache.containsKey(key)) return _iconCache[key]!;

    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    final s = size.toDouble();
    final r = s / 2;
    final rect = ui.Rect.fromLTWH(0, 0, s, s);

    // fundo circular
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
      final tp = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w700,
          fontSize: s * 0.38))
        ..pushStyle(ui.TextStyle(color: txt))
        ..addText(initials);
      final para = tp.build()..layout(ui.ParagraphConstraints(width: s));
      c.drawParagraph(para, ui.Offset(0, (s - para.height) / 2));
    }

    // borda
    final border = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = math.max(3.0, s * 0.06)
      ..color = borderColor
      ..isAntiAlias = true;
    c.drawCircle(ui.Offset(r, r), r - border.strokeWidth / 2, border);

    final img = await rec.endRecording().toImage(size, size);
    final data = (await img.toByteData(format: ui.ImageByteFormat.png))!;
    final desc = gmaps.BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    _iconCache[key] = desc;
    return desc;
  }

  Future<gmaps.BitmapDescriptor> _pngIconFromUrl(String url,
      {required int width}) async {
    final key = 'png::$url::$width';
    if (_iconCache.containsKey(key)) return _iconCache[key]!;
    final bytes = await _fetchBytes(url);
    if (bytes == null) {
      return gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueOrange);
    }
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final data = (await img.toByteData(format: ui.ImageByteFormat.png))!;
    final desc = gmaps.BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    _iconCache[key] = desc;
    return desc;
  }

  // ================== ROTA ==================

  Future<void> _buildRoute() async {
    final o = _gm(widget.latlngOrigem);
    final d = _gm(widget.latlngDestino);

    final key = (widget.googleApiKey ?? '').trim();
    List<gmaps.LatLng> pts;
    if (key.isNotEmpty) {
      pts = await _fetchDrivingRoute(o, d, key) ?? <gmaps.LatLng>[o, d];
    } else {
      pts = <gmaps.LatLng>[o, d];
    }

    _route = _simplify(pts, minStepMeters: 1.5, maxPoints: 1500);

    // pré-calcula distâncias acumuladas
    _cumDist = List<double>.filled(_route.length, 0.0, growable: false);
    double acc = 0.0;
    for (int i = 1; i < _route.length; i++) {
      acc += _meters(_route[i - 1], _route[i]);
      _cumDist[i] = acc;
    }
    _totalDist = acc;
  }

  List<gmaps.LatLng> _simplify(List<gmaps.LatLng> pts,
      {double minStepMeters = 1.5, int maxPoints = 1500}) {
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

  // ======= Polylines base (sombra + prévia tracejada) =======
  void _rebuildPolylineBase() {
    _polylines
      ..removeWhere((p) =>
          p.polylineId.value == 'route_shadow' ||
          p.polylineId.value == 'route_preview' ||
          p.polylineId.value == 'route_progress')
      ..add(
        gmaps.Polyline(
          polylineId: const gmaps.PolylineId('route_shadow'),
          points: _route,
          width: (widget.strokeWidth + 2).toInt().clamp(4, 9),
          color: const Color(0x80000000),
          zIndex: 9,
          startCap: gmaps.Cap.roundCap,
          endCap: gmaps.Cap.roundCap,
          jointType: gmaps.JointType.round,
          geodesic: true,
        ),
      )
      ..add(
        gmaps.Polyline(
          polylineId: const gmaps.PolylineId('route_preview'),
          points: _route,
          width: widget.strokeWidth.toInt().clamp(3, 7),
          color: widget.strokeColor.withOpacity(0.85),
          zIndex: 10,
          startCap: gmaps.Cap.roundCap,
          endCap: gmaps.Cap.roundCap,
          jointType: gmaps.JointType.round,
          patterns: _dashPattern,
          geodesic: true,
        ),
      );

    // inicia limpa a progress line; será atualizada no tick
    _polylines.add(
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('route_progress'),
        points: const <gmaps.LatLng>[],
        width: (widget.strokeWidth + 1).toInt().clamp(3, 8),
        color: widget.strokeColor, // sólida
        zIndex: 11,
        startCap: gmaps.Cap.roundCap,
        endCap: gmaps.Cap.roundCap,
        jointType: gmaps.JointType.round,
        geodesic: true,
      ),
    );

    if (mounted) setState(() {});
  }

  // ======= Animação do progresso =======
  void _startRouteAnimation() {
    _routeT = 0.0;
    _updateRunnerCircle(null); // limpa runner
    if (!widget.routeAnimationEnabled || _route.length < 2) {
      _applyProgress(1.0); // desenha tudo
      return;
    }

    // calcula duração com base na distância total
    // totalDist (m) -> (km * msPorKm) clamp(min,max)
    final kms = (_totalDist / 1000.0).clamp(0.0, 1e6);
    final ms = (kms * widget.routeAnimMsPerKm)
        .clamp(
            widget.routeAnimMinMs.toDouble(), widget.routeAnimMaxMs.toDouble())
        .round();

    _routeCtrl?.removeListener(_onRouteTick);
    _routeCtrl?.dispose();
    _routeCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: math.max(300, ms)),
    )..addListener(_onRouteTick);

    _routeCtrl!.forward(from: 0.0);
  }

  void _onRouteTick() {
    _routeT = _routeCtrl!.value; // 0..1
    _applyProgress(_routeT);
  }

  void _applyProgress(double t) {
    // Constrói a subpolyline até a distância-alvo
    if (_route.isEmpty) return;

    final targetDist = _totalDist * t;
    final out = <gmaps.LatLng>[];

    if (t <= 0) {
      // nenhum ponto
    } else if (t >= 1) {
      out.addAll(_route);
    } else {
      // encontra o segmento onde fica o targetDist
      int idx = _lowerBound(_cumDist, targetDist);
      // idx é o primeiro i tal que _cumDist[i] >= targetDist
      if (idx <= 0) {
        out.add(_route.first);
      } else {
        // todos pontos completos até idx-1
        out.addAll(_route.getRange(0, idx));
        // adiciona ponto interpolado no segmento [idx-1, idx]
        final prevD = _cumDist[idx - 1];
        final segLen = (_cumDist[idx] - prevD);
        final f =
            segLen <= 0 ? 1.0 : ((targetDist - prevD) / segLen).clamp(0.0, 1.0);
        out.add(_lerp(_route[idx - 1], _route[idx], f));
      }
    }

    // atualiza a polyline de progresso
    _polylines.removeWhere((p) => p.polylineId.value == 'route_progress');
    _polylines.add(
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('route_progress'),
        points: out,
        width: (widget.strokeWidth + 1).toInt().clamp(3, 8),
        color: widget.strokeColor,
        zIndex: 11,
        startCap: gmaps.Cap.roundCap,
        endCap: gmaps.Cap.roundCap,
        jointType: gmaps.JointType.round,
        geodesic: true,
      ),
    );

    // atualiza o “dot” correndo na frente
    final runner = out.isEmpty
        ? _route.first
        : out.length == 1
            ? out.first
            : out.last;
    _updateRunnerCircle(runner);

    if (mounted) setState(() {});
  }

  int _lowerBound(List<double> a, double x) {
    // padrão: first index with a[i] >= x
    int l = 0, r = a.length; // [l, r)
    while (l < r) {
      final m = (l + r) >> 1;
      if (a[m] < x) {
        l = m + 1;
      } else {
        r = m;
      }
    }
    return l;
  }

  gmaps.LatLng _lerp(gmaps.LatLng a, gmaps.LatLng b, double f) {
    final lat = a.latitude + (b.latitude - a.latitude) * f;
    final lng = a.longitude + (b.longitude - a.longitude) * f;
    return gmaps.LatLng(lat, lng);
  }

  void _updateRunnerCircle(gmaps.LatLng? pos) {
    _circles.removeWhere((c) => c.circleId.value == 'runner');
    if (pos == null) {
      if (mounted) setState(() {});
      return;
    }
    _circles.add(
      gmaps.Circle(
        circleId: const gmaps.CircleId('runner'),
        center: pos,
        radius: widget.runnerDotRadiusMeters,
        strokeColor: widget.strokeColor.withOpacity(0.95),
        strokeWidth: 2,
        fillColor: widget.strokeColor.withOpacity(0.75),
        zIndex: 26,
      ),
    );
  }

  Future<void> _buildMarkers() async {
    _markers.clear();

    // ORIGEM: avatar (foto OU iniciais) com borda âmbar
    final initials = _initialsFromName(widget.userName);
    _userIcon ??= await _buildUserAvatar(
      size: widget.userMarkerSize,
      photoUrl: widget.userPhotoUrl,
      initials: initials,
    );

    _markers.add(gmaps.Marker(
      markerId: const gmaps.MarkerId('origem'),
      position: _gm(widget.latlngOrigem),
      icon: _userIcon!,
      anchor: const Offset(0.5, 0.5),
      zIndex: 30,
      flat: true,
      infoWindow: const gmaps.InfoWindow(title: 'Origem'),
    ));

    // DESTINO: PNG personalizado
    _destIcon ??= await _pngIconFromUrl(
      widget.destinationMarkerPngUrl,
      width: widget.destMarkerWidth,
    );

    final destPos = _gm(widget.latlngDestino);

    _markers.add(gmaps.Marker(
      markerId: const gmaps.MarkerId('destino'),
      position: destPos,
      icon: _destIcon!,
      anchor: const Offset(0.5, 1.0),
      zIndex: 25,
      flat: true,
      infoWindow: const gmaps.InfoWindow(title: 'Destino'),
    ));

    // círculo pulsante no destino (atualizado no listener)
    _buildPulseCircle(destPos);

    if (mounted) setState(() {});
  }

  void _buildPulseCircle(gmaps.LatLng pos) {
    // cria/atualiza o círculo com base no valor de _pulse
    final t = _pulse.value; // 0..1
    final radius = 12 + 18 * t; // em metros
    final alpha = (0.55 * (1 - t)).clamp(0.0, 0.55); // some no pico

    _circles
      ..removeWhere((c) => c.circleId.value == 'dest_pulse')
      ..add(
        gmaps.Circle(
          circleId: const gmaps.CircleId('dest_pulse'),
          center: _markers
              .firstWhere((m) => m.markerId.value == 'destino',
                  orElse: () => gmaps.Marker(
                      markerId: const gmaps.MarkerId('tmp'),
                      position: _gm(widget.latlngDestino)))
              .position,
          radius: radius,
          strokeWidth: 2,
          strokeColor: const Color(0xFFFBB125).withOpacity(alpha),
          fillColor: const Color(0xFFFBB125).withOpacity(alpha * 0.45),
          zIndex: 24,
        ),
      );
    if (mounted) setState(() {});
  }

  void _updatePulse() {
    if (_markers.any((m) => m.markerId.value == 'destino')) {
      _buildPulseCircle(
          _markers.firstWhere((m) => m.markerId.value == 'destino').position);
    }
  }

  Future<void> _fitToContent() async {
    if (_controller == null) return;

    final pts = <gmaps.LatLng>[];
    for (final pl in _polylines) pts.addAll(pl.points);
    for (final mk in _markers) pts.add(mk.position);
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

    await _controller!.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(bounds, widget.fitPadding),
    );
  }

  // --------- Directions helpers ----------
  Future<List<gmaps.LatLng>?> _fetchDrivingRoute(
    gmaps.LatLng origin,
    gmaps.LatLng dest,
    String apiKey,
  ) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${dest.latitude},${dest.longitude}'
      '&mode=driving&language=pt-BR&key=$apiKey',
    );

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;

      final data = json.decode(resp.body) as Map<String, dynamic>;
      if ((data['status'] ?? '') != 'OK') return null;

      final routes = (data['routes'] as List?) ?? const [];
      if (routes.isEmpty) return null;

      final overview = routes.first['overview_polyline']?['points']?.toString();
      if (overview == null || overview.isEmpty) return null;

      return _decodePolyline(overview);
    } catch (_) {
      return null;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? double.infinity;
    final height = widget.height ?? 240.0;

    final initialTarget = _route.isNotEmpty
        ? _route.first
        : gmaps.LatLng(
            widget.latlngOrigem.latitude, widget.latlngOrigem.longitude);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Fundo preto para evitar “flash” antes do estilo
            Positioned.fill(child: Container(color: const Color(0xFF000000))),

            AnimatedOpacity(
              opacity: _mapVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              child: gmaps.GoogleMap(
                initialCameraPosition: gmaps.CameraPosition(
                  target: initialTarget,
                  zoom: 13.5,
                  tilt: 0,
                ),
                mapType: gmaps.MapType.normal,
                buildingsEnabled: true,

                // Overlay
                polylines: _polylines,
                markers: _markers,
                circles: _circles,
                polygons: const <gmaps.Polygon>{},

                // Controles/gestos
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                rotateGesturesEnabled: widget.interactive,
                tiltGesturesEnabled: widget.interactive,
                scrollGesturesEnabled: widget.interactive,
                zoomGesturesEnabled: widget.interactive,

                onMapCreated: (c) async {
                  _controller = c;
                  await c.setMapStyle(_darkMapStyle);
                  if (mounted) setState(() => _mapVisible = true);

                  // Fit assim que renderizar
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _fitToContent();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
