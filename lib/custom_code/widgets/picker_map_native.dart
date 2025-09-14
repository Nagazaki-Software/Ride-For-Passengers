// ignore_for_file: avoid_print
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // PlatformViewHitTestBehavior
import 'package:flutter/services.dart';
import 'package:ride_bahamas/flutter_flow/lat_lng.dart' as ff;

/// Controller para chamar métodos nativos (Android/iOS).
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
    this.showDebugPanel = false,
    this.controller,

    // ==== Compat (legado) ====
    @Deprecated('Compat apenas. Não é usado pelo nativo.')
    this.driversRefs = const [],
    this.refreshMs,
    this.destinationMarkerPngUrl,
    this.userMarkerSize,
    this.driverIconWidth,
    this.driverTaxiIconAsset,
    this.driverDriverIconUrl,
    this.driverTaxiIconUrl,
    this.enableRouteSnake = false,
    this.liteModeOnAndroid,
    this.ultraLowSpecMode,
    // =========================

    this.brandSafePaddingBottom,
    this.mapStyleJson,
    this.panelMaxLines = 120,
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
  final int panelMaxLines;

  final PickerMapNativeController? controller;

  // ====== Compat (legado) ======
  @Deprecated('Compat apenas. Não é usado pelo nativo.')
  final List<dynamic> driversRefs;
  final int? refreshMs;

  final String? destinationMarkerPngUrl;
  final double? userMarkerSize;
  final double? driverIconWidth;
  final String? driverTaxiIconAsset;
  final String? driverDriverIconUrl;
  final String? driverTaxiIconUrl;
  final bool enableRouteSnake;
  final bool? liteModeOnAndroid;
  final bool? ultraLowSpecMode;
  // =============================

  final double? brandSafePaddingBottom;
  final String? mapStyleJson;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  static int _nextViewId = 1;

  MethodChannel? _channel;
  late final int _viewId;

  // Controller Android criado UMA vez e reutilizado.
  AndroidViewController? _androidController;

  final _ktLogs = <String>[];
  bool _logsVisible = false;

  bool _platformReady = false;
  bool _sentInitialCamera = false;

  void _pushLog(String msg) {
    if (!widget.showDebugPanel) return;
    setState(() {
      final ts = DateTime.now().toIso8601String().substring(11, 19);
      _ktLogs.insert(0, '[$ts] $msg');
      if (_ktLogs.length > widget.panelMaxLines) _ktLogs.removeLast();
    });
    // print(msg); // silenciado
  }

  @override
  void initState() {
    super.initState();
    _viewId = _nextViewId++;

    if (defaultTargetPlatform == TargetPlatform.android) {
      _androidController = PlatformViewsService.initSurfaceAndroidView(
        id: _viewId,
        viewType: 'picker_map_native',
        layoutDirection: ui.TextDirection.ltr,
        creationParams: _creationParams(),
        creationParamsCodec: const StandardMessageCodec(),
      )
        ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
        ..create();
    }
  }

  Map<String, dynamic> _creationParams() {
    return {
      'initialUserLocation': {
        'latitude': widget.userLocation.latitude,
        'longitude': widget.userLocation.longitude,
      },
      if (widget.mapStyleJson != null) 'mapStyleJson': widget.mapStyleJson,
      if (widget.refreshMs != null) 'refreshMs': widget.refreshMs,
      if (widget.liteModeOnAndroid != null)
        'liteModeOnAndroid': widget.liteModeOnAndroid,
      if (widget.ultraLowSpecMode != null)
        'ultraLowSpecMode': widget.ultraLowSpecMode,
    };
  }

  Future<void> _pushConfigToNative() async {
    if (_channel == null) return;
    final cfg = {
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

      // compat
      if (widget.refreshMs != null) 'refreshMs': widget.refreshMs,
      if (widget.destinationMarkerPngUrl != null)
        'destinationMarkerPngUrl': widget.destinationMarkerPngUrl,
      if (widget.userMarkerSize != null) 'userMarkerSize': widget.userMarkerSize,
      if (widget.driverIconWidth != null)
        'driverIconWidth': widget.driverIconWidth,
      if (widget.driverTaxiIconAsset != null)
        'driverTaxiIconAsset': widget.driverTaxiIconAsset,
      if (widget.driverDriverIconUrl != null)
        'driverDriverIconUrl': widget.driverDriverIconUrl,
      if (widget.driverTaxiIconUrl != null)
        'driverTaxiIconUrl': widget.driverTaxiIconUrl,
      'enableRouteSnake': widget.enableRouteSnake,
      if (widget.liteModeOnAndroid != null)
        'liteModeOnAndroid': widget.liteModeOnAndroid,
      if (widget.ultraLowSpecMode != null)
        'ultraLowSpecMode': widget.ultraLowSpecMode,
    };
    try {
      await _channel!.invokeMethod('updateConfig', cfg);
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant PickerMapNative oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sempre que props relevantes mudarem, envia pro nativo (sem recriar view).
    if (_platformReady) {
      _pushConfigToNative();

      // Move câmera pro new userLocation com um tilt/bearing charmoso.
      if (oldWidget.userLocation.latitude != widget.userLocation.latitude ||
          oldWidget.userLocation.longitude != widget.userLocation.longitude) {
        _safeCameraTo(widget.userLocation, zoom: 17, tilt: 50);
      }

      // Se destino mudou, o app costuma chamar fitBounds do lado do Dart (Home5),
      // então aqui não precisamos fazer nada — mas não faz mal recentrar:
      if (oldWidget.destination?.latitude != widget.destination?.latitude ||
          oldWidget.destination?.longitude != widget.destination?.longitude) {
        _safeCameraTo(widget.userLocation, zoom: 16, tilt: 50);
      }
    }
  }

  void _safeCameraTo(ff.LatLng p, {double? zoom, double? tilt}) {
    widget.controller?.cameraTo(
      p.latitude,
      p.longitude,
      zoom: zoom,
      tilt: tilt,
      bearing: 15,
    );
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    widget.controller?._detach();
    super.dispose();
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _channel = MethodChannel('picker_map_native_$id');
    _channel!.setMethodCallHandler(_handleCall);
    widget.controller?._attach(_channel!);

    await _pushConfigToNative();
    _platformReady = true;

    if (!_sentInitialCamera) {
      _sentInitialCamera = true;
      _safeCameraTo(widget.userLocation, zoom: 16.5, tilt: 50);
    }
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    if (call.method == 'platformReady') {
      _platformReady = true;
      _pushConfigToNative();
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
    final bottomSafe = MediaQuery.maybeOf(context)?.padding.bottom ?? 0;
    final brandBottom = widget.brandSafePaddingBottom ?? 16;
    final outerPadding = EdgeInsets.fromLTRB(0, 0, 0, bottomSafe + brandBottom);

    Widget platformView;

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Reutiliza o controller criado no initState
      platformView = AndroidViewSurface(
        controller: _androidController as AndroidViewController,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: 'picker_map_native',
        creationParams: _creationParams(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return const Center(child: Text('PickerMapNative: plataforma não suportada'));
    }

    // NÃO clipa no Android.
    final Widget baseBox = SizedBox(
      width: widget.width,
      height: widget.height,
      child: platformView,
    );

    final Widget mapBoxPadded = Padding(padding: outerPadding, child: baseBox);

    final Widget mapBox = (defaultTargetPlatform == TargetPlatform.android)
        ? mapBoxPadded
        : ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: mapBoxPadded,
          );

    if (!widget.showDebugPanel) return mapBox;

    final double topSafe = (MediaQuery.maybeOf(context)?.padding.top ?? 0) + 8;

    return Stack(
      children: [
        mapBox,
        Positioned(
          left: 8,
          top: topSafe,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => setState(() => _logsVisible = !_logsVisible),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text('LOGS', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ),
        ),
        if (_logsVisible)
          Positioned(
            left: 8,
            right: 8,
            bottom: 12 + brandBottom,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _ktLogs.length,
                    itemBuilder: (_, i) => Text(
                      _ktLogs[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
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
