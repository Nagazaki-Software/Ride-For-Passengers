// lib/custom_code/widgets/picker_map_native.dart
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // PlatformViewHitTestBehavior
import 'package:flutter/services.dart';
import 'package:ride_bahamas/flutter_flow/lat_lng.dart' as ff;

/// ------------------------ CONTROLLER ------------------------

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
        if (tilt != null) 'tilt': tilt,
      }) ?? Future.value();

  Future<void> fitBounds(List<ff.LatLng> pts, {double padding = 0}) async =>
      _channel?.invokeMethod('fitBounds', {
        'points': pts
            .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
            .toList(),
        'padding': padding,
      }) ?? Future.value();

  Future<void> updateCarPosition(
    String id,
    ff.LatLng pos, {
    double? rotation,
    int? durationMs,
  }) async =>
      _channel?.invokeMethod('updateCarPosition', {
        'id': id,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        if (rotation != null) 'rotation': rotation,
        if (durationMs != null) 'durationMs': durationMs,
      }) ?? Future.value();

  Future<dynamic> debugInfo() async =>
      _channel?.invokeMethod('debugInfo') ?? Future.value();

  /// --------- Helpers “conveniência” (opcional usar) ---------

  /// Define UMA polyline como rota.
  Future<void> setRoute(List<ff.LatLng> pts,
          {Color? color, double? width}) async =>
      setPolylines([
        {
          'points':
              pts.map((e) => {'latitude': e.latitude, 'longitude': e.longitude}).toList(),
          if (color != null) 'color': color.value,
          if (width != null) 'width': width,
        }
      ]);

  /// “Snake” (desenha a rota aos poucos). Simples e eficiente.
  Future<void> animateRouteSnake(
    List<ff.LatLng> pts, {
    Duration total = const Duration(seconds: 2),
    Color? color,
    double width = 5,
  }) async {
    if (pts.length < 2) return;
    final steps = pts.length;
    final perStep = total ~/ steps;
    for (var i = 2; i <= steps; i++) {
      await setRoute(pts.take(i).toList(), color: color, width: width);
      await Future.delayed(perStep);
    }
  }

  /// Move um carro passando por uma sequência de pontos.
  Future<void> moveCarSmooth(
    String id,
    List<ff.LatLng> path, {
    int durationMsPerLeg = 800,
    double? fixedRotation,
  }) async {
    if (path.length < 2) return;
    for (var i = 1; i < path.length; i++) {
      await updateCarPosition(
        id,
        path[i],
        rotation: fixedRotation,
        durationMs: durationMsPerLeg,
      );
      await Future.delayed(Duration(milliseconds: durationMsPerLeg));
    }
  }
}

/// ------------------------ WIDGET ------------------------

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
    @Deprecated('Compatibilidade apenas. Não é usado pelo native.')
    this.driversRefs = const [],
    this.brandSafePaddingBottom,
    this.mapStyleJson,
  });

  final ff.LatLng userLocation;
  final ff.LatLng? destination;
  final String? userName;
  final String? userPhotoUrl;

  final double? width;
  final double height;
  final double borderRadius;
  final Color routeColor;
  final int routeWidth;
  final bool showDebugPanel;
  final PickerMapNativeController? controller;

  /// Mantido só para o seu call site não quebrar.
  @Deprecated('Compatibilidade apenas. Não é usado pelo native.')
  final List<dynamic> driversRefs;

  /// Caso sua bottom bar seja alta, ajuste aqui para os logs não sobreporem.
  final double? brandSafePaddingBottom;

  /// JSON de estilo do Google Maps (use p/ tema dark).
  /// Ex.: const kDarkMapStyle abaixo.
  final String? mapStyleJson;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  MethodChannel? _channel;
  int? _viewId;

  final _ktLogs = <String>[];
  bool _logsVisible = false;

  static int _nextViewId = 9000; // id único p/ múltiplas instâncias

  void _pushLog(String msg) {
    setState(() {
      final ts = DateTime.now().toIso8601String().substring(11, 19);
      _ktLogs.insert(0, '[$ts] $msg');
      if (_ktLogs.length > 200) _ktLogs.removeLast();
    });
    // também no console do Flutter
    // ignore: avoid_print
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

    // configuração inicial
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
      if (widget.mapStyleJson != null) 'mapStyleJson': widget.mapStyleJson,
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

    final viewId = _nextViewId++;
    final controller = PlatformViewsService.initSurfaceAndroidView(
      id: viewId,
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

    if (!widget.showDebugPanel) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: mapBox,
      );
    }

    // -------- LOG PANEL (reposicionado e menor) ----------
    final mq = MediaQuery.of(context);
    final safeBottom = mq.padding.bottom;
    final extraBottom = widget.brandSafePaddingBottom ?? 56; // altura típica de navbar
    final panelHeight = (mq.size.height * 0.22).clamp(120.0, 180.0);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: mapBox,
        ),
        // botão de toggle (canto superior)
        Positioned(
          left: 10,
          top: 10,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => setState(() => _logsVisible = !_logsVisible),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  _logsVisible ? 'Ocultar logs' : 'Mostrar logs',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
        if (_logsVisible)
          Positioned(
            left: 10,
            right: 10,
            bottom: 10 + safeBottom + extraBottom,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 110,
                maxHeight: panelHeight,
              ),
              child: Material(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Logs do mapa',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.zero,
                          itemCount: _ktLogs.length,
                          itemBuilder: (_, i) => Text(
                            _ktLogs[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// ------------------------ Exemplo de estilo DARK ------------------------
/// Jogue este const em algum arquivo seu (ou aqui mesmo) e passe
/// `mapStyleJson: kDarkMapStyle` no PickerMapNative.
const String kDarkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#1d1f25"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#e0e0e0"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#1d1f25"}]},
  {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color":"#3a3d44"}]},
  {"featureType": "poi", "elementType": "geometry", "stylers": [{"color":"#2a2d34"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color":"#27302b"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color":"#2b2f36"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color":"#1f2228"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color":"#383c45"}]},
  {"featureType": "transit", "elementType": "geometry", "stylers": [{"color":"#2b2f36"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color":"#0f141a"}]}
]
''';
