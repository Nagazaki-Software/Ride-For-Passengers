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

// RideViewerNav: Mapa do passageiro (sem voz), com rota, motorista, avatar do usuário
// (foto ou iniciais), mapa dark sem flash, polyline laranja com underlay e toggle de câmera.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '/flutter_flow/lat_lng.dart' as ff;
import 'package:http/http.dart' as http;

class RideViewerNav extends StatefulWidget {
  const RideViewerNav({
    Key? key,
    required this.apiKey,
    required this.userLatLng, // ff.LatLng
    required this.placeLatLng, // ff.LatLng
    required this.driverLatLng, // ff.LatLng (vem do backend)
    this.driverHeading = 0, // graus, opcional
    this.pickedUp = false, // false: Driver->User | true: User->Place
    this.userPhotoUrl,
    this.userDisplayName, // para avatar com iniciais
    required this.width,
    required this.height,
  }) : super(key: key);

  final String apiKey;
  final ff.LatLng userLatLng;
  final ff.LatLng placeLatLng;
  final ff.LatLng driverLatLng;
  final double driverHeading;
  final bool pickedUp;
  final String? userPhotoUrl;
  final String? userDisplayName;
  final double width;
  final double height;

  @override
  State<RideViewerNav> createState() => _RideViewerNavState();
}

enum _CameraMode { topDown, follow }

class _RideViewerNavState extends State<RideViewerNav> {
  gmap.GoogleMapController? _map;

  final Set<gmap.Polyline> _polylines = {};
  final Set<gmap.Marker> _markers = {};

  List<_LegStep> _steps = [];
  double _remainingMeters = 0;
  String _etaText = '';
  String _phaseText = 'To pickup';

  // Câmera
  _CameraMode _cameraMode = _CameraMode.follow;

  // Ícones
  gmap.BitmapDescriptor? _userAvatarIcon; // foto do usuário
  gmap.BitmapDescriptor? _userInitialsIcon; // fallback com iniciais
  gmap.BitmapDescriptor? _carIcon;

  // Cache para evitar re-rotear toda hora
  ff.LatLng? _lastRouteOrigin; // ff.LatLng
  ff.LatLng? _lastRouteDest; // ff.LatLng

  // Véu para matar flash
  bool _veilVisible = true;

  @override
  void initState() {
    super.initState();
    _prepareIcons();
  }

