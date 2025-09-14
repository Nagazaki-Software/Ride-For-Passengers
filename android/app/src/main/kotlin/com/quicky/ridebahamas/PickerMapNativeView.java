// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // PlatformViewHitTestBehavior
import 'package:flutter/services.dart';

import 'package:ride_bahamas/flutter_flow/lat_lng.dart' as ff; // FlutterFlow LatLng

// ============================================================================
// Controller
// ============================================================================
class PickerMapNativeController {
  MethodChannel? _channel;
  void _attach(MethodChannel ch) => _channel = ch;
  void _detach() => _channel = null;

  // --- Métodos diretos do nativo ---
  Future<void> updateConfig(Map<String, dynamic> cfg) async =>
      _channel?.invokeMethod('updateConfig', cfg) ?? Future.value();

  Future<void> setMarkers(List<Map<String, dynamic>> m) async =>
      _channel?.invokeMethod('setMarkers', m) ?? Future.value();

  Future<void> setPolylines(List<Map<String, dynamic>> l) async =>
      _channel?.invokeMethod('setPolylines', l) ?? Future.value();

  Future<void> setPolygons(List<Map<String, dynamic>> p) async =>
      _channel?.invokeMethod('setPolygons', p) ?? Future.value();

  Future<void> cameraTo(
    double lat,
    double lng, {
    double? zoom,
    double? bearing,
    double? tilt,
  }) async =>
      _channel?.invokeMethod('cameraTo', {
        'latitude': lat,
        'longitude': lng,
        if (zoom != null) 'zoom': zoom,
        if (bearing != null) 'bearing': bearing,
        if (tilt != null) 'tilt': tilt,
      }) ??
      Future.value();

  Future<void> fitBounds(List<ff.LatLng> pts, {double padding = 0}) async =>
      _channel?.invokeMethod('fitBounds', {
        'points': pts
            .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
            .toList(),
        'padding': padding,
      }) ??
      Future.value();

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
      }) ??
      Future.value();

  Future<dynamic> debugInfo() async =>
      _channel?.invokeMethod('debugInfo') ?? Future.value();

  // --- Extras de conforto (se o nativo não tiver, apenas ignorará) ---
  Future<void> setMapStyle(String json) async {
    try {
      await _channel?.invokeMethod('setMapStyle', {'json': json});
    } catch (_) {
      // se o método não existir no nativo, ignora
    }
  }

  /// Anima um polyline "crescendo" ponto a ponto (route snake).
  /// Se o nativo tiver animação própria, prefira lá; isso aqui é compat no Dart.
  Future<void> animatePolyline({
    required List<ff.LatLng> points,
    int steps = 24,
    int totalMs = 900,
    int color = 0xFFFFC107,
    double width = 4.0,
  }) async {
    if (points.length < 2) return;
    final stepMs = (totalMs / steps).round();
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final idx = (t * (points.length - 1)).clamp(1.0, (points.length - 1).toDouble());
      final hi = idx.floor();
      final lo = hi - 1;
      final frac = idx - hi;

      final out = <Map<String, dynamic>>[];
      for (var k = 0; k <= hi; k++) {
        out.add({
          'latitude': points[k].latitude,
          'longitude': points[k].longitude,
        });
      }
      if (frac > 0 && hi + 1 < points.length) {
        final a = points[hi];
        final b = points[hi + 1];
        final lat = a.latitude + (b.latitude - a.latitude) * frac;
        final lng = a.longitude + (b.longitude - a.longitude) * frac;
        out.add({'latitude': lat, 'longitude': lng});
      }

      await setPolylines([
        {
          'points': out,
          'color': color,
          'width': width,
        }
      ]);

      await Future.delayed(Duration(milliseconds: stepMs));
    }
  }

  /// Desenha um polígono simples (borda + preenchimento).
  Future<void> drawPolygon({
    required List<ff.LatLng> points,
    int strokeColor = 0xFF000000,
    double strokeWidth = 2.0,
    int fillColor = 0x220000FF,
  }) async {
    if (points.length < 3) return;
    await setPolygons([
      {
        'points': points
            .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
            .toList(),
        'strokeColor': strokeColor,
        'width': strokeWidth,
        'fillColor': fillColor,
      }
    ]);
  }
}

// ============================================================================
// Widget
// ============================================================================
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
    @Deprecated('Compat apenas. Não é usado pelo native.')
    this.driversRefs = const [], // <- mantém compat com seu call site
    this.brandSafePaddingBottom,
    this.mapStyleJson,
  });

  // Requeridos / principais
  final ff.LatLng userLocation;
  final ff.LatLng? destination;

  // Info do usuário (opcional)
  final String? userName;
  final String? userPhotoUrl;

  // Layout / estilo
  final double? width;
  final double height;
  final double borderRadius;

  // Rota
  final Color routeColor;
  final int routeWidth;

  // Painel de debug
  final bool showDebugPanel;

  // Controller
  final PickerMapNativeController? controller;

  // Compat
  @Deprecated('Compat apenas. Não é usado pelo native.')
  final List<dynamic> driversRefs;

  // UI
  final double? brandSafePaddingBottom;

  // Estilo do mapa (passe o JSON do Styled Maps aqui para dark mode)
  final String? mapStyleJson;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  MethodChannel? _channel;
  int? _viewId;

  static int _nextViewId = 1; // multi-instância sem conflito

  final _ktLogs = <String>[];
  bool _logsVisible = true;

  String? _pendingMapStyleJson; // aplica assim que platformReady chegar

  void _pushLog(String msg) {
    setState(() {
      final ts = DateTime.now().toIso8601String().substring(11, 19);
      _ktLogs.insert(0, '[$ts] $msg');
      if (_ktLogs.length > 300) _ktLogs.removeLast();
    });
    // Só para ver no logcat também
    // ignore: avoid_print
    print(msg);
  }

  @override
  void initState() {
    super.initState();
    _pendingMapStyleJson = widget.mapStyleJson;
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

    // Config inicial
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
      // aplica estilo do mapa assim que o nativo estiver pronto
      if (_pendingMapStyleJson != null && _pendingMapStyleJson!.trim().isNotEmpty) {
        try {
          await _channel?.invokeMethod('setMapStyle', {'json': _pendingMapStyleJson});
          _pushLog('[Dart] mapStyle aplicado');
        } catch (_) {
          _pushLog('[Dart] setMapStyle não suportado no nativo (ignorado)');
        }
      }
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

    // ID único para este PlatformView
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

    // Evitar sobrepor status/nav bar: usa SafeArea e paddings
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    final topInset = mq.padding.top;
    final brandPad = widget.brandSafePaddingBottom ?? 0;
    final logsHeight = math.min<double>(180, widget.height * 0.3);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        children: [
          mapBox,
          // Botão de toggle dos logs no topo, respeitando status bar
          Positioned(
            left: 8,
            right: 8,
            top: 8 + topInset,
            child: Row(
              children: [
                Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => setState(() => _logsVisible = !_logsVisible),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text(
                        'Logs',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // slot pra mais ações se quiser
              ],
            ),
          ),
          if (_logsVisible)
            Positioned(
              left: 8,
              right: 8,
              // respeita nav bar / bottom inset e ainda um brandPad opcional
              bottom: 8 + bottomInset + brandPad,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // evita cortar quando o container é baixo
                  maxHeight: logsHeight,
                ),
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ScrollConfiguration(
                      behavior: const _NoGlowBehavior(),
                      child: ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: _ktLogs.length,
                        itemBuilder: (_, i) => Text(
                          _ktLogs[i],
                          softWrap: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Remove overscroll glow do painel de logs (puramente estético)
class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
