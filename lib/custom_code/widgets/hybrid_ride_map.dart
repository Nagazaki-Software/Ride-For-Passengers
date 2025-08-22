// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

// Google (Android)
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
// Apple (iOS)
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amap;

// Localização (foreground/web)
import 'package:geolocator/geolocator.dart';

class HybridRideMap extends StatefulWidget {
  const HybridRideMap({
    Key? key,
    required this.rideRequested,
    required this.users,
    required this.width,
    required this.height,
    this.destLat,
    this.destLng,
    this.nearbyRadiusMeters = 1500,
    this.encodedPolyline,
  }) : super(key: key);

  final bool rideRequested;
  final List<UsersRecord> users;
  final double width;
  final double height;

  final double? destLat;
  final double? destLng;
  final double nearbyRadiusMeters;
  final String? encodedPolyline;

  @override
  State<HybridRideMap> createState() => _HybridRideMapState();
}

class _Point {
  final double lat;
  final double lng;
  const _Point(this.lat, this.lng);
}

class _HybridRideMapState extends State<HybridRideMap> {
  gmap.GoogleMapController? _gController;
  amap.AppleMapController? _aController;

  _Point? _me;
  StreamSubscription<Position>? _posSub;

  final Set<gmap.Marker> _gMarkers = {};
  final Set<amap.Annotation> _aAnnotations = {};

  final Set<gmap.Polyline> _gPolylines = {};
  final Set<amap.Polyline> _aPolylines = {};

  bool _locationReady = false;
  bool _cameraCenteredOnce = false;

