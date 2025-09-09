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
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart' show PlatformViewHitTestBehavior;

import '/flutter_flow/lat_lng.dart';

/// Controller that exposes imperative methods to interact with the native map.
///
/// The controller simply forwards commands to the underlying platform
/// implementation via [MethodChannel].  Each method is a thin wrapper around a
/// channel invocation and therefore returns a [Future] that completes when the
/// native side acknowledges the request.
class PickerMapNativeController {
  MethodChannel? _channel;

  void _attach(MethodChannel channel) {
    _channel = channel;
  }

  void _detach() {
    _channel = null;
  }

  Future<void> setMarkers(List<Map<String, dynamic>> markers) async {
    await _channel?.invokeMethod('setMarkers', markers);
  }

  Future<void> setPolylines(List<Map<String, dynamic>> lines) async {
    await _channel?.invokeMethod('setPolylines', lines);
  }

  Future<void> setPolygons(List<Map<String, dynamic>> polys) async {
    await _channel?.invokeMethod('setPolygons', polys);
  }

  Future<void> cameraTo(double lat, double lng,
      {double? zoom, double? bearing, double? tilt}) async {
    final args = <String, dynamic>{
      'latitude': lat,
      'longitude': lng,
    };
    if (zoom != null) args['zoom'] = zoom;
    if (bearing != null) args['bearing'] = bearing;
    if (tilt != null) args['tilt'] = tilt;
    await _channel?.invokeMethod('cameraTo', args);
  }

  Future<void> fitBounds(List<LatLng> points, {double padding = 0}) async {
    final args = {
      'points': points
          .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
          .toList(),
      'padding': padding,
    };
    await _channel?.invokeMethod('fitBounds', args);
  }

  Future<void> updateCarPosition(String id, LatLng pos,
      {double? rotation, int? durationMs}) async {
    final args = <String, dynamic>{
      'id': id,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
    };
    if (rotation != null) args['rotation'] = rotation;
    if (durationMs != null) args['durationMs'] = durationMs;
    await _channel?.invokeMethod('updateCarPosition', args);
  }
}

/// Native implementation of [PickerMap] using platform views.
class PickerMapNative extends StatefulWidget {
  const PickerMapNative({
    super.key,
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
    this.destinationMarkerPngUrl = '',
    this.borderRadius = 16,
    this.enableRouteSnake = true,
    this.brandSafePaddingBottom = 60,
    this.ultraLowSpecMode = false,
    this.liteModeOnAndroid = false,
    this.onTap,
    this.onLongPress,
    this.controller,
  });

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

  final void Function(LatLng)? onTap;
  final void Function(LatLng)? onLongPress;

  /// Optional controller that receives a reference to the underlying native
  /// view. When supplied, imperative commands like [cameraTo] can be issued
  /// from the outside.
  final PickerMapNativeController? controller;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  MethodChannel? _channel;
  int? _viewId;

  // drivers
  final Map<String, StreamSubscription<DocumentSnapshot>> _subs = {};
  final Map<String, LatLng> _driverPos = {};
  final Map<String, double> _driverRot = {};
  final Map<String, String> _driverType = {};

  // route
  List<LatLng> _route = [];

