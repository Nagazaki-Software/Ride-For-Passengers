// ignore_for_file: avoid_print
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // PlatformViewHitTestBehavior
import 'package:flutter/services.dart';
import 'package:ride_bahamas/flutter_flow/lat_lng.dart' as ff; // LatLng do FlutterFlow

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
    this.controller,

    // Compat (legado) — o nativo pode ignorar
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

    // Estilo
    this.mapStyleJson,

    // 3D / câmera inicial
    this.initialZoom = 16.5,
    this.initialBearing = 24.0,
    this.initialTilt = 45.0,
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

  final PickerMapNativeController? controller;

  // ===== compat (legado) =====
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
  // ===========================

  final String? mapStyleJson;

  // 3D
  final double initialZoom;
  final double initialBearing;
  final double initialTilt;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative>
    with AutomaticKeepAliveClientMixin {
  static int _nextViewId = 1;

  MethodChannel? _channel;
  late final int _viewId;

  // Mantém o AndroidView vivo entre rebuilds.
  AndroidViewController? _androidController;

  bool _platformReady = false;
  bool _movedInitialCamera = false;

  bool _isZero(ff.LatLng? p) =>
      p == null || (p.latitude == 0.0 && p.longitude == 0.0);

  Map<String, dynamic> _buildCfg() => {
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
        // compat — o nativo pode ignorar
        if (widget.refreshMs != null) 'refreshMs': widget.refreshMs,
        if (widget.destinationMarkerPngUrl != null)
          'destinationMarkerPngUrl': widget.destinationMarkerPngUrl,
        if (widget.userMarkerSize != null) 'userMarkerSize': widget.userMarkerSize,
        if (widget.driverIconWidth != null) 'driverIconWidth': widget.driverIconWidth,
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

  Future<void> _moveInitialCameraIfNeeded() async {
    if (!_platformReady || _movedInitialCamera) return;
    if (_isZero(widget.userLocation)) return;
    try {
      await _channel?.invokeMethod('cameraTo', {
        'latitude': widget.userLocation.latitude,
        'longitude': widget.userLocation.longitude,
        'zoom': widget.initialZoom,
        'bearing': widget.initialBearing,
        'tilt': widget.initialTilt,
      });
      _movedInitialCamera = true;
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _viewId = _nextViewId++;

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Cria o controller UMA vez
      final ctrl = PlatformViewsService.initSurfaceAndroidView(
        id: _viewId,
        viewType: 'picker_map_native',
        layoutDirection: ui.TextDirection.ltr,
        creationParams: {
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
        },
        creationParamsCodec: const StandardMessageCodec(),
      )
        ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
        ..create();

      _androidController = ctrl as AndroidViewController;
    }
  }

  @override
  void didUpdateWidget(covariant PickerMapNative oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sempre que props mudarem, reenvia configuração
    if (_channel != null) {
      _channel!.invokeMethod('updateConfig', _buildCfg());
    }

    // Se antes era 0,0 e agora temos posição, move a câmera 3D
    if (_isZero(oldWidget.userLocation) && !_isZero(widget.userLocation)) {
      _movedInitialCamera = false; // garante movimento agora
      _moveInitialCameraIfNeeded();
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    widget.controller?._detach();
    _androidController?.dispose();
    super.dispose();
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _channel = MethodChannel('picker_map_native_$id');
    _channel!.setMethodCallHandler(_handleCall);
    widget.controller?._attach(_channel!);

    // Config inicial
    await _channel!.invokeMethod('updateConfig', _buildCfg());
    // Se já temos user válido, tenta mover 3D
    await _moveInitialCameraIfNeeded();
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    if (call.method == 'platformReady') {
      _platformReady = true;
      // Reaplica config e Move 3D
      if (_channel != null) {
        await _channel!.invokeMethod('updateConfig', _buildCfg());
      }
      await _moveInitialCameraIfNeeded();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // keep-alive

    Widget platformView;
    if (defaultTargetPlatform == TargetPlatform.android) {
      platformView = AndroidViewSurface(
        controller: _androidController!,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: 'picker_map_native',
        creationParams: {
          'initialUserLocation': {
            'latitude': widget.userLocation.latitude,
            'longitude': widget.userLocation.longitude,
          },
          if (widget.mapStyleJson != null) 'mapStyleJson': widget.mapStyleJson,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return const Center(child: Text('PickerMapNative: plataforma não suportada'));
    }

    final box = SizedBox(width: widget.width, height: widget.height, child: platformView);

    // Android não clipa (evita véu cinza)
    if (defaultTargetPlatform == TargetPlatform.android) return box;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: box,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Tema DARK com acentos ÂMBAR (amarelo), sem azul.
const String kGoogleMapsDarkAmberStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1a1a1a"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1a1a1a"}]},

  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#5f5f5f"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#252525"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1f1f1f"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#232323"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0d0d0d"}]},

  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a2a2a"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#3a3a3a"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#444444"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#e6c200"}]},
  {"featureType":"road","elementType":"labels.text.stroke","stylers":[{"color":"#151515"}]},

  {"featureType":"poi.business","elementType":"labels.text.fill","stylers":[{"color":"#ffc107"}]},
  {"featureType":"poi.attraction","elementType":"labels.text.fill","stylers":[{"color":"#ffc107"}]}
]
''';

// (Opcional) dark básico
const String kGoogleMapsDarkStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#212121"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#303030"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263238"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
  {"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}
]
''';
