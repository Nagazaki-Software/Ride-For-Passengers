// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
import '/flutter_flow/lat_lng.dart';
import 'package:provider/provider.dart';
// Notifications for steps are triggered inside PickingYou9 page.
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class PickingYouMap extends StatefulWidget {
  const PickingYouMap({
    super.key,
    this.width,
    this.height,
    required this.latlngOrigemPickingYou,
    required this.latlngDestinoPickingYou,
    required this.latlngOrigemProgress,
    required this.latlngDestinoProgress,
    required this.latlngOrigemFinish,
    required this.latlngDestinationFinish,
    this.googleApiKey,
  });

  final double? width;
  final double? height;
  final LatLng latlngOrigemPickingYou;
  final LatLng latlngDestinoPickingYou;
  final LatLng latlngOrigemProgress;
  final LatLng latlngDestinoProgress;
  final LatLng latlngOrigemFinish;
  final LatLng latlngDestinationFinish;
  final String? googleApiKey;

  @override
  State<PickingYouMap> createState() => _PickingYouMapState();
}

class _PickingYouMapState extends State<PickingYouMap>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Reage à troca de página (pickingyou/progress/finish)
    context.watch<FFAppState>();

    String mode = FFAppState().pickingPage;
    if (mode != 'pickingyou' && mode != 'progress' && mode != 'finish') {
      mode = 'pickingyou';
    }

    // Seleciona origem/destino conforme o modo
    LatLng origem;
    LatLng? destino;
    switch (mode) {
      case 'progress':
        origem = widget.latlngOrigemProgress;
        destino = widget.latlngDestinoProgress;
        break;
      case 'finish':
        origem = widget.latlngOrigemFinish;
        destino = widget.latlngDestinationFinish;
        break;
      case 'pickingyou':
      default:
        origem = widget.latlngOrigemPickingYou;
        destino = widget.latlngDestinoPickingYou;
        break;
    }

    // Usa a mesma chave do PickerMap da Home caso nenhuma seja passada
    final String apiKey =
        (widget.googleApiKey ?? 'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ').trim();

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 320.0,
      child: PickerMap(
        key: ValueKey(
          'pymode:$mode|o:${origem.latitude},${origem.longitude}|d:${destino?.latitude},${destino?.longitude}',
        ),
        width: widget.width ?? double.infinity,
        height: widget.height ?? 320.0,
        userLocation: origem,
        destination: destino,
        googleApiKey: apiKey,
        // Visual e animações alinhados ao PickerMap existente
        borderRadius: 0.0,
        routeColor: FlutterFlowTheme.of(context).secondaryBackground,
        routeWidth: 5,
        enableRouteSnake: true,
        brandSafePaddingBottom: 0.0,
        ultraLowSpecMode: false,
        userMarkerSize: 18,
        driverIconWidth: 25,
        liveTraceWidth: 4,
        liveTraceColor: FlutterFlowTheme.of(context).secondaryBackground,
        fadeInMs: 500,
        snakeDurationMsOverride: 600,
        snakeSpeedFactor: 2.0,
        driverTweenMs: 240,
        traceThrottleMs: 80,
        traceMinStepMeters: 1.5,
      ),
    );
  }
}