  @override
  void didUpdateWidget(covariant RideViewerNav oldWidget) {
    super.didUpdateWidget(oldWidget);

    final origin = _gm(widget.driverLatLng);
    final dest =
        widget.pickedUp ? _gm(widget.placeLatLng) : _gm(widget.userLatLng);

    // FIX de tipo: usa ff.LatLng direto no _dist(...)
    final needRoute = _lastRouteOrigin == null ||
        _lastRouteDest == null ||
        _dist(_lastRouteOrigin!, origin) > 8 ||
        _dist(_lastRouteDest!, dest) > 8 ||
        (oldWidget.pickedUp != widget.pickedUp);

    if (needRoute) {
      _planRoute();
    } else {
      _updateDriverMarker();
      _updateCamera(animated: true);
    }
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  // ---------- Helpers de LatLng ----------
  gmap.LatLng _gm(ff.LatLng v) => gmap.LatLng(v.latitude, v.longitude);

  // ---------- Estilo dark ----------
  static const String _darkMapStyle = '''
  [
    {"elementType":"geometry","stylers":[{"color":"#1d1d1d"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#8f8f8f"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1d1d"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a2a2a"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#202020"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#b0b0b0"}]},
    {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#242424"}]},
    {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#172117"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0b0b0b"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]}
  ]
  ''';

  Future<void> _applyDarkStyle() async {
    if (_map != null) await _map!.setMapStyle(_darkMapStyle);
  }

  // ---------- Ícones ----------
  Future<void> _prepareIcons() async {
    _carIcon ??= gmap.BitmapDescriptor.fromBytes(await _drawCarPng(size: 110));

    // Foto do usuário (se houver)
    if ((widget.userPhotoUrl ?? '').isNotEmpty) {
      try {
        _userAvatarIcon = gmap.BitmapDescriptor.fromBytes(
          await _avatarFromNetwork(widget.userPhotoUrl!, 140),
        );
      } catch (_) {
        _userAvatarIcon = null;
      }
    }

    // Fallback de iniciais (sempre deixa pronto)
    _userInitialsIcon = gmap.BitmapDescriptor.fromBytes(
      await _initialsAvatarPng(
        name: widget.userDisplayName?.trim().isNotEmpty == true
            ? widget.userDisplayName!.trim()
            : 'Usuário',
        size: 140,
      ),
    );

    setState(() {});
    // calcula rota inicial
    _planRoute();
  }

  Future<Uint8List> _avatarFromNetwork(String url, int size) async {
    final res = await http.get(Uri.parse(url));
    final bytes = res.bodyBytes;
    final codec = await ui.instantiateImageCodec(bytes,
        targetWidth: size, targetHeight: size);
    final frame = await codec.getNextFrame();
    final img = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final radius = size / 2.0;

    // fundo
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      Paint()..color = const Color(0xFF222222),
    );
    // recorte
    canvas.save();
    final path = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius - 4),
      );
    canvas.clipPath(path);
    canvas.drawImage(img, Offset(0, 0), Paint()..isAntiAlias = true);
    canvas.restore();
    // borda
    canvas.drawCircle(
      Offset(radius, radius),
      radius - 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFFFFC107),
    );

    final picture = recorder.endRecording();
    final png = await picture.toImage(size, size);
    final bytesOut = await png.toByteData(format: ui.ImageByteFormat.png);
    return bytesOut!.buffer.asUint8List();
  }

  Future<Uint8List> _initialsAvatarPng(
      {required String name, int size = 112}) async {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    final r = size / 2.0;

    // cor estável derivada do nome
    final bg = _colorFromString(name);
    // círculo
    canvas.drawCircle(Offset(r, r), r, Paint()..color = bg);
    // borda branca sutil
    canvas.drawCircle(
      Offset(r, r),
      r - 3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = const Color(0xFFFFFFFF).withOpacity(.9),
    );

    // texto (iniciais)
    final initials = _nameToInitials(name);
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: size * 0.38,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w700,
      ),
    )
      ..pushStyle(ui.TextStyle(color: const Color(0xFF111111)))
      ..addText(initials);
    final paragraph = pb.build()
      ..layout(ui.ParagraphConstraints(width: size.toDouble()));
    canvas.drawParagraph(paragraph, Offset(0, r - paragraph.height / 2));

    final img = await rec.endRecording().toImage(size, size);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  String _nameToInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    final take = parts.take(2).map((w) => w.characters.first.toUpperCase());
    final s = take.join();
    return s.isEmpty ? 'U' : s; // "Lucas Cesar" -> "LC"
  }

  Color _colorFromString(String s) {
    int h = 0;
    for (final c in s.codeUnits) {
      h = 0x1f * h + c;
    }
    final hue = (h % 360).toDouble();
    return HSVColor.fromAHSV(1, hue, 0.55, 0.85).toColor();
  }

  Future<Uint8List> _drawCarPng({int size = 96}) async {
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    final w = size.toDouble(), h = size.toDouble();

    // under-sombra
    c.drawOval(
      Rect.fromCenter(
          center: Offset(w * .5, h * .78), width: w * .58, height: h * .18),
      Paint()
        ..color = const Color(0xFF000000).withOpacity(.22)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
    );

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.28, w * 0.7, h * 0.44),
      const Radius.circular(14),
    );
    c.drawRRect(body, Paint()..color = const Color(0xFFFFC107)); // amarelo táxi
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.23, h * 0.34, w * 0.54, h * 0.18),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF2b7cff), // vidro
    );
    c.drawCircle(
        Offset(w * 0.28, h * 0.76), h * 0.08, Paint()..color = Colors.black87);
    c.drawCircle(
        Offset(w * 0.72, h * 0.76), h * 0.08, Paint()..color = Colors.black87);

    final pic = rec.endRecording();
    final img = await pic.toImage(size, size);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  // ---------- Rotas ----------
  Future<void> _planRoute() async {
    final origin = _gm(widget.driverLatLng);
    final destination =
        widget.pickedUp ? _gm(widget.placeLatLng) : _gm(widget.userLatLng);

    _lastRouteOrigin = widget.driverLatLng;
    _lastRouteDest = widget.pickedUp ? widget.placeLatLng : widget.userLatLng;

    _phaseText = widget.pickedUp ? 'To destination' : 'To pickup';

    final data = await _fetchDirections(
      origin: origin,
      destination: destination,
      apiKey: widget.apiKey,
    );
    if (data == null) return;

    final route = data['routes'][0];
    final leg = route['legs'][0];

    // steps + métricas
    final stepsJson = leg['steps'] as List<dynamic>;
    _steps = stepsJson.map((s) => _LegStep.fromJson(s)).toList();
    _remainingMeters = (leg['distance']['value'] as num).toDouble();
    final seconds = (leg['duration']['value'] as num).toInt();
    _etaText = _fmtEta(seconds);

    // polyline (decoder local, sem pacote)
    final encoded = route['overview_polyline']['points'] as String;
    final polyPoints = _decodePolyline(encoded);

    _polylines
      ..clear()
      // underlay escuro
      ..add(gmap.Polyline(
        polylineId: const gmap.PolylineId('route_under'),
        width: 12,
        color: Colors.black.withOpacity(.55),
        startCap: gmap.Cap.roundCap,
        endCap: gmap.Cap.roundCap,
        jointType: gmap.JointType.round,
        geodesic: true,
        points: polyPoints,
      ))
      // traço principal
      ..add(gmap.Polyline(
        polylineId: const gmap.PolylineId('route'),
        width: 8,
        color: const Color(0xFFFFA000),
        startCap: gmap.Cap.roundCap,
        endCap: gmap.Cap.roundCap,
        jointType: gmap.JointType.round,
        geodesic: true,
        points: polyPoints,
      ));

    // markers
    _markers
      ..clear()
      ..add(gmap.Marker(
        markerId: const gmap.MarkerId('driver'),
        position: origin,
        rotation: widget.driverHeading,
        icon: _carIcon ??
            gmap.BitmapDescriptor.defaultMarkerWithHue(
                gmap.BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.55),
        flat: true,
      ))
      ..add(gmap.Marker(
        markerId: const gmap.MarkerId('pickup'),
        position: _gm(widget.userLatLng),
        icon: _userAvatarIcon ??
            _userInitialsIcon ??
            gmap.BitmapDescriptor.defaultMarker,
        infoWindow: const gmap.InfoWindow(title: 'Pickup'),
        anchor: const Offset(0.5, 0.5),
        flat: true,
      ))
      ..add(gmap.Marker(
        markerId: const gmap.MarkerId('dropoff'),
        position: _gm(widget.placeLatLng),
        icon: gmap.BitmapDescriptor.defaultMarkerWithHue(
            gmap.BitmapDescriptor.hueRed),
        infoWindow: const gmap.InfoWindow(title: 'Destination'),
        flat: true,
      ));

    setState(() {});
    await _fitBounds(polyPoints);
    _updateCamera(animated: true);
  }

  Future<Map<String, dynamic>?> _fetchDirections({
    required gmap.LatLng origin,
    required gmap.LatLng destination,
    required String apiKey,
  }) async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving&language=en&alternatives=false&key=$apiKey';
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) return null;
    final data = json.decode(resp.body);
    if (data['status'] != 'OK') return null;
    return data;
  }

  // ---------- Decoder local de polyline (Google Encoded Polyline Algorithm) ----------
  List<gmap.LatLng> _decodePolyline(String encoded) {
    final List<gmap.LatLng> points = [];
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

      points.add(gmap.LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  // ---------- Atualização rápida do marcador do motorista ----------
  void _updateDriverMarker() {
    final newPos = _gm(widget.driverLatLng);
    _markers.removeWhere((m) => m.markerId.value == 'driver');
    _markers.add(gmap.Marker(
      markerId: const gmap.MarkerId('driver'),
      position: newPos,
      rotation: widget.driverHeading,
      icon: _carIcon ??
          gmap.BitmapDescriptor.defaultMarkerWithHue(
              gmap.BitmapDescriptor.hueAzure),
      anchor: const Offset(0.5, 0.55),
      flat: true,
    ));
    setState(() {});
  }

  // ---------- Câmera ----------
  Future<void> _fitBounds(List<gmap.LatLng> points) async {
    if (_map == null || points.isEmpty) return;
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    final bounds = gmap.LatLngBounds(
      southwest: gmap.LatLng(minLat, minLng),
      northeast: gmap.LatLng(maxLat, maxLng),
    );
    await _map!.animateCamera(gmap.CameraUpdate.newLatLngBounds(bounds, 60));
  }

  void _updateCamera({required bool animated}) {
    if (_map == null) return;
    final target = _gm(widget.driverLatLng);

    final cam = _cameraMode == _CameraMode.follow
        ? gmap.CameraPosition(
            target: target,
            zoom: 17.2,
            bearing: widget.driverHeading,
            tilt: 55,
          )
        : gmap.CameraPosition(
            target: target,
            zoom: 15.0,
            bearing: 0,
            tilt: 0,
          );

    final upd = gmap.CameraUpdate.newCameraPosition(cam);
    if (animated) {
      _map!.animateCamera(upd);
    } else {
      _map!.moveCamera(upd);
    }
  }

  // ---------- Distância e ETA ----------
  double _dist(ff.LatLng a, gmap.LatLng b) {
    final la = gmap.LatLng(a.latitude, a.longitude);
    return _haversine(la, b);
  }

  double _haversine(gmap.LatLng a, gmap.LatLng b) {
    const R = 6371000.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final la1 = _deg2rad(a.latitude);
    final la2 = _deg2rad(b.latitude);

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * R * math.asin(math.min(1, math.sqrt(h)));
  }

  double _deg2rad(double d) => d * math.pi / 180.0;

  String _fmtEta(int seconds) {
    if (seconds <= 59) return '1 min';
    final mins = (seconds / 60).ceil();
    return '$mins min';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // mapa
            gmap.GoogleMap(
              initialCameraPosition: gmap.CameraPosition(
                target: _gm(widget.userLatLng),
                zoom: 13,
              ),
              onMapCreated: (c) async {
                _map = c;
                await _applyDarkStyle(); // aplica estilo antes
                await Future.delayed(const Duration(milliseconds: 180));
                if (mounted) setState(() => _veilVisible = false);
                await Future.delayed(const Duration(milliseconds: 70));
                _updateCamera(animated: false);
              },
              polylines: _polylines,
              markers: _markers,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              trafficEnabled: true,
              buildingsEnabled: true,
              tiltGesturesEnabled: false,
              mapToolbarEnabled: false,
            ),

            // véu antipisca
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _veilVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: Container(color: Colors.black),
              ),
            ),

            // Card de status
            Positioned(
              top: 72,
              left: 14,
              right: 14,
              child: _InfoCard(
                phaseText: _phaseText,
                etaText: _etaText,
                remainingMeters: _remainingMeters,
              ),
            ),

            // Botões à direita
            Positioned(
              right: 14,
              bottom: 14,
              child: Column(
                children: [
                  _RoundBtn(
                    icon: Icons.switch_camera_outlined,
                    onTap: () {
                      setState(() {
                        _cameraMode = _cameraMode == _CameraMode.follow
                            ? _CameraMode.topDown
                            : _CameraMode.follow;
                      });
                      _updateCamera(animated: true);
                    },
                    tooltip: _cameraMode == _CameraMode.follow
                        ? 'Top-Down view'
                        : 'Follow view',
                  ),
                  const SizedBox(height: 10),
                  _RoundBtn(
                    icon: Icons.refresh,
                    onTap: _planRoute,
                    tooltip: 'Re-route',
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

// ====== UI components ======
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.phaseText,
    required this.etaText,
    required this.remainingMeters,
  });

  final String phaseText;
  final String etaText;
  final double remainingMeters;

  @override
  Widget build(BuildContext context) {
    final km = (remainingMeters / 1000).clamp(0, 9999).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.78),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.map_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phaseText,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text('$etaText • $km km',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16, height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.82),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

// ===== modelo simples de step (guardamos distancia para ETA) =====
class _LegStep {
  final double distanceMeters;
  _LegStep({required this.distanceMeters});

  factory _LegStep.fromJson(Map<String, dynamic> json) {
    final dist = (json['distance']['value'] as num).toDouble();
    return _LegStep(distanceMeters: dist);
  }
}
