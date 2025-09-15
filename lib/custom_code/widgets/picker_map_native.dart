// ignore_for_file: depend_on_referenced_packages
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/lat_lng.dart'; // LatLng do FlutterFlow

// =================== Estilo dark (preto/cinza) ===================
const String kGoogleMapsMonoBlackStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1d1f25"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a8c91"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1f25"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a2d34"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1a1c21"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8c91"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#111317"}]}
]
''';

// =================== Controller ===================
class PickerMapNativeController {
  MethodChannel? _channel;

  void _attach(int id) {
    _channel = MethodChannel('picker_map_native/$id');
  }

  Future<void> updateConfig(Map<String, dynamic> cfg) async {
    if (_channel == null) return;
    await _channel!.invokeMethod('updateConfig', cfg);
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
      'position': {'latitude': position.latitude, 'longitude': position.longitude},
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
    this.driversRefs, // ignorado aqui (usamos controller p/ posições)
    this.refreshMs = 2000,
    this.destinationMarkerPngUrl,
    this.userPhotoUrl,
    this.userMarkerSize = 40,
    this.userName,
    this.driverIconWidth = 70,
    this.driverTaxiIconAsset,
    this.driverTaxiIconUrl,
    this.driverDriverIconUrl,
    this.liteModeOnAndroid = false,
    this.ultraLowSpecMode = false,
    this.brandSafePaddingBottom = 60,
    this.showDebugPanel = false,
    this.borderRadius = 0,
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
  final bool ultraLowSpecMode;
  final int brandSafePaddingBottom;
  final bool showDebugPanel;
  final double borderRadius;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  int? _viewId;

  Map<String, dynamic> get _payload => {
        'mapStyleJson': widget.mapStyleJson,
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
    // sempre empurra config nova pro nativo
    _pushConfig();
  }

  Future<void> _pushConfig() async {
    if (_viewId == null) return;
    await widget.controller.updateConfig(_payload);
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return const Center(child: Text('PickerMapNative disponível só no Android.'));
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
          await _pushConfig();
          params.onPlatformViewCreated(id);
        });
        controller.create();
        return controller;
      },
    );

    final map = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(width: widget.width, height: widget.height, child: view),
    );

    return map;
  }
}
