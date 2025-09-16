// ignore_for_file: depend_on_referenced_packages
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import '/flutter_flow/lat_lng.dart'; // LatLng do FlutterFlow

// =================== Estilo dark (preto/cinza) ===================
const String kGoogleMapsMonoBlackStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#0e1116"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a8f98"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0e1116"}]},

  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1c222b"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#0b0f14"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9aa0a6"}]},
  {"featureType":"road.local","elementType":"geometry","stylers":[{"color":"#212733"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#232a36"}]},

  {"featureType":"landscape.man_made","elementType":"geometry.fill","stylers":[{"color":"#2a303a"}]},
  {"featureType":"landscape.man_made","elementType":"geometry.stroke","stylers":[{"color":"#3b424e"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#2a303a"}]},
  {"featureType":"poi","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#1a1f26"}]},

  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#0a0c10"}]}
]
''';

// =================== Controller ===================
class PickerMapNativeController {
  MethodChannel? _channel;
  Future<dynamic> Function(MethodCall call)? _handler;

  void _attach(int id) {
    _channel = MethodChannel('picker_map_native/$id');
    if (_handler != null) {
      _channel!.setMethodCallHandler(_handler);
    }
  }

  Future<void> updateConfig(Map<String, dynamic> cfg) async {
    if (_channel == null) return;
    await _channel!.invokeMethod('updateConfig', cfg);
  }

  void setMethodCallHandler(Future<dynamic> Function(MethodCall call) handler) {
    _handler = handler;
    if (_channel != null) {
      _channel!.setMethodCallHandler(handler);
    }
  }

  Future<void> updateCarPosition(
    String id,
    LatLng position, {
    double rotation = 0,
    int durationMs = 1600,
  }) async {
    if (_channel == null) return;
    await _channel!.invokeMethod('updateCarPosition', {
      'id': id,
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude
      },
      'rotation': rotation,
      'durationMs': durationMs,
    });
  }

  Future<void> cameraTo(LatLng pos, {double zoom = 15}) async {
    if (_channel == null) return;
    await _channel!.invokeMethod('cameraTo', {
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'zoom': zoom,
    });
  }

  Future<void> fitBounds(List<LatLng> points, {int padding = 100}) async {
    if (_channel == null) return;
    await _channel!.invokeMethod('fitBounds', {
      'points': points
          .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
          .toList(),
      'padding': padding,
    });
  }

  Future<void> onResume() async {
    if (_channel == null) return;
    await _channel!.invokeMethod('onResume');
  }

  Future<void> onPause() async {
    if (_channel == null) return;
    await _channel!.invokeMethod('onPause');
  }

  Future<void> onLowMemory() async {
    if (_channel == null) return;
    await _channel!.invokeMethod('onLowMemory');
  }
}

// =================== Widget (Platform View) ===================
class PickerMapNative extends StatefulWidget {
  const PickerMapNative({
    super.key,
    required this.width,
    required this.height,
    required this.controller,
    required this.userLocation,
    this.destination,
    this.mapStyleJson = kGoogleMapsMonoBlackStyle,
    this.routeColor = 0xFFBDBDBD,
    this.routeWidth = 5,
    this.enableRouteSnake = true,
    this.encodedPolyline,
    this.driversRefs, // ignorado aqui (usamos controller p/ posições)
    this.refreshMs = 2000,
    this.destinationMarkerPngUrl,
    this.userPhotoUrl,
    this.userMarkerSize = 16,
    this.userName,
    this.driverIconWidth = 70,
    this.driverTaxiIconAsset,
    this.driverTaxiIconUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/bgmclb0d2bsd/ChatGPT_Image_3_de_set._de_2025%2C_19_17_48.png',
    this.driverDriverIconUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
    this.liteModeOnAndroid = false,
    this.autoFitCamera = true,
    this.ultraLowSpecMode = false,
    this.brandSafePaddingBottom = 60,
    this.showDebugPanel = false,
    this.borderRadius = 0,
    this.deferCreateMs = 350,
  });

  final double width;
  final double height;
  final PickerMapNativeController controller;

  final LatLng userLocation;
  final LatLng? destination;

  final String mapStyleJson;
  final int routeColor;
  final int routeWidth;
  final bool enableRouteSnake;
  final String? encodedPolyline;

  final List<dynamic>? driversRefs; // mantido p/ API compatível
  final int refreshMs;

  final String? destinationMarkerPngUrl;
  final String? userPhotoUrl;
  final double userMarkerSize;
  final String? userName;
  final int driverIconWidth;
  final String? driverTaxiIconAsset;
  final String? driverTaxiIconUrl;
  final String? driverDriverIconUrl;

  final bool liteModeOnAndroid;
  final bool autoFitCamera;
  final bool ultraLowSpecMode;
  final int brandSafePaddingBottom;
  final bool showDebugPanel;
  final double borderRadius;
  final int deferCreateMs;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative>
    with WidgetsBindingObserver {
  int? _viewId;
  bool _ready = false;
  bool _moving = false;
  String? _lastPayloadCache;
  bool _createdPlatformView = false;

  Map<String, dynamic> get _payload => {
        'mapStyleJson': widget.mapStyleJson,
        'useNativeStyle': true,
        'userLocation': {
          'latitude': widget.userLocation.latitude,
          'longitude': widget.userLocation.longitude,
        },
        'destination': (widget.destination == null)
            ? null
            : {
                'latitude': widget.destination!.latitude,
                'longitude': widget.destination!.longitude,
              },
        'routeColor': widget.routeColor,
        'routeWidth': widget.routeWidth,
        'enableRouteSnake': widget.enableRouteSnake,
        'encodedPolyline': widget.encodedPolyline,
        'autoFitCamera': widget.autoFitCamera,
        'ultraLowSpecMode': widget.ultraLowSpecMode,
        'destinationMarkerPngUrl': widget.destinationMarkerPngUrl,
        'userPhotoUrl': widget.userPhotoUrl,
        'userMarkerSize': widget.userMarkerSize,
        'userName': widget.userName,
        'driverIconWidth': widget.driverIconWidth,
        'driverTaxiIconAsset': widget.driverTaxiIconAsset,
        'driverTaxiIconUrl': widget.driverTaxiIconUrl,
        'driverDriverIconUrl': widget.driverDriverIconUrl,
        'brandSafePaddingBottom': widget.brandSafePaddingBottom,
      };

  @override
  void didUpdateWidget(covariant PickerMapNative oldWidget) {
    super.didUpdateWidget(oldWidget);
    // só envia se mudou (cache controla)
    _pushConfig();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Forward lifecycle to native MapView to avoid black/blank map on resume.
    if (_viewId == null) return;
    switch (state) {
      case AppLifecycleState.resumed:
        widget.controller.onResume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        widget.controller.onPause();
        break;
      case AppLifecycleState.detached:
        widget.controller.onLowMemory();
        break;
    }
  }

  Future<void> _pushConfig() async {
    if (_viewId == null) return;
    final payload = _payload;
    final key = payload.toString();
    if (key == _lastPayloadCache) return;
    _lastPayloadCache = key;
    await widget.controller.updateConfig(payload);
  }

  @override
  Widget build(BuildContext context) {
    // iOS branch: use UiKitView and same channel callbacks
    if (Platform.isIOS) {
      final iosView = UiKitView(
        viewType: 'picker_map_native',
        layoutDirection: TextDirection.ltr,
        creationParams: _payload,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) async {
          _viewId = id;
          widget.controller._attach(id);
          widget.controller.setMethodCallHandler((call) async {
            if (!mounted) return null;
            if (call.method == 'mapLoaded') {
              Future.delayed(const Duration(milliseconds: 220), () {
                if (mounted) setState(() => _ready = true);
              });
            } else if (call.method == 'cameraMoveStart') {
              setState(() => _moving = true);
            } else if (call.method == 'cameraIdle') {
              Future.delayed(const Duration(milliseconds: 120), () {
                if (mounted) setState(() => _moving = false);
              });
            }
            return null;
          });
          await _pushConfig();
          Future.delayed(const Duration(milliseconds: 700), () {
            if (mounted && !_ready) setState(() => _ready = true);
          });
        },
      );

      final map = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: SizedBox(width: widget.width, height: widget.height, child: iosView),
      );

      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: const Color(0xFF1D1F25),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _ready ? 1.0 : 0.0,
            child: map,
          ),
        ],
      );
    }
    if (!Platform.isAndroid) {
      return const Center(
          child: Text('PickerMapNative disponível só no Android.'));
    }

    if (Platform.isAndroid && !_createdPlatformView) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1217),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }

    final view = PlatformViewLink(
      viewType: 'picker_map_native',
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        final creationParams = _payload;
        final controller = PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: 'picker_map_native',
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {},
        );
        controller.addOnPlatformViewCreatedListener((id) async {
          _viewId = id;
          widget.controller._attach(id);
          // Listen for native 'mapLoaded' to hide placeholder precisely
          widget.controller.setMethodCallHandler((call) async {
            if (!mounted) return null;
            if (call.method == 'mapLoaded') {
              // pequeno atraso para garantir que os tiles já renderizaram o primeiro frame
              Future.delayed(const Duration(milliseconds: 220), () {
                if (mounted) setState(() => _ready = true);
              });
            } else if (call.method == 'cameraMoveStart') {
              setState(() {
                _moving = true;
              });
            } else if (call.method == 'cameraIdle') {
              setState(() {
                _moving = false;
              });
            }
            return null;
          });
          await _pushConfig();
          params.onPlatformViewCreated(id);
          // Fallback: ensure ready in case mapLoaded is delayed
          Future.delayed(const Duration(milliseconds: 700), () {
            if (mounted && !_ready) setState(() => _ready = true);
          });
          // Câmera controlada no nativo (3D tilt/bearing) ao mudar rota/destino
        });
        controller.create();
        return controller;
      },
    );

    final Widget mapViewBox = SizedBox(
      width: widget.width,
      height: widget.height,
      child: view,
    );
    final Widget placeholder = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1217),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
    );
    final Widget animatedMap = AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _ready ? 1.0 : 0.0,
      child: defaultTargetPlatform == TargetPlatform.android
          ? mapViewBox
          : ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: mapViewBox,
            ),
    );
    final Widget stack = SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          placeholder,
          animatedMap,
        ],
      ),
    );
    return defaultTargetPlatform == TargetPlatform.android
        ? stack
        : ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: stack,
          );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid) {
      Future.delayed(Duration(milliseconds: widget.deferCreateMs), () {
        if (mounted) setState(() => _createdPlatformView = true);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}


