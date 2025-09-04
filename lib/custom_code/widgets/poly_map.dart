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

// Imports do FlutterFlow / projeto
import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

// Flutter / Dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

// Firebase / Maps
import '/flutter_flow/lat_lng.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// POLYMAP (enxuto, sem directions e sem driversCollection): - Mapa dark -
/// Ponto do usuário (laranja) + PULSE animado - Drivers via `driversRefs`
/// (streams) - Card inline ao tocar no driver
class PolyMap extends StatefulWidget {
  const PolyMap({
    super.key,
    this.width,
    this.height,
    required this.userLocation,
    this.driversRefs, // << só isso pra drivers
    this.refreshMs = 8000, // leve re-enquadramento opcional
  });

  final double? width;
  final double? height;
  final LatLng userLocation;

  /// Streams de docs específicos (opcional)
  final List<DocumentReference>? driversRefs;

  final int refreshMs;

  @override
  State<PolyMap> createState() => _PolyMapState();
}

class _PolyMapState extends State<PolyMap> with TickerProviderStateMixin {
  final _markers = <gmaps.Marker>{};
  gmaps.GoogleMapController? _controller;

  // cache de ícones
  final Map<String, gmaps.BitmapDescriptor> _iconCache = {};
  gmaps.BitmapDescriptor? _userDotIcon;

  // subscriptions (apenas refs)
  final Map<String, StreamSubscription<DocumentSnapshot>> _refsSubs = {};

  // Card do driver tocado
  _DriverInfo? _selected;

  // Pulse overlay
  late final AnimationController _pulseCtrl;
  Offset? _userScreenPx;

  Timer? _uiNudgeTimer;

