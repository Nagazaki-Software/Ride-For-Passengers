// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import '/flutter_flow/lat_lng.dart';

class PickerMapNativeController {
  MethodChannel? _channel;
  void _attach(MethodChannel channel) { _channel = channel; }
  void _detach() { _channel = null; }
  Future<void> setMarkers(List<Map<String, dynamic>> m)
    => _channel?.invokeMethod('setMarkers', m) ?? Future.value();
  Future<void> setPolylines(List<Map<String, dynamic>> l)
    => _channel?.invokeMethod('setPolylines', l) ?? Future.value();
  Future<void> setPolygons(List<Map<String, dynamic>> p)
    => _channel?.invokeMethod('setPolygons', p) ?? Future.value();
  Future<void> cameraTo(double lat, double lng, {double? zoom, double? bearing, double? tilt})
    => _channel?.invokeMethod('cameraTo', {
      'latitude':lat,'longitude':lng, if(zoom!=null) 'zoom':zoom,
      if(bearing!=null) 'bearing':bearing, if(tilt!=null) 'tilt':tilt
    }) ?? Future.value();
  Future<void> fitBounds(List<LatLng> pts, {double padding = 0})
    => _channel?.invokeMethod('fitBounds', {
      'points': pts.map((p)=>{'latitude':p.latitude,'longitude':p.longitude}).toList(),
      'padding': padding,
    }) ?? Future.value();
  Future<void> updateCarPosition(String id, LatLng pos, {double? rotation, int? durationMs})
    => _channel?.invokeMethod('updateCarPosition', {
      'id':id,'latitude':pos.latitude,'longitude':pos.longitude,
      if(rotation!=null) 'rotation':rotation, if(durationMs!=null) 'durationMs':durationMs
    }) ?? Future.value();
}

class PickerMapNative extends StatefulWidget {
  const PickerMapNative({
    super.key,
    this.width,
    this.height,
    required this.userLocation,
    this.userName,
    this.userPhotoUrl,
    this.destination,
    this.driversRefs,
    this.googleApiKey,
    this.refreshMs = 8000,
    this.routeColor = const Color(0xFFFFC107),
    this.routeWidth = 4,
    this.userMarkerSize = 52,
    this.driverIconWidth = 72,
    this.driverDriverIconAsset,
    this.driverTaxiIconAsset,
    this.driverDriverIconUrl,
    this.driverTaxiIconUrl,
    this.destinationMarkerPngUrl = '',
    this.borderRadius = 16,
    this.enableRouteSnake = true,
    this.brandSafePaddingBottom = 60,
    this.ultraLowSpecMode = false,
    this.liteModeOnAndroid = false,
    this.onTap,
    this.onLongPress,
    this.controller,
  });

  final double? width;
  final double? height;
  final LatLng userLocation;
  final String? userName;
  final String? userPhotoUrl;
  final LatLng? destination;
  final List<DocumentReference>? driversRefs;
  final String? googleApiKey;
  final int refreshMs;
  final Color routeColor;
  final int routeWidth;
  final int userMarkerSize;
  final int driverIconWidth;
  final String? driverDriverIconAsset;
  final String? driverTaxiIconAsset;
  final String? driverDriverIconUrl;
  final String? driverTaxiIconUrl;
  final String destinationMarkerPngUrl;
  final double borderRadius;
  final bool enableRouteSnake;
  final double brandSafePaddingBottom;
  final bool ultraLowSpecMode;
  final bool liteModeOnAndroid;
  final void Function(LatLng)? onTap;
  final void Function(LatLng)? onLongPress;
  final PickerMapNativeController? controller;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  MethodChannel? _channel;
  int? _viewId;

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
    await _sendConfig();
  }

  Future<void> _sendConfig() async {
    if (_channel == null) return;
    final cfg = <String, dynamic>{
      'userLocation': {'latitude': widget.userLocation.latitude, 'longitude': widget.userLocation.longitude},
      if (widget.destination != null)
        'destination': {'latitude': widget.destination!.latitude, 'longitude': widget.destination!.longitude},
      'route': const <Map<String, double>>[], // rota é opcional; pode ser atualizada depois
      'routeColor': widget.routeColor.value,
      'routeWidth': widget.routeWidth,
      'userName': widget.userName,
      'userPhotoUrl': widget.userPhotoUrl,
    };
    try { await _channel!.invokeMethod('updateConfig', cfg); } catch (_) {}
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    if (call.method == 'platformReady') {
      await _sendConfig();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final viewType = 'picker_map_native';
    final creationParams = <String, dynamic>{
      'initialUserLocation': {
        'latitude': widget.userLocation.latitude,
        'longitude': widget.userLocation.longitude,
      },
    };

    Widget platformView;
    if (defaultTargetPlatform == TargetPlatform.android) {
      platformView = PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: ui.TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
            ..create();
        },
      );
    } else {
      return Text('$defaultTargetPlatform is not yet supported by PickerMapNative');
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: platformView,
      ),
    );
  }
}