  @override
  void didUpdateWidget(covariant PickerMapNative oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driversRefs != widget.driversRefs) {
      _subscribeDrivers();
    }
    if (oldWidget.destination != widget.destination ||
        oldWidget.userLocation != widget.userLocation ||
        oldWidget.googleApiKey != widget.googleApiKey) {
      _loadRoute();
    }
    _sendConfig();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    for (final s in _subs.values) {
      s.cancel();
    }
    widget.controller?._detach();
    super.dispose();
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _viewId = id;
    _channel = MethodChannel('picker_map_native_$id');
    _channel!.setMethodCallHandler(_handleCall);
    widget.controller?._attach(_channel!);
    _subscribeDrivers();
    await _loadRoute();
    await _sendConfig();
  }

  Future<void> _sendConfig() async {
    if (_channel == null) return;
    final cfg = <String, dynamic>{
      'userLocation': _latLngToMap(widget.userLocation),
      if (widget.destination != null)
        'destination': _latLngToMap(widget.destination!),
      'drivers': _driverPos.keys
          .map((id) => {
                'id': id,
                ..._latLngToMap(_driverPos[id]!),
                'rotation': _driverRot[id] ?? 0,
                'type': _driverType[id] ?? 'driver',
              })
          .toList(),
      'route': _route.map(_latLngToMap).toList(),
      'routeColor': widget.routeColor.value,
      'routeWidth': widget.routeWidth,
      'userMarkerSize': widget.userMarkerSize,
      'driverIconWidth': widget.driverIconWidth,
      'borderRadius': widget.borderRadius,
      'enableRouteSnake': widget.enableRouteSnake,
      'brandSafePaddingBottom': widget.brandSafePaddingBottom,
      'ultraLowSpecMode': widget.ultraLowSpecMode,
      'liteModeOnAndroid': widget.liteModeOnAndroid,
      'userName': widget.userName,
      'userPhotoUrl': widget.userPhotoUrl,
      'driverDriverIconUrl': widget.driverDriverIconUrl,
      'driverTaxiIconUrl': widget.driverTaxiIconUrl,
      'destinationMarkerPngUrl': widget.destinationMarkerPngUrl,
    };
    try {
      await _channel!.invokeMethod('updateConfig', cfg);
    } catch (_) {}
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    switch (call.method) {
      case 'onTap':
        final args = call.arguments as Map;
        widget.onTap?.call(LatLng(args['latitude'], args['longitude']));
        break;
      case 'onLongPress':
        final args = call.arguments as Map;
        widget.onLongPress?.call(LatLng(args['latitude'], args['longitude']));
        break;
    }
    return null;
  }

  Map<String, double> _latLngToMap(LatLng p) =>
      {'latitude': p.latitude, 'longitude': p.longitude};

  void _subscribeDrivers() {
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
    _driverPos.clear();
    _driverRot.clear();

    final refs = widget.driversRefs;
    if (refs == null) return;
    for (final ref in refs) {
      final id = ref.id;
      _subs[id] = ref.snapshots().listen((snap) {
        final data = snap.data() as Map<String, dynamic>?;
        LatLng? newPos;
        final loc = data?['location'];
        if (loc is LatLng) {
          newPos = loc;
        } else if (loc is GeoPoint) {
          newPos = LatLng(loc.latitude, loc.longitude);
        } else {
          final lat = (data?['lat'] as num?)?.toDouble();
          final lng = (data?['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) newPos = LatLng(lat, lng);
        }
        if (newPos == null) return;
        final last = _driverPos[id];
        if (last != null) {
          _driverRot[id] = _bearing(last, newPos);
        }
        _driverPos[id] = newPos;
        _driverType[id] = _driverTypeFromData(id, data);
        _sendConfig();
      });
    }
  }

  double _bearing(LatLng a, LatLng b) {
    final lat1 = a.latitude * math.pi / 180.0;
    final lat2 = b.latitude * math.pi / 180.0;
    final dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final brng = math.atan2(y, x) * 180.0 / math.pi;
    return (brng + 360.0) % 360.0;
  }

  Future<void> _loadRoute() async {
    _route = [];
    final dest = widget.destination;
    if (dest == null) {
      _sendConfig();
      return;
    }
    final pts = await _fetchDrivingRoute(widget.userLocation, dest);
    _route = pts;
    _sendConfig();
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
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
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  List<LatLng> _decimate(List<LatLng> pts,
      {double minStepMeters = 4.0, int maxPoints = 420}) {
    if (widget.ultraLowSpecMode) {
      minStepMeters = 6.0;
      maxPoints = 300;
    }
    if (pts.length <= 2) return pts;
    final out = <LatLng>[];
    LatLng? last;
    for (final p in pts) {
      if (last == null || _meters(last, p) >= minStepMeters) {
        out.add(p);
        last = p;
      }
    }
    if (out.length <= maxPoints) return out;
    final step = (out.length / maxPoints).ceil();
    final dec = <LatLng>[];
    for (int i = 0; i < out.length; i += step) dec.add(out[i]);
    if (dec.last != out.last) dec.add(out.last);
    return dec;
  }

  double _meters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final la1 = a.latitude * math.pi / 180.0;
    final la2 = b.latitude * math.pi / 180.0;
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * R * math.asin(math.min(1, math.sqrt(h)));
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
        : (hasDriver ? 'driver' : (_driverType[id] ?? 'driver'));
    return resolved;
  }

  Future<List<LatLng>> _fetchDrivingRoute(LatLng origin, LatLng dest) async {
    final key = (widget.googleApiKey ?? '').trim();
    if (key.isEmpty) {
      return [origin, dest];
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
        return [origin, dest];
      }
      final data = json.decode(resp.body) as Map<String, dynamic>;
      if ((data['status'] ?? '') != 'OK') {
        return [origin, dest];
      }
      final routes = (data['routes'] as List?) ?? const [];
      if (routes.isEmpty) {
        return [origin, dest];
      }
      final overview = routes.first['overview_polyline']?['points']?.toString();
      if (overview == null || overview.isEmpty) {
        return [origin, dest];
      }
      final pts = _decimate(_decodePolyline(overview));
      return pts;
    } catch (_) {
      return [origin, dest];
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewType = 'picker_map_native';
    final creationParams = <String, dynamic>{
      'initialUserLocation': _latLngToMap(widget.userLocation),
    };

    Widget platformView;
    if (defaultTargetPlatform == TargetPlatform.android) {
      platformView = PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: ui.TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
            ..create();
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: viewType,
        layoutDirection: ui.TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      );
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PickerMapNative');
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: platformView,
      ),
    );
  }
}
