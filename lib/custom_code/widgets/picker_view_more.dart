// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/flutter_flow/lat_lng.dart';

/// PickerViewMore agora delega para PickerMap para replicar exatamente a
/// experiência visual do mapa principal (marcadores circulares, ícones Ride
/// Driver/Taxi, rota animada e movimentos de câmera).
class PickerViewMore extends StatelessWidget {
  const PickerViewMore({
    super.key,
    this.width,
    this.height,
    required this.latlngOrigem,
    required this.latlngDestino,
    this.googleApiKey,
    this.fitPadding = 56,
    this.strokeWidth = 4,
    this.strokeColor = const Color(0xFFFBB125),
    this.interactive = false,
    this.borderRadius = 16,
    this.userName,
    this.userPhotoUrl,
    this.destinationMarkerPngUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png',
    this.userMarkerSize = 56,
    this.destMarkerWidth = 54,
    this.routeAnimationEnabled = true,
    this.routeAnimMinMs = 1600,
    this.routeAnimMaxMs = 18000,
    this.routeAnimMsPerKm = 1100,
    this.runnerDotRadiusMeters = 9.0,
    this.driverDriverIconUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/bgmclb0d2bsd/ChatGPT_Image_3_de_set._de_2025%2C_19_17_48.png',
    this.driverTaxiIconUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
  });

  final double? width;
  final double? height;

  final LatLng latlngOrigem;
  final LatLng latlngDestino;

  final String? googleApiKey;
  final double fitPadding;

  final double strokeWidth;
  final Color strokeColor;

  final double borderRadius;
  final bool interactive;

  final String? userName;
  final String? userPhotoUrl;
  final String destinationMarkerPngUrl;

  final int userMarkerSize;
  final int destMarkerWidth;

  final bool routeAnimationEnabled;
  final int routeAnimMinMs;
  final int routeAnimMaxMs;
  final int routeAnimMsPerKm;
  final double runnerDotRadiusMeters;

  final String? driverDriverIconUrl;
  final String? driverTaxiIconUrl;

  @override
  Widget build(BuildContext context) {
    final int normalizedRouteWidth =
        strokeWidth.round().clamp(1, 64).toInt();
    final int normalizedIconWidth =
        destMarkerWidth.clamp(32, 240);

    final double snakeSpeedFactor = (routeAnimMsPerKm / 1100.0)
        .clamp(0.25, 4.0);
    final int? snakeDurationOverride = routeAnimationEnabled
        ? routeAnimMaxMs.clamp(routeAnimMinMs, routeAnimMaxMs)
        : null;

    final widgetMap = PickerMap(
      width: width,
      height: height,
      userLocation: latlngOrigem,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      destination: latlngDestino,
      driversRefs: null,
      googleApiKey: googleApiKey,
      refreshMs: 8000,
      traceThrottleMs: 90,
      routeColor: strokeColor,
      routeWidth: normalizedRouteWidth,
      liveTraceColor: const Color(0xFF00E5FF),
      liveTraceWidth: 4,
      userMarkerSize: userMarkerSize,
      driverIconWidth: normalizedIconWidth,
      driverDriverIconUrl: driverDriverIconUrl,
      driverTaxiIconUrl: driverTaxiIconUrl,
      markerDestinationIconUrl: destinationMarkerPngUrl,
      borderRadius: borderRadius,
      brandSafePaddingBottom: fitPadding,
      fadeInMs: 420,
      enableRouteSnake: routeAnimationEnabled,
      snakeDurationMsOverride: snakeDurationOverride,
      snakeSpeedFactor: snakeSpeedFactor,
      driverTweenMs: 320,
      ultraLowSpecMode: false,
      traceMinStepMeters: runnerDotRadiusMeters,
    );

    return IgnorePointer(
      ignoring: !interactive,
      child: widgetMap,
    );
  }
}
