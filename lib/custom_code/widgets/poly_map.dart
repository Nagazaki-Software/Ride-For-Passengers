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
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '/flutter_flow/lat_lng.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_native_sdk/google_maps_native_sdk.dart' as nmap;

class PolyMap extends StatefulWidget {
  const PolyMap({
    super.key,
    this.width,
    this.height,
    required this.userLocation,
    this.driversRefs,
    this.refreshMs = 8000,
  });

  final double? width;
  final double? height;
  final LatLng userLocation;
  final List<DocumentReference>? driversRefs;
  final int refreshMs;

  @override
  State<PolyMap> createState() => _PolyMapState();
}

class _PolyMapState extends State<PolyMap> {
  nmap.GoogleMapController? _controller;

  final Set<String> _markerIds = <String>{};
  final Map<String, nmap.LatLng> _markerPos = {};
  final Map<String, String> _markerTitle = {};

  final Map<String, StreamSubscription<DocumentSnapshot>> _refsSubs = {};

  Timer? _autoFitTimer;
  Uint8List? _userDotPng;

  static const _darkMapStyle =
      '[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#2b2b2b"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f2f2f"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}]';

  nmap.LatLng _gm(LatLng p) => nmap.LatLng(p.latitude, p.longitude);

  @override
  void initState() {
    super.initState();
    _autoFitTimer =
        Timer.periodic(Duration(milliseconds: widget.refreshMs), (_) async {
      await _fitToContent(padding: 60);
    });
  }

  @override
  void dispose() {
    _autoFitTimer?.cancel();
    for (final s in _refsSubs.values) {
      s.cancel();
    }
    _refsSubs.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? double.infinity;
    final h = widget.height ?? 320.0;

    final initialCamera = nmap.CameraPosition(
      target: _gm(widget.userLocation),
      zoom: 13.0,
    );

    return SizedBox(
      width: w,
      height: h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
            nmap.GoogleMapView(
              key: const ValueKey('PolyMapNative'),
              initialCameraPosition: initialCamera,
              myLocationEnabled: false,
              trafficEnabled: false,
              buildingsEnabled: true,
              mapStyleJson: _darkMapStyle,
              onMapCreated: (nmap.GoogleMapController c) async {
                _controller = c;
                try {
                  await c.onMapLoaded;
                } catch (_) {}
                await _placeUserMarker();
                _subscribeDriversRefs();
                await _fitToContent(padding: 60);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeUserMarker() async {
    if (_controller == null) return;
    final id = 'user';
    final pos = _gm(widget.userLocation);

    if (!_markerIds.contains(id)) {
      await _controller!.addMarker(nmap.MarkerOptions(
        id: id,
        position: pos,
        title: 'Você',
        anchorU: 0.5,
        anchorV: 0.5,
        zIndex: 30.0,
      ));
      _markerIds.add(id);
      _markerPos[id] = pos;
      _markerTitle[id] = 'Você';
    } else {
      await _controller!.updateMarker(id, position: pos);
      _markerPos[id] = pos;
    }

    _userDotPng ??= await _buildDotPng(
        color: const Color(0xFFFFC107), size: 28, ring: true);
    try {
      final dynamic dc = _controller;
      await dc.setMarkerIconBytes(id: id, bytes: _userDotPng!);
    } catch (_) {}
  }

  void _subscribeDriversRefs() {
    for (final s in _refsSubs.values) {
      s.cancel();
    }
    _refsSubs.clear();

    final refs = widget.driversRefs;
    if (refs == null) return;

    for (final ref in refs) {
      final id = ref.id;
      _refsSubs[id] = ref.snapshots().listen((snap) async {
        if (!mounted) return;
        if (!snap.exists) {
          if (_markerIds.contains('driver_$id')) {
            try {
              await _controller?.removeMarker('driver_$id');
            } catch (_) {}
            _markerIds.remove('driver_$id');
          }
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

        final String name = (data?['display_name'] ?? 'Driver').toString();
        final String photoUrl = (data?['photo_url'] ?? '').toString();

        await _upsertDriverMarker(
          id: id,
          name: name,
          photoUrl: photoUrl,
          position: p,
        );
      });
    }
  }

  Future<void> _upsertDriverMarker({
    required String id,
    required String name,
    required String photoUrl,
    required nmap.LatLng position,
  }) async {
    final mid = 'driver_$id';

    if (_markerIds.contains(mid)) {
      await _controller?.updateMarker(mid, position: position);
      _markerPos[mid] = position;
    } else {
      await _controller?.addMarker(nmap.MarkerOptions(
        id: mid,
        position: position,
        title: name,
        anchorU: 0.5,
        anchorV: 0.62,
        zIndex: 22.0,
      ));
      _markerIds.add(mid);
      _markerPos[mid] = position;
      _markerTitle[mid] = name;
    }

    Uint8List? bytes;
    if (photoUrl.isNotEmpty) {
      bytes = await _circleImagePng(photoUrl, size: 96);
    }
    bytes ??= await _buildDotPng(color: const Color(0xFFFFC107), size: 32);

    try {
      final dynamic dc = _controller;
      await dc.setMarkerIconBytes(id: mid, bytes: bytes);
    } catch (_) {}
  }

  Future<void> _fitToContent({double padding = 60}) async {
    if (_controller == null) return;
    if (_markerIds.isEmpty) return;

    double? minLat, maxLat, minLng, maxLng;
    for (final id in _markerIds) {
      final p = _markerPos[id];
      if (p == null) continue;
      minLat = (minLat == null) ? p.latitude : math.min(minLat, p.latitude);
      maxLat = (maxLat == null) ? p.latitude : math.max(maxLat, p.latitude);
      minLng = (minLng == null) ? p.longitude : math.min(minLng, p.longitude);
      maxLng = (maxLng == null) ? p.longitude : math.max(maxLng, p.longitude);
    }
    if (minLat == null || minLng == null || maxLat == null || maxLng == null)
      return;

    final ne = nmap.LatLng(maxLat!, maxLng!);
    final sw = nmap.LatLng(minLat!, minLng!);
    try {
      await _controller!.animateToBounds(ne, sw, padding: padding);
    } catch (_) {}
  }

  Future<Uint8List> _buildDotPng(
      {Color color = const Color(0xFFFFC107),
      int size = 28,
      bool ring = true}) async {
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
    return bytes!.buffer.asUint8List();
  }

  Future<Uint8List?> _download(String url) async {
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) return resp.bodyBytes;
    } catch (_) {}
    return null;
  }

  Future<Uint8List> _circleImagePng(String url, {int size = 96}) async {
    final raw = await _download(url);
    if (raw == null) return _buildDotPng();
    final codec = await ui.instantiateImageCodec(raw,
        targetWidth: size, targetHeight: size);
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
    return bytes!.buffer.asUint8List();
  }
}
