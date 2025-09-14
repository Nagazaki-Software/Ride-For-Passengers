// ignore_for_file: avoid_print
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:ride_bahamas/flutter_flow/lat_lng.dart' as ff;

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

  Future<void> updateCarPosition(String id, ff.LatLng pos,
          {double? rotation, int? durationMs}) async =>
      _channel?.invokeMethod('updateCarPosition', {
        'id': id,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        if (rotation != null) 'rotation': rotation,
        if (durationMs != null) 'durationMs': durationMs
      }) ??
      Future.value();

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
    this.driversRefs = const [],
    this.refreshMs,
    this.destinationMarkerPngUrl,
    this.userMarkerSize,
    this.driverIconWidth,
    this.driverTaxiIconAsset,
    this.driverDriverIconUrl,
    this.driverTaxiIconUrl,
    this.enableRouteSnake = false,
    this.brandSafePaddingBottom,
    this.liteModeOnAndroid,
    this.ultraLowSpecMode,
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
  final List<dynamic> driversRefs;
  final int? refreshMs;
  final String? destinationMarkerPngUrl;
  final double? userMarkerSize;
  final double? driverIconWidth;
  final String? driverTaxiIconAsset;
  final String? driverDriverIconUrl;
  final String? driverTaxiIconUrl;
  final bool enableRouteSnake;
  final double? brandSafePaddingBottom;
  final bool? liteModeOnAndroid;
  final bool? ultraLowSpecMode;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative>
    with AutomaticKeepAliveClientMixin {
  MethodChannel? _channel;
  late final Widget _platformView; // criado 1x
  final _ktLogs = <String>[];
  bool _logsVisible = true;

  @override
  bool get wantKeepAlive => true;

  void _pushLog(String msg) {
    setState(() {
      final ts = DateTime.now().toIso8601String().substring(11, 19);
      _ktLogs.insert(0, '[$ts] $msg');
      if (_ktLogs.length > 120) _ktLogs.removeLast(); // cap mais baixo
    });
    // ignore: avoid_print
    print(msg);
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    if (call.method == 'platformReady') {
      _pushLog('KT → Dart: platformReady');
      // Envia config inicial aqui (após o "platformReady" o nativo está 100%)
      await _channel?.invokeMethod('updateConfig', {
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
    } else if (call.method == 'debugLog') {
      final m = (call.arguments as Map?) ?? const {};
      final level = (m['level'] ?? 'D').toString();
      final msg = (m['msg'] ?? '').toString();
      // Evita flood: ignora logs de sizes repetidos
      if (msg.startsWith('sizes:')) return null;
      _pushLog('[KT/$level] $msg');
    }
    return null;
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _channel = MethodChannel('picker_map_native_$id');
    _channel!.setMethodCallHandler(_handleCall);
    widget.controller?._attach(_channel!);
  }

  @override
  void initState() {
    super.initState();
    // Cria o AndroidView uma única vez
    _platformView = AndroidView(
      viewType: 'picker_map_native',
      layoutDirection: TextDirection.ltr,
      creationParams: {
        'initialUserLocation': {
          'latitude': widget.userLocation.latitude,
          'longitude': widget.userLocation.longitude,
        },
      },
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }

  @override
  void didUpdateWidget(covariant PickerMapNative oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se localização/destino mudarem, reenvia config sem recriar a view
    if (_channel != null &&
        (oldWidget.userLocation.latitude != widget.userLocation.latitude ||
            oldWidget.userLocation.longitude !=
                widget.userLocation.longitude ||
            oldWidget.destination?.latitude != widget.destination?.latitude ||
            oldWidget.destination?.longitude !=
                widget.destination?.longitude)) {
      _channel!.invokeMethod('updateConfig', {
        'userLocation': {
          'latitude': widget.userLocation.latitude,
          'longitude': widget.userLocation.longitude,
        },
        if (widget.destination != null)
          'destination': {
            'latitude': widget.destination!.latitude,
            'longitude': widget.destination!.longitude,
          },
      });
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    widget.controller?._detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (defaultTargetPlatform != TargetPlatform.android) {
      return const Center(child: Text('PickerMapNative: apenas Android'));
    }

    final mapBox = SizedBox(
      width: widget.width,
      height: widget.height,
      child: _platformView,
    );

    if (!widget.showDebugPanel) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: mapBox,
      );
    }

    // Ajustes de overlay/log: respeita SafeArea e altura adaptativa
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final safePad =
        (widget.brandSafePaddingBottom ?? 0) + (bottomInset > 0 ? bottomInset : 8);
    final logsMaxH = math.min(180.0, math.max(120.0, widget.height * 0.35));

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        children: [
          mapBox,
          // Botão compacto
          Positioned(
            left: 8,
            top: 8,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => setState(() => _logsVisible = !_logsVisible),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    _logsVisible ? 'Ocultar logs' : 'Mostrar logs',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
          // Painel de logs no rodapé, com SafeArea
          if (_logsVisible)
            Positioned(
              left: 8,
              right: 8,
              bottom: 8 + safePad,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: logsMaxH,
                  minHeight: math.min(120.0, logsMaxH),
                ),
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.zero,
                      itemCount: _ktLogs.length,
                      itemBuilder: (_, i) => Text(
                        _ktLogs[i],
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}
