// ignore_for_file: avoid_print
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // PlatformViewHitTestBehavior
import 'package:flutter/services.dart';
import '/flutter_flow/lat_lng.dart' as ff; // LatLng do FlutterFlow

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
    int? durationMs,
  }) async =>
      _channel?.invokeMethod('cameraTo', {
        'latitude': lat,
        'longitude': lng,
        if (zoom != null) 'zoom': zoom,
        if (bearing != null) 'bearing': bearing,
        if (tilt != null) 'tilt': tilt,
        if (durationMs != null) 'durationMs': durationMs,
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
    this.showDebugPanel = false, // padrão: sem painéis
    this.controller,

    // ==== Parâmetros de compatibilidade (legados) ====
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
    // =================================================

    this.brandSafePaddingBottom,
    this.mapStyleJson,
    this.panelMaxLines = 120,
  });

  /// Localização do usuário (FF LatLng) — **obrigatório** e não nulo.
  final ff.LatLng userLocation;

  /// Destino (opcional)
  final ff.LatLng? destination;

  /// Dados opcionais
  final String? userName;
  final String? userPhotoUrl;

  /// Layout
  final double? width;
  final double height;
  final double borderRadius;

  /// Rota
  final Color routeColor;
  final int routeWidth;

  /// Painel de debug/logs
  final bool showDebugPanel;
  final int panelMaxLines;

  /// Controller
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

  /// Ajuste para não sobrepor a navbar/gestural bar
  final double? brandSafePaddingBottom;

  /// Estilo JSON do Google Maps (ex.: dark).
  final String? mapStyleJson;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  static int _nextViewId = 1;

  MethodChannel? _channel;
  late final int _viewId;

  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _viewId = _nextViewId++;
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    widget.controller?._detach();
    super.dispose();
  }

  Future<void> _applyInitialCamera() async {
    if (!_ready) return;
    final u = widget.userLocation;
    // Se tem destino, deixa o nativo ajustar via fitBounds; senão, 3D suave no user.
    if (widget.destination != null) {
      await _channel?.invokeMethod('fitBounds', {
        'points': [
          {'latitude': u.latitude, 'longitude': u.longitude},
          {
            'latitude': widget.destination!.latitude,
            'longitude': widget.destination!.longitude
          },
        ],
        'padding': 80.0,
      });
    } else {
      await _channel?.invokeMethod('cameraTo', {
        'latitude': u.latitude,
        'longitude': u.longitude,
        'zoom': 16.0,
        'bearing': 20.0,
        'tilt': 45.0,
        'durationMs': 500,
      });
    }
  }

  Future<void> _sendFullConfig() async {
    if (_channel == null) return;
    final cfg = <String, dynamic>{
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
      // ====== Compat (legado) — nativo pode ignorar ======
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
      // =====================================================
    };

    await _channel!.invokeMethod('updateConfig', cfg);
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _channel = MethodChannel('picker_map_native_$id');
    widget.controller?._attach(_channel!);

    _channel!.setMethodCallHandler((call) async {
      if (call.method == 'platformReady') {
        _ready = true;
        // manda config completa e posiciona câmera no primeiro “ready”
        await _sendFullConfig();
        await _applyInitialCamera();
      }
      // sem painel de debug/logs
      return null;
    });

    // Envia config inicial logo após criar (nativo pode aplicar parcialmente
    // antes do callback de ready; não faz mal)
    await _sendFullConfig();
  }

  @override
  void didUpdateWidget(covariant PickerMapNative oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se mudar userLocation/destination, reenvia config e ajusta câmera.
    if (oldWidget.userLocation.latitude != widget.userLocation.latitude ||
        oldWidget.userLocation.longitude != widget.userLocation.longitude ||
        (oldWidget.destination?.latitude != widget.destination?.latitude) ||
        (oldWidget.destination?.longitude != widget.destination?.longitude)) {
      _sendFullConfig();
      // pequena espera pra nativo processar as entidades antes da câmera
      Future.delayed(const Duration(milliseconds: 80), _applyInitialCamera);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.maybeOf(context)?.padding.bottom ?? 0;
    final brandBottom = widget.brandSafePaddingBottom ?? 16;
    final outerPadding = EdgeInsets.fromLTRB(0, 0, 0, bottomSafe + brandBottom);

    Widget platformView;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final controller = PlatformViewsService.initSurfaceAndroidView(
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

      platformView = AndroidViewSurface(
        controller: controller as AndroidViewController,
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

    // NÃO clipa PlatformView no Android (evita "véu cinza").
    final Widget baseBox = SizedBox(
      width: widget.width,
      height: widget.height,
      child: platformView,
    );

    final Widget mapBoxPadded = Padding(padding: outerPadding, child: baseBox);

    final Widget mapBox = (defaultTargetPlatform == TargetPlatform.android)
        ? mapBoxPadded // sem ClipRRect no Android
        : ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: mapBoxPadded,
          );

    return mapBox;
  }
}

/// Estilo DARK com acentos âmbar (amarelo), sem azul (opcional).
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