  // Google map dark style
  static const String _googleGreyStyle = r'''[
  {"elementType":"geometry","stylers":[{"color":"#1f1f1f"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#a3a3a3"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1f1f1f"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#2a2a2a"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#bfbfbf"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2b2b2b"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2a2a2a"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0f0f0f"}]}
]''';

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _ensureLocation();
  }

  @override
  void didUpdateWidget(covariant HybridRideMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshLayers();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  Future<void> _ensureLocation() async {
    try {
      // Serviços ativos?
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Opcional: await Geolocator.openLocationSettings();
      }

      // Permissões
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationReady = false);
        return;
      }

      // Posição atual
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (!mounted) return;
      setState(() {
        _me = _Point(p.latitude, p.longitude);
        _locationReady = true;
      });

      // Stream com debounce
      _posSub?.cancel();
      Position? lastEmit;
      DateTime lastTime = DateTime.fromMillisecondsSinceEpoch(0);
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
        ),
      ).listen((pos) {
        if (!mounted) return;

        final now = DateTime.now();
        final tooSoon = now.difference(lastTime).inMilliseconds < 600;
        final similar = lastEmit != null &&
            (Geolocator.distanceBetween(
                  lastEmit!.latitude,
                  lastEmit!.longitude,
                  pos.latitude,
                  pos.longitude,
                ) <
                1.5);

        if (tooSoon || similar) return;

        lastEmit = pos;
        lastTime = now;

        setState(() => _me = _Point(pos.latitude, pos.longitude));
        _animateToUserIfNeeded();
        _refreshLayers();
      });

      _animateToUserIfNeeded(initial: true);
      _refreshLayers();
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void _animateToUserIfNeeded({bool initial = false}) {
    if (_me == null) return;
    final lat = _me!.lat;
    final lng = _me!.lng;

    if (!initial && _cameraCenteredOnce) return;

    if (_isIOS) {
      final c = _aController;
      if (c == null) return;
      c.moveCamera(
        amap.CameraUpdate.newCameraPosition(
          amap.CameraPosition(target: amap.LatLng(lat, lng), zoom: 15),
        ),
      );
    } else if (_isAndroid) {
      final c = _gController;
      if (c == null) return;
      c.animateCamera(
        gmap.CameraUpdate.newCameraPosition(
          gmap.CameraPosition(target: gmap.LatLng(lat, lng), zoom: 15),
        ),
      );
    }

    _cameraCenteredOnce = true;
  }

  void _refreshLayers() {
    if (_isIOS) {
      _buildAppleAnnotationsFromUsers();
      _buildAppleRoutePolyline();
    } else if (_isAndroid) {
      _buildGoogleMarkersFromUsers();
      _buildGoogleRoutePolyline();
    }
    if (mounted) setState(() {}); // uma única atualização visual
  }

  // ---------- Helpers de UsersRecord ----------
  dynamic _readField(UsersRecord u, String key) {
    try {
      if (u.snapshotData.containsKey(key)) return u.snapshotData[key];
    } catch (_) {}
    return null;
  }

  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  _DriverPos? _extractDriverPos(UsersRecord u) {
    final loc = _readField(u, 'location'); // LatLng do FF
    if (loc is LatLng) {
      final la = loc.latitude, lo = loc.longitude;
      if (la.isFinite && lo.isFinite) {
        return _DriverPos(lat: la, lng: lo);
      }
    }
    final lat = _asDouble(_readField(u, 'lat'));
    final lng = _asDouble(_readField(u, 'lng'));
    if (lat == null || lng == null) return null;
    if (!lat.isFinite || !lng.isFinite) return null;
    return _DriverPos(lat: lat, lng: lng);
  }

  double _extractHeading(UsersRecord u) {
    final h = _asDouble(_readField(u, 'heading'));
    final b = _asDouble(_readField(u, 'bearing'));
    return (h ?? b ?? 0.0);
  }

  bool _isOnline(UsersRecord u) {
    final on = _readField(u, 'isOnline');
    if (on is bool) return on;
    return true;
  }

  // ---------- ANDROID (Google) ----------
  void _buildGoogleMarkersFromUsers() {
    _gMarkers.clear();
    if (_me == null || widget.users.isEmpty) return;

    final userLat = _me!.lat;
    final userLng = _me!.lng;

    for (int i = 0; i < widget.users.length; i++) {
      final u = widget.users[i];
      if (!_isOnline(u)) continue;

      final pos = _extractDriverPos(u);
      if (pos == null) continue;

      final distM = Geolocator.distanceBetween(userLat, userLng, pos.lat, pos.lng);
      if (distM > widget.nearbyRadiusMeters) continue;

      final heading = _extractHeading(u);
      final veryNear = distM < 120.0;

      _gMarkers.add(
        gmap.Marker(
          markerId: gmap.MarkerId('driver_$i'),
          position: gmap.LatLng(pos.lat, pos.lng),
          rotation: heading,
          flat: true,
          icon: gmap.BitmapDescriptor.defaultMarkerWithHue(veryNear ? 12 : 42),
        ),
      );
    }
  }

  void _buildGoogleRoutePolyline() {
    _gPolylines.clear();

    final hasDest = (widget.destLat != null && widget.destLng != null);
    if (!widget.rideRequested || _me == null || !hasDest) return;

    final user = gmap.LatLng(_me!.lat, _me!.lng);
    final destG = gmap.LatLng(widget.destLat!, widget.destLng!);

    final encoded = (widget.encodedPolyline ?? '').trim();
    List<gmap.LatLng> gpts;
    if (encoded.isNotEmpty && encoded.toLowerCase() != 'null') {
      final decoded = _safeDecode(encoded);
      if (decoded.isNotEmpty) {
        gpts = decoded.map((p) => gmap.LatLng(p.latitude, p.longitude)).toList();
      } else {
        gpts = [user, destG];
      }
    } else {
      gpts = [user, destG];
    }

    _gPolylines.add(
      gmap.Polyline(
        polylineId: const gmap.PolylineId('route'),
        points: gpts,
        width: 5,
        color: Colors.orangeAccent,
        geodesic: true,
      ),
    );
  }

  // ---------- iOS (Apple) ----------
  void _buildAppleAnnotationsFromUsers() {
    _aAnnotations.clear();
    if (_me == null || widget.users.isEmpty) return;

    final userLat = _me!.lat;
    final userLng = _me!.lng;

    for (int i = 0; i < widget.users.length; i++) {
      final u = widget.users[i];
      if (!_isOnline(u)) continue;

      final pos = _extractDriverPos(u);
      if (pos == null) continue;

      final distM = Geolocator.distanceBetween(userLat, userLng, pos.lat, pos.lng);
      if (distM > widget.nearbyRadiusMeters) continue;

      final veryNear = distM < 120.0;

      _aAnnotations.add(
        amap.Annotation(
          annotationId: amap.AnnotationId('driver_$i'),
          position: amap.LatLng(pos.lat, pos.lng),
          infoWindow: amap.InfoWindow(
            title: veryNear ? 'Driver (nearby)' : 'Driver',
            snippet: veryNear ? '≈ ${distM.toStringAsFixed(0)} m' : 'Nearby',
          ),
        ),
      );
    }
  }

  void _buildAppleRoutePolyline() {
    _aPolylines.clear();

    final hasDest = (widget.destLat != null && widget.destLng != null);
    if (!widget.rideRequested || _me == null || !hasDest) return;

    final user = amap.LatLng(_me!.lat, _me!.lng);
    final destA = amap.LatLng(widget.destLat!, widget.destLng!);

    final encoded = (widget.encodedPolyline ?? '').trim();
    List<amap.LatLng> apts;
    if (encoded.isNotEmpty && encoded.toLowerCase() != 'null') {
      final decoded = _safeDecode(encoded);
      if (decoded.isNotEmpty) {
        apts = decoded.map((p) => amap.LatLng(p.latitude, p.longitude)).toList();
      } else {
        apts = [user, destA];
      }
    } else {
      apts = [user, destA];
    }

    _aPolylines.add(
      amap.Polyline(
        polylineId: const amap.PolylineId('route'),
        points: apts,
        width: 5,
        color: Colors.orangeAccent,
      ),
    );
  }

  // --- Polyline decoder (safe) ---
  List<_LatLng> _safeDecode(String encoded) {
    try {
      return _decodePolyline(encoded);
    } catch (e) {
      debugPrint('Polyline decode error: $e');
      return const <_LatLng>[];
    }
  }

  List<_LatLng> _decodePolyline(String encoded) {
    final poly = <_LatLng>[];
    int index = 0, lat = 0, lng = 0;
    final len = encoded.length;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        if (index >= len) return poly;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        if (index >= len) return poly;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(_LatLng(lat / 1e5, lng / 1e5));
    }
    return poly;
  }

  @override
  Widget build(BuildContext context) {
    final hasMe = _me != null && _me!.lat.isFinite && _me!.lng.isFinite;
    final hasDest = widget.destLat != null && widget.destLng != null;

    final startLat = hasMe ? _me!.lat : (hasDest ? widget.destLat! : -15.793889);
    final startLng = hasMe ? _me!.lng : (hasDest ? widget.destLng! : -47.882778);

    if (_isIOS) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: amap.AppleMap(
            initialCameraPosition: amap.CameraPosition(
              target: amap.LatLng(startLat, startLng),
              zoom: hasMe ? 14 : 4,
            ),
            onMapCreated: (c) => _aController = c,
            mapType: amap.MapType.standard,
            myLocationEnabled: _locationReady,
            annotations: _aAnnotations,
            polylines: _aPolylines,
          ),
        ),
      );
    }

    // Android (Google) e Web
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: gmap.GoogleMap(
          initialCameraPosition: gmap.CameraPosition(
            target: gmap.LatLng(startLat, startLng),
            zoom: hasMe ? 14 : 4,
          ),
          onMapCreated: (c) async {
            _gController = c;
            try {
              await c.setMapStyle(_googleGreyStyle);
            } catch (_) {}
            _animateToUserIfNeeded(initial: true);
          },
          myLocationEnabled: _locationReady,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          buildingsEnabled: false,
          markers: _gMarkers,
          polylines: _gPolylines,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }
}

class _LatLng {
  final double latitude;
  final double longitude;
  const _LatLng(this.latitude, this.longitude);
}

class _DriverPos {
  final double lat;
  final double lng;
  const _DriverPos({required this.lat, required this.lng});
}
