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

import 'package:http/http.dart' as http;
import 'package:characters/characters.dart';
import 'package:path_provider/path_provider.dart';

import '/flutter_flow/lat_lng.dart' as ff;
import 'package:google_maps_native_sdk/google_maps_native_sdk.dart' as nmap;

class RideViewerNav extends StatefulWidget {
  const RideViewerNav({
    Key? key,
    required this.apiKey,
    required this.userLatLng,
    required this.placeLatLng,
    required this.driverLatLng,
    this.driverHeading = 0,
    this.pickedUp = false,
    this.userPhotoUrl,
    this.userDisplayName,
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
  nmap.GoogleMapController? _map;

  final Set<String> _markerIds = <String>{};
  final Set<String> _polylineIds = <String>{};

  List<nmap.LatLng> _route = <nmap.LatLng>[];
  double _remainingMeters = 0;
  String _etaText = '';
  String _phaseText = 'To pickup';

  _CameraMode _cameraMode = _CameraMode.follow;

  Uint8List? _userAvatarBytes;
  Uint8List? _carBytes;

  ff.LatLng? _lastRouteOrigin;
  ff.LatLng? _lastRouteDest;

  bool _veilVisible = true;

  static const String _darkMapStyle =
      '[{"elementType":"geometry","stylers":[{"color":"#1d1d1d"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#8f8f8f"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#1d1d1d"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a2a2a"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#202020"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#b0b0b0"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#242424"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#172117"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#0b0b0b"}]},{"featureType":"transit","stylers":[{"visibility":"off"}]}]';

  nmap.LatLng _gm(ff.LatLng v) => nmap.LatLng(v.latitude, v.longitude);

  @override
  void initState() {
    super.initState();
    _prepareIcons();
  }

  @override
  void didUpdateWidget(covariant RideViewerNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ff.LatLng originFF = widget.driverLatLng;
    final ff.LatLng destFF =
        widget.pickedUp ? widget.placeLatLng : widget.userLatLng;
    final bool needRoute = _lastRouteOrigin == null ||
        _lastRouteDest == null ||
        _haversineFF(_lastRouteOrigin!, originFF) > 8 ||
        _haversineFF(_lastRouteDest!, destFF) > 8 ||
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
    super.dispose();
  }

  Future<void> _prepareIcons() async {
    _carBytes ??= await _drawCarPng(size: 110);
    _userAvatarBytes = await _buildUserAvatarBytes(
      size: 140,
      photoUrl: widget.userPhotoUrl,
      name: widget.userDisplayName?.trim().isNotEmpty == true
          ? widget.userDisplayName!.trim()
          : 'Usuário',
    );
    if (mounted) setState(() {});
    _planRoute();
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
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
            nmap.GoogleMapView(
              initialCameraPosition: nmap.CameraPosition(
                target: _gm(widget.userLatLng),
                zoom: 13,
              ),
              mapStyleJson: _darkMapStyle,
              buildingsEnabled: true,
              trafficEnabled: false,
              myLocationEnabled: false,
              padding: const nmap.MapPadding(),
              onMapCreated: (c) async {
                _map = c;
                try {
                  await c.onMapLoaded;
                } catch (_) {}
                try {
                  final dynamic dc = _map;
                  await dc.animateCameraBy(dx: 0.1, dy: 0);
                  await Future<void>.delayed(const Duration(milliseconds: 40));
                  await dc.animateCameraBy(dx: -0.1, dy: 0);
                } catch (_) {}
                if (mounted) setState(() => _veilVisible = false);
                await Future<void>.delayed(const Duration(milliseconds: 70));
                _updateCamera(animated: false);
              },
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: AbsorbPointer(
                absorbing: true,
                child: const SizedBox(width: 96, height: 60),
              ),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _veilVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: const ColoredBox(color: Colors.black),
              ),
            ),
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

  Future<void> _planRoute() async {
    if (_map == null) return;
    final nmap.LatLng origin = _gm(widget.driverLatLng);
    final nmap.LatLng destination =
        widget.pickedUp ? _gm(widget.placeLatLng) : _gm(widget.userLatLng);

    _lastRouteOrigin = widget.driverLatLng;
    _lastRouteDest = widget.pickedUp ? widget.placeLatLng : widget.userLatLng;
    _phaseText = widget.pickedUp ? 'To destination' : 'To pickup';

    Map<String, dynamic>? data;

    final String key = widget.apiKey.trim();
    bool usedRoutesV2 = false;
    if (key.isNotEmpty) {
      try {
        final res = await nmap.RoutesApi.computeRoutes(
          apiKey: key,
          origin: nmap.Waypoint(location: origin),
          destination: nmap.Waypoint(location: destination),
          languageCode: 'en',
          alternatives: false,
        );
        if (res.routes.isNotEmpty) {
          final r = res.routes.first;
          _route = r.points
              .map((p) => nmap.LatLng(p.latitude, p.longitude))
              .toList();
          usedRoutesV2 = _route.length >= 2;
          if (usedRoutesV2) {
            final meters = (r.distanceMeters ?? 0).toDouble();
            _remainingMeters = meters;
            final secs = _estimateEtaSecondsFromMeters(meters);
            _etaText = _fmtEta(secs);
          }
        }
      } catch (_) {
        usedRoutesV2 = false;
      }
    }

    if (!usedRoutesV2) {
      data = await _fetchDirections(
          origin: origin, destination: destination, apiKey: key);
      if (data == null) return;
      final route = data['routes'][0];
      final leg = route['legs'][0];
      _remainingMeters = (leg['distance']['value'] as num).toDouble();
      final seconds = (leg['duration']['value'] as num).toInt();
      _etaText = _fmtEta(seconds);
      final encoded = route['overview_polyline']['points'] as String;
      _route = _decodePolyline(encoded);
    }

    await _drawRoutePolylines(_route);
    await _placeCoreMarkers(origin, destination);
    await _fitBounds(_route);
    _updateCamera(animated: true);
  }

  int _estimateEtaSecondsFromMeters(double meters) {
    // estimativa: mais curto => mais lento; mais longo => mais rápido
    final km = meters / 1000.0;
    final double kmh = (km < 3)
        ? 25.0 // trânsito local
        : (km < 15)
            ? 40.0 // urbano/arteriais
            : 55.0; // trechos mais rápidos
    final secs = ((km / kmh) * 3600.0).round();
    return secs.clamp(60, 24 * 3600);
  }

  Future<void> _placeCoreMarkers(
      nmap.LatLng origin, nmap.LatLng destination) async {
    await _addOrUpdateMarker(
      id: 'driver',
      position: origin,
      rotation: widget.driverHeading,
      anchorU: 0.5,
      anchorV: 0.55,
      zIndex: 30,
      title: null,
      bytesIcon: _carBytes,
    );

    await _addOrUpdateMarker(
      id: 'pickup',
      position: _gm(widget.userLatLng),
      anchorU: 0.5,
      anchorV: 0.5,
      zIndex: 20,
      title: 'Pickup',
      bytesIcon: _userAvatarBytes,
    );

    await _addOrUpdateMarker(
      id: 'dropoff',
      position: _gm(widget.placeLatLng),
      anchorU: 0.5,
      anchorV: 1.0,
      zIndex: 20,
      title: 'Destination',
    );
  }

  Future<void> _updateDriverMarker() async {
    final nmap.LatLng newPos = _gm(widget.driverLatLng);
    if (!_markerIds.contains('driver')) {
      await _addOrUpdateMarker(
        id: 'driver',
        position: newPos,
        rotation: widget.driverHeading,
        anchorU: 0.5,
        anchorV: 0.55,
        zIndex: 30,
        bytesIcon: _carBytes,
      );
      return;
    }
    try {
      await _map?.updateMarker('driver',
          position: newPos, rotation: widget.driverHeading);
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> _fetchDirections({
    required nmap.LatLng origin,
    required nmap.LatLng destination,
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

  Future<void> _drawRoutePolylines(List<nmap.LatLng> pts) async {
    if (_map == null || pts.isEmpty) return;
    await _addOrUpdatePolyline(
      id: 'route_under',
      points: pts,
      width: 12.0,
      color: Colors.black.withOpacity(.55),
      geodesic: true,
    );
    await _addOrUpdatePolyline(
      id: 'route',
      points: pts,
      width: 8.0,
      color: const Color(0xFFFFA000),
      geodesic: true,
    );
  }

  Future<void> _fitBounds(List<nmap.LatLng> points) async {
    if (_map == null || points.isEmpty) return;
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final ne = nmap.LatLng(maxLat, maxLng);
    final sw = nmap.LatLng(minLat, minLng);
    try {
      await _map!.animateToBounds(ne, sw, padding: 60);
    } catch (_) {}
  }

  void _updateCamera({required bool animated}) {
    if (_map == null) return;
    final nmap.LatLng target = _gm(widget.driverLatLng);
    if (_cameraMode == _CameraMode.follow) {
      final dynamic dc = _map;
      if (animated) {
        dc.animateCameraTo(
          target: target,
          zoom: 17.2,
          bearing: widget.driverHeading,
          tilt: 55.0,
          durationMs: 350,
        );
      } else {
        dc.moveCamera(
          target,
          zoom: 17.2,
          bearing: widget.driverHeading,
          tilt: 55.0,
        );
      }
    } else {
      final dynamic dc = _map;
      if (animated) {
        dc.animateCameraTo(
          target: target,
          zoom: 15.0,
          bearing: 0.0,
          tilt: 0.0,
          durationMs: 350,
        );
      } else {
        dc.moveCamera(target, zoom: 15.0);
      }
    }
  }

  double _haversineFF(ff.LatLng a, ff.LatLng b) {
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

  Future<void> _addOrUpdateMarker({
    required String id,
    required nmap.LatLng position,
    double? rotation,
    required double anchorU,
    required double anchorV,
    required double zIndex,
    String? title,
    Uint8List? bytesIcon,
  }) async {
    if (!_markerIds.contains(id)) {
      try {
        await _map?.addMarker(nmap.MarkerOptions(
          id: id,
          position: position,
          title: title,
          anchorU: anchorU,
          anchorV: anchorV,
          zIndex: zIndex,
          rotation: (rotation ?? 0).toDouble(),
        ));
        _markerIds.add(id);
      } catch (_) {}
    } else {
      try {
        await _map?.updateMarker(
          id,
          position: position,
          rotation: (rotation ?? 0).toDouble(),
        );
      } catch (_) {}
    }
    if (bytesIcon != null) {
      try {
        final dynamic dc = _map;
        await dc.setMarkerIconBytes(id: id, bytes: bytesIcon);
      } catch (_) {
        await _fallbackMarkerIconFile(
            id, position, title, anchorU, anchorV, zIndex, bytesIcon);
      }
    }
  }

  Future<void> _fallbackMarkerIconFile(
      String id,
      nmap.LatLng pos,
      String? title,
      double anchorU,
      double anchorV,
      double zIndex,
      Uint8List bytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/marker_${DateTime.now().microsecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes, flush: true);
      if (_markerIds.contains(id)) {
        try {
          await _map?.removeMarker(id);
        } catch (_) {}
        _markerIds.remove(id);
      }
      await _map?.addMarker(nmap.MarkerOptions(
        id: id,
        position: pos,
        title: title,
        iconUrl: 'file://${file.path}',
        anchorU: anchorU,
        anchorV: anchorV,
        zIndex: zIndex,
        rotation: 0.0,
      ));
      _markerIds.add(id);
    } catch (_) {}
  }

  Future<void> _addOrUpdatePolyline({
    required String id,
    required List<nmap.LatLng> points,
    required double width,
    required Color color,
    bool geodesic = true,
  }) async {
    if (!_polylineIds.contains(id)) {
      try {
        await _map?.addPolyline(nmap.PolylineOptions(
          id: id,
          points: points,
          width: width,
          color: color,
          geodesic: geodesic,
        ));
        _polylineIds.add(id);
      } catch (_) {}
      return;
    }
    try {
      await _map?.updatePolylinePoints(id, points);
    } catch (_) {
      try {
        await _map?.removePolyline(id);
        await _map?.addPolyline(nmap.PolylineOptions(
          id: id,
          points: points,
          width: width,
          color: color,
          geodesic: geodesic,
        ));
      } catch (_) {}
    }
  }

  Future<Uint8List> _buildUserAvatarBytes(
      {required int size, String? photoUrl, required String name}) async {
    Uint8List? photo;
    if ((photoUrl ?? '').trim().isNotEmpty) {
      try {
        final resp = await http
            .get(Uri.parse(photoUrl!.replaceFirst('http://', 'https://')));
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          final ui.Codec codec = await ui.instantiateImageCodec(resp.bodyBytes,
              targetWidth: size, targetHeight: size);
          final ui.FrameInfo frame = await codec.getNextFrame();
          final ui.Image img = frame.image;
          final rec = ui.PictureRecorder();
          final c = ui.Canvas(rec);
          final s = size.toDouble();
          final r = s / 2;
          final rect = ui.Rect.fromLTWH(0, 0, s, s);
          c.drawCircle(
              ui.Offset(r, r), r, ui.Paint()..color = const Color(0xFF222222));
          c.save();
          c.clipPath(ui.Path()
            ..addOval(
                ui.Rect.fromCircle(center: ui.Offset(r, r), radius: r - 4)));
          c.drawImageRect(
              img,
              ui.Rect.fromLTWH(
                  0, 0, img.width.toDouble(), img.height.toDouble()),
              rect,
              ui.Paint());
          c.restore();
          c.drawCircle(
              ui.Offset(r, r),
              r - 2,
              ui.Paint()
                ..style = ui.PaintingStyle.stroke
                ..strokeWidth = 4
                ..color = const Color(0xFFFFC107));
          final picture = rec.endRecording();
          final out = await picture.toImage(size, size);
          final data = await out.toByteData(format: ui.ImageByteFormat.png);
          return data!.buffer.asUint8List();
        }
      } catch (_) {}
    }
    return _initialsAvatarPng(name: name, size: size);
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
      r - 3,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = const Color(0xFFFFFFFF).withOpacity(.9),
    );
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
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    final take = parts.take(2).map((w) => w.characters.first.toUpperCase());
    final s = take.join();
    return s.isEmpty ? 'U' : s;
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
    final c = ui.Canvas(rec);
    final w = size.toDouble(), h = size.toDouble();
    c.drawOval(
      ui.Rect.fromCenter(
          center: ui.Offset(w * .5, h * .78), width: w * .58, height: h * .18),
      ui.Paint()
        ..color = const Color(0xFF000000).withOpacity(.22)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
    );
    final body = ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(w * 0.15, h * 0.28, w * 0.7, h * 0.44),
      const ui.Radius.circular(14),
    );
    c.drawRRect(body, ui.Paint()..color = const Color(0xFFFFC107));
    c.drawRRect(
      ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(w * 0.23, h * 0.34, w * 0.54, h * 0.18),
        const ui.Radius.circular(10),
      ),
      ui.Paint()..color = const Color(0xFF2b7cff),
    );
    c.drawCircle(ui.Offset(w * 0.28, h * 0.76), h * 0.08,
        ui.Paint()..color = const Color(0xFF111111));
    c.drawCircle(ui.Offset(w * 0.72, h * 0.76), h * 0.08,
        ui.Paint()..color = const Color(0xFF111111));
    final pic = rec.endRecording();
    final img = await pic.toImage(size, size);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(
      {required this.phaseText,
      required this.etaText,
      required this.remainingMeters});
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
          borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        const Icon(Icons.map_rounded, color: Colors.white, size: 28),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(phaseText,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 2),
          Text('$etaText • $km km',
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, height: 1.2)),
        ])),
      ]),
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
              color: Colors.black.withOpacity(0.82), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white)),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}
