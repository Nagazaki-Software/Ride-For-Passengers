// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '/flutter_flow/lat_lng.dart';

/// Native implementation of [PickerMap] using platform views.
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
    this.brandSafePaddingBottom = 0,
    this.ultraLowSpecMode = false,
    this.liteModeOnAndroid = false,
    this.onTap,
    this.onLongPress,
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

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  MethodChannel? _channel;
  int? _viewId;

  @override
  void didUpdateWidget(covariant PickerMapNative oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sendConfig();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _viewId = id;
    _channel = MethodChannel('picker_map_native_$id');
    _channel!.setMethodCallHandler(_handleCall);
    await _sendConfig();
  }

  Future<void> _sendConfig() async {
    if (_channel == null) return;
    final cfg = <String, dynamic>{
      'userLocation': _latLngToMap(widget.userLocation),
      if (widget.destination != null)
        'destination': _latLngToMap(widget.destination!),
      'routeColor': widget.routeColor.value,
      'routeWidth': widget.routeWidth,
      'userMarkerSize': widget.userMarkerSize,
      'driverIconWidth': widget.driverIconWidth,
      'borderRadius': widget.borderRadius,
      'enableRouteSnake': widget.enableRouteSnake,
      'brandSafePaddingBottom': widget.brandSafePaddingBottom,
      'ultraLowSpecMode': widget.ultraLowSpecMode,
      'liteModeOnAndroid': widget.liteModeOnAndroid,
    };
    try {
      await _channel!.invokeMethod('updateConfig', cfg);
    } catch (_) {}
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    switch (call.method) {
      case 'onTap':
        final args = call.arguments as Map;
        widget.onTap?.call(LatLng(args['latitude'], args['longitude']));
        break;
      case 'onLongPress':
        final args = call.arguments as Map;
        widget.onLongPress
            ?.call(LatLng(args['latitude'], args['longitude']));
        break;
    }
    return null;
  }

  Map<String, double> _latLngToMap(LatLng p) =>
      {'latitude': p.latitude, 'longitude': p.longitude};

  @override
  Widget build(BuildContext context) {
    final viewType = 'picker_map_native';
    final creationParams = <String, dynamic>{
      'initialUserLocation': _latLngToMap(widget.userLocation),
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
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
            ..create();
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      );
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PickerMapNative');
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

