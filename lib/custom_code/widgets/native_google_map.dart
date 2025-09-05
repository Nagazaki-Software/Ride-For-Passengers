
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/lat_lng.dart';

typedef NativeMapCreatedCallback = void Function(NativeGoogleMapController controller);

class NativeGoogleMap extends StatefulWidget {
  const NativeGoogleMap({
    super.key,
    required this.initialPosition,
    this.zoom = 14,
    this.onMapCreated,
  });

  final LatLng initialPosition;
  final double zoom;
  final NativeMapCreatedCallback? onMapCreated;

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
          _controller = NativeGoogleMapController(params.id);
          widget.onMapCreated?.call(_controller!);
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
          _controller = NativeGoogleMapController(id);
          widget.onMapCreated?.call(_controller!);
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class NativeGoogleMapController {
  NativeGoogleMapController(int id)
      : _channel = MethodChannel('native_google_map_' + id.toString());

  final MethodChannel _channel;

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

  Future<void> setPolylines(List<List<double>> polyline) async {
    await _channel.invokeMethod('setPolylines', {'polyline': polyline});
  }
}
