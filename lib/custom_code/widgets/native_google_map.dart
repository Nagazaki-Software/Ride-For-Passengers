
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import '/flutter_flow/lat_lng.dart';

typedef NativeMapCreatedCallback = void Function(NativeGoogleMapController controller);
typedef MapTapCallback = void Function(LatLng position);

class NativeGoogleMap extends StatefulWidget {
  const NativeGoogleMap({
    super.key,
    required this.initialPosition,
    this.zoom = 14,
    this.onMapCreated,
    this.onTap,
    this.onLongPress,
  });

  final LatLng initialPosition;
  final double zoom;
  final NativeMapCreatedCallback? onMapCreated;
  final MapTapCallback? onTap;
  final MapTapCallback? onLongPress;

  @override
  State<NativeGoogleMap> createState() => _NativeGoogleMapState();
}

class _NativeGoogleMapState extends State<NativeGoogleMap> {
  NativeGoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Center(child: Text('Native map unsupported on web'));
    }

    const viewType = 'native-google-map';
    final creationParams = <String, dynamic>{
      'lat': widget.initialPosition.latitude,
      'lng': widget.initialPosition.longitude,
      'zoom': widget.zoom,
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          final controller = PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          );
          controller.create();
          _controller = NativeGoogleMapController(params.id)
            ..onTap = widget.onTap
            ..onLongPress = widget.onLongPress
            ..onMapReady = () {
              widget.onMapCreated?.call(_controller!);
            };
          return controller;
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          _controller = NativeGoogleMapController(id)
            ..onTap = widget.onTap
            ..onLongPress = widget.onLongPress
            ..onMapReady = () {
              widget.onMapCreated?.call(_controller!);
            };
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class NativeGoogleMapController {
  NativeGoogleMapController(int id)
      : _channel = MethodChannel('native_google_map_' + id.toString()) {
    _channel.setMethodCallHandler(_handleCallbacks);
  }

  final MethodChannel _channel;

  MapTapCallback? onTap;
  MapTapCallback? onLongPress;
  VoidCallback? onMapReady;

  Future<void> _handleCallbacks(MethodCall call) async {
    switch (call.method) {
      case 'onTap':
        final args = call.arguments as Map;
        onTap?.call(LatLng(args['lat'] as double, args['lng'] as double));
        break;
      case 'onLongPress':
        final args = call.arguments as Map;
        onLongPress?.call(LatLng(args['lat'] as double, args['lng'] as double));
        break;
      case 'mapReady':
        onMapReady?.call();
        break;
    }
  }

  Future<void> moveCamera(LatLng target, double zoom) async {
    await _channel.invokeMethod('moveCamera', {
      'lat': target.latitude,
      'lng': target.longitude,
      'zoom': zoom,
    });
  }

  Future<void> setMarkers(List<Map<String, dynamic>> markers) async {
    await _channel.invokeMethod('setMarkers', {'markers': markers});
  }

  Future<void> setPolylines(List<List<double>> polyline,
      {int color = 0xff4285F4, double width = 5}) async {
    await _channel.invokeMethod('setPolylines', {
      'polyline': polyline,
      'color': color,
      'width': width,
    });
  }

  Future<void> setPolygons(List<List<List<double>>> polygons,
      {int strokeColor = 0xff4285F4,
      int fillColor = 0x554285F4,
      double strokeWidth = 1}) async {
    await _channel.invokeMethod('setPolygons', {
      'polygons': polygons,
      'strokeColor': strokeColor,
      'fillColor': fillColor,
      'strokeWidth': strokeWidth,
    });
  }

  Future<void> setMapStyle(String styleJson) async {
    await _channel.invokeMethod('setMapStyle', {'style': styleJson});
  }
}