  static const _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#212121"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f1f1f"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f2f2f"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}
]
''';

  gmaps.LatLng _gm(LatLng p) => gmaps.LatLng(p.latitude, p.longitude);

  // -------------------- Icons --------------------
  Future<gmaps.BitmapDescriptor> _buildDotIcon({
    Color color = const Color(0xFFFFC107),
    int size = 28,
    bool ring = true,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final c = ui.Offset(size / 2, size / 2);
    final r = size / 2.0;

    if (ring) {
      final ringPaint = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = (size * 0.16)
        ..color = color.withOpacity(0.9)
        ..isAntiAlias = true;
      canvas.drawCircle(c, r - ringPaint.strokeWidth / 2, ringPaint);
    }

    final dot = ui.Paint()
      ..color = color
      ..isAntiAlias = true;
    canvas.drawCircle(c, r * 0.62, dot);

    final img = await recorder.endRecording().toImage(size, size);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return gmaps.BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<gmaps.BitmapDescriptor> _circleImageIcon(String url,
      {int size = 96}) async {
    if (_iconCache.containsKey(url)) return _iconCache[url]!;
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) {
        return gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueOrange);
      }

      final codec = await ui.instantiateImageCodec(
        resp.bodyBytes,
        targetWidth: size,
        targetHeight: size,
      );
      final frame = await codec.getNextFrame();
      final img = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final rect = ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());

      final r = size / 2.0;
      final clip = ui.Path()
        ..addOval(ui.Rect.fromCircle(center: ui.Offset(r, r), radius: r));
      canvas.clipPath(clip);

      final paint = ui.Paint()..isAntiAlias = true;
      canvas.drawImageRect(
        img,
        ui.Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        rect,
        paint,
      );

      final border = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = const Color(0xFFFFC107);
      canvas.drawCircle(ui.Offset(r, r), r - 3, border);

      final outImg = await recorder.endRecording().toImage(size, size);
      final bytes = await outImg.toByteData(format: ui.ImageByteFormat.png);
      final desc =
          gmaps.BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());

      _iconCache[url] = desc;
      return desc;
    } catch (_) {
      return gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueOrange);
    }
  }

  // -------------------- Fit --------------------
  Future<void> _fitToContent({double padding = 60}) async {
    if (_controller == null) return;
    if (_markers.isEmpty) return;

    double minLat = _markers.first.position.latitude;
    double maxLat = minLat;
    double minLng = _markers.first.position.longitude;
    double maxLng = minLng;

    for (final m in _markers) {
      final p = m.position;
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
      gmaps.CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }

  // -------------------- Drivers (somente refs) --------------------
  Future<void> _ensureUserMarker() async {
    _userDotIcon ??= await _buildDotIcon();
    final userPos = _gm(widget.userLocation);

    _markers.removeWhere((m) => m.markerId.value == 'user');
    _markers.add(
      gmaps.Marker(
        markerId: const gmaps.MarkerId('user'),
        position: userPos,
        icon: _userDotIcon!,
        zIndex: 30,
        infoWindow: const gmaps.InfoWindow(title: 'Você'),
      ),
    );
  }

  void _clearRefsSubs() {
    for (final s in _refsSubs.values) {
      s.cancel();
    }
    _refsSubs.clear();
  }

  void _subscribeDriversRefs() async {
    _clearRefsSubs();
    final refs = widget.driversRefs;
    if (refs == null) return;

    for (final ref in refs) {
      final id = ref.id;

      _refsSubs[id] = ref.snapshots().listen((snap) async {
        if (!snap.exists) {
          _markers.removeWhere((m) => m.markerId.value == 'driver_$id');
          if (mounted) setState(() {});
          return;
        }

        final data = snap.data() as Map<String, dynamic>?;

        gmaps.LatLng? pos;
        final loc = data?['location'];
        if (loc is GeoPoint) {
          pos = gmaps.LatLng(loc.latitude, loc.longitude);
        } else {
          final lat = (data?['lat'] as num?)?.toDouble();
          final lng = (data?['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) pos = gmaps.LatLng(lat, lng);
        }
        if (pos == null) return;

        await _upsertDriverMarker(
          id: id,
          name: (data?['display_name'] ?? 'Driver').toString(),
          photoUrl: (data?['photo_url'] ?? '').toString(),
          position: pos,
        );
      });
    }
  }

  Future<void> _upsertDriverMarker({
    required String id,
    required String name,
    required String photoUrl,
    required gmaps.LatLng position,
  }) async {
    gmaps.BitmapDescriptor icon;
    if (photoUrl.isNotEmpty) {
      icon = await _circleImageIcon(photoUrl, size: 96);
    } else {
      icon = await _buildDotIcon(color: const Color(0xFFFFC107), size: 32);
    }

    final markerId = 'driver_$id';

    final marker = gmaps.Marker(
      markerId: gmaps.MarkerId(markerId),
      position: position,
      zIndex: 20,
      icon: icon,
      infoWindow: gmaps.InfoWindow(title: name),
      onTap: () {
        if (!mounted) return;
        setState(() {
          _selected = _DriverInfo(name: name, photoUrl: photoUrl);
        });
      },
    );

    _markers
      ..removeWhere((m) => m.markerId.value == markerId)
      ..add(marker);
  }

  // -------------------- PULSE overlay --------------------
  Future<void> _updateUserScreenPx() async {
    if (_controller == null) return;
    try {
      final sc =
          await _controller!.getScreenCoordinate(_gm(widget.userLocation));
      _userScreenPx = Offset(sc.x.toDouble(), sc.y.toDouble());
      if (mounted) setState(() {});
    } catch (_) {
      // ignore
    }
  }

  // -------------------- Lifecycle --------------------
  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    // user + streams
    _ensureUserMarker();
    _subscribeDriversRefs();

    // leve auto-fit periódico (opcional)
    _uiNudgeTimer =
        Timer.periodic(Duration(milliseconds: widget.refreshMs), (_) async {
      if (!mounted) return;
      await _fitToContent(padding: 60);
      // atualiza posição do pulse na tela
      await _updateUserScreenPx();
    });
  }

  @override
  void didUpdateWidget(covariant PolyMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userLocation != widget.userLocation) {
      _ensureUserMarker();
      _updateUserScreenPx();
    }
    if (oldWidget.driversRefs != widget.driversRefs) {
      _subscribeDriversRefs();
    }
  }

  @override
  void dispose() {
    _uiNudgeTimer?.cancel();
    _pulseCtrl.dispose();
    for (final s in _refsSubs.values) {
      s.cancel();
    }
    _refsSubs.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? double.infinity;
    final height = widget.height ?? 320;

    final center = _gm(widget.userLocation);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // MAPA
            gmaps.GoogleMap(
              initialCameraPosition: gmaps.CameraPosition(
                target: center,
                zoom: 13,
                tilt: 0,
              ),
              markers: _markers,
              compassEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              buildingsEnabled: true,
              onMapCreated: (c) async {
                _controller = c;
                await c.setMapStyle(_darkMapStyle);
                // posiciona pulse inicial
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _fitToContent(padding: 60);
                  _updateUserScreenPx();
                });
              },
              onCameraMove: (_) => _updateUserScreenPx(),
              onCameraIdle: _updateUserScreenPx,
              mapType: gmaps.MapType.normal,
            ),

            // OVERLAY do PULSE (desenhado em coordenada de tela do user)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _PulsePainter(
                        centerPx: _userScreenPx,
                        t: _pulseCtrl.value,
                        color: const Color(0xFFFFC107),
                      ),
                    );
                  },
                ),
              ),
            ),

            // CARD DO DRIVER (inline, sem barrier)
            if (_selected != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Material(
                    color: const Color(0xFF1E1E1E),
                    elevation: 12,
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 88,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(48),
                            child: Image.network(
                              _selected!.photoUrl.isNotEmpty
                                  ? _selected!.photoUrl
                                  : 'https://picsum.photos/seed/driver/200/200',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selected!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _selected = null),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Painter do PULSE ---
class _PulsePainter extends CustomPainter {
  final Offset? centerPx;
  final double t; // 0..1
  final Color color;

  _PulsePainter({required this.centerPx, required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (centerPx == null) return;

    // Limita o centro ao bounds do canvas
    final cx = centerPx!.dx.clamp(0.0, size.width);
    final cy = centerPx!.dy.clamp(0.0, 1.0 * size.height);
    final c = Offset(cx, cy);

    // Dois anéis alternados (t e t deslocado)
    _drawRing(canvas, c, size, (t));
    _drawRing(canvas, c, size, (t + 0.5) % 1.0);
  }

  void _drawRing(Canvas canvas, Offset c, Size size, double tt) {
    // raio máximo proporcional ao menor lado
    final maxR = (math.min(size.width, size.height) * 0.22);
    final r = ui.lerpDouble(0, maxR, Curves.easeOut.transform(tt))!;
    final a = (1.0 - tt).clamp(0.0, 1.0);

    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ui.lerpDouble(2, 0.8, tt)!
      ..color = color.withOpacity(0.25 * a)
      ..isAntiAlias = true;

    canvas.drawCircle(c, r, p);

    // preenchimento sutil no centro (fade)
    if (tt < 0.25) {
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withOpacity(0.10 * (1 - tt / 0.25));
      canvas.drawCircle(c, r * 0.25, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) {
    return oldDelegate.centerPx != centerPx ||
        oldDelegate.t != t ||
        oldDelegate.color != color;
  }
}

// struct simples para o card
class _DriverInfo {
  final String name;
  final String photoUrl;
  const _DriverInfo({required this.name, required this.photoUrl});
}
