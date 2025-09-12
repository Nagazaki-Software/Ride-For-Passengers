// ignore_for_file: avoid_print
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

// Se estiver usando FlutterFlow, adapte imports de LatLng conforme seu projeto.
// Aqui uso uma struct simples:
class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}

class PickerMapNativeController {
  MethodChannel? _channel;
  void _attach(MethodChannel ch) => _channel = ch;
  void _detach() => _channel = null;

  Future<void> updateConfig(Map<String, dynamic> cfg) async =>
      _channel?.invokeMethod('updateConfig', cfg) ?? Future.value();
  Future<void> setMarkers(List<Map<String, dynamic>> m) async =>
      _channel?.invokeMethod('setMarkers', m) ?? Future.value();
  Future<void> setPolylines(List<Map<String, dynamic>> l) async =>
      _channel?.invokeMethod('setPolylines', l) ?? Future.value();
  Future<void> setPolygons(List<Map<String, dynamic>> p) async =>
      _channel?.invokeMethod('setPolygons', p) ?? Future.value();

  Future<void> cameraTo(double lat, double lng,
      {double? zoom, double? bearing, double? tilt}) async =>
      _channel?.invokeMethod('cameraTo', {
        'latitude': lat,
        'longitude': lng,
        if (zoom != null) 'zoom': zoom,
        if (bearing != null) 'bearing': bearing,
        if (tilt != null) 'tilt': tilt
      }) ?? Future.value();

  Future<void> fitBounds(List<LatLng> pts, {double padding = 0}) async =>
      _channel?.invokeMethod('fitBounds', {
        'points': pts.map((p) => {'latitude': p.latitude, 'longitude': p.longitude}).toList(),
        'padding': padding,
      }) ?? Future.value();

  Future<void> updateCarPosition(String id, LatLng pos, {double? rotation, int? durationMs}) async =>
      _channel?.invokeMethod('updateCarPosition', {
        'id': id,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        if (rotation != null) 'rotation': rotation,
        if (durationMs != null) 'durationMs': durationMs
      }) ?? Future.value();

  Future<dynamic> debugInfo() async =>
      _channel?.invokeMethod('debugInfo') ?? Future.value();
}

class PickerMapNative extends StatefulWidget {
  const PickerMapNative({
    super.key,
    required this.userLocation,
    this.destination,
    this.userName,
    this.userPhotoUrl,
    this.width,
    this.height = 320,
    this.borderRadius = 16,
    this.routeColor = const Color(0xFFFFC107),
    this.routeWidth = 4,
    this.showDebugPanel = true,
    this.controller,
  });

  final LatLng userLocation;
  final LatLng? destination;
  final String? userName;
  final String? userPhotoUrl;

  final double? width;
  final double height;
  final double borderRadius;
  final Color routeColor;
  final int routeWidth;
  final bool showDebugPanel;
  final PickerMapNativeController? controller;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  MethodChannel? _channel;
  int? _viewId;

  final _ktLogs = <String>[];
  bool _logsVisible = true;

  void _pushLog(String msg) {
    setState(() {
      final ts = DateTime.now().toIso8601String().substring(11, 19);
      _ktLogs.insert(0, '[$ts] $msg');
      if (_ktLogs.length > 200) _ktLogs.removeLast();
    });
    print(msg);
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    widget.controller?._detach();
    super.dispose();
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _viewId = id;
    _channel = MethodChannel('picker_map_native_$id');
    _channel!.setMethodCallHandler(_handleCall);
    widget.controller?._attach(_channel!);

    await _channel!.invokeMethod('updateConfig', {
      'userLocation': {
        'latitude': widget.userLocation.latitude,
        'longitude': widget.userLocation.longitude,
      },
      if (widget.destination != null)
        'destination': {
          'latitude': widget.destination!.latitude,
          'longitude': widget.destination!.longitude,
        },
      'route': const <Map<String, double>>[],
      'routeColor': widget.routeColor.value,
      'routeWidth': widget.routeWidth,
      'userName': widget.userName,
      'userPhotoUrl': widget.userPhotoUrl,
    });
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    if (call.method == 'platformReady') {
      _pushLog('KT → Dart: platformReady');
    } else if (call.method == 'debugLog') {
      final m = (call.arguments as Map?) ?? const {};
      final level = (m['level'] ?? 'D').toString();
      final msg = (m['msg'] ?? '').toString();
      _pushLog('[KT/$level] $msg');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const Center(child: Text('PickerMapNative: apenas Android'));
    }

    final controller = PlatformViewsService.initSurfaceAndroidView(
      id: 0,
      viewType: 'picker_map_native',
      layoutDirection: ui.TextDirection.ltr,
      creationParams: {
        'initialUserLocation': {
          'latitude': widget.userLocation.latitude,
          'longitude': widget.userLocation.longitude,
        },
      },
      creationParamsCodec: const StandardMessageCodec(),
    )
      ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
      ..create();

    final androidView = AndroidViewSurface(
      controller: controller as AndroidViewController,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      hitTestBehavior: PlatformViewHitTestBehavior.opaque,
    );

    final mapBox = SizedBox(
      width: widget.width,
      height: widget.height,
      child: androidView,
    );

    if (!widget.showDebugPanel) return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: mapBox,
    );

    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(widget.borderRadius), child: mapBox),
        Positioned(
          left: 8, top: 8,
          child: Material(
            color: Colors.black54, borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => setState(() => _logsVisible = !_logsVisible),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text('Ocultar logs', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ),
        ),
        if (_logsVisible)
          Positioned(
            left: 8, right: 8, bottom: 8,
            child: SizedBox(
              height: 160,
              child: Material(
                color: Colors.black54, borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _ktLogs.length,
                    itemBuilder: (_, i) => Text(
                      _ktLogs[i],
                      style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
