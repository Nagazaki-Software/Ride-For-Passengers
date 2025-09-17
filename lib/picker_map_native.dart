// Wrapper adapter for the native PickerMap to match Home5 usage.
// Bridges Home5 props to lib/custom_code/widgets/picker_map_native.dart

import 'package:flutter/material.dart';
import '/flutter_flow/lat_lng.dart';

import 'custom_code/widgets/picker_map_native.dart'
    as base; // real implementation

class PickerMapNative extends StatefulWidget {
  const PickerMapNative({
    super.key,
    required this.userLocation,
    this.destination,
    this.googleApiKey, // not required by native map; kept for API compatibility
    this.userPhotoUrl,
    this.userName,
    this.userMarkerSize = 25,
    this.drivers = const [],
    this.encodedPolyline,
    this.enableRouteSnake = true,
    this.brandSafePaddingBottom = 60.0,
    this.darkStyle = true,
    this.driverTaxiIconUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
    this.driverDriverIconUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/bgmclb0d2bsd/ChatGPT_Image_3_de_set._de_2025%2C_19_17_48.png',
  });

  final LatLng userLocation;
  final LatLng? destination;
  final String? googleApiKey;
  final String? userPhotoUrl;
  final String? userName;
  final double userMarkerSize;
  final List<Map<String, dynamic>> drivers;
  final String? encodedPolyline;
  final bool enableRouteSnake;
  final double brandSafePaddingBottom;
  final bool darkStyle;
  final String? driverTaxiIconUrl;
  final String? driverDriverIconUrl;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  final base.PickerMapNativeController _controller =
      base.PickerMapNativeController();

  @override
  void initState() {
    super.initState();
    // After first frame, push driver markers.
    WidgetsBinding.instance.addPostFrameCallback((_) => _pushDrivers());
  }

  @override
  void didUpdateWidget(covariant PickerMapNative oldWidget) {
    super.didUpdateWidget(oldWidget);
<<<<<<< HEAD
=======
    // Push driver positions whenever the list changes.
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
    if (!identical(oldWidget.drivers, widget.drivers)) {
      _pushDrivers();
    }
  }

<<<<<<< HEAD
=======
  @override
  void dispose() {
    super.dispose();
  }

>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
  Future<void> _pushDrivers() async {
    for (final d in widget.drivers) {
      try {
        final id = d['id']?.toString();
        final lat = (d['lat'] as num?)?.toDouble();
        final lng = (d['lng'] as num?)?.toDouble();
        final bearing = (d['bearing'] as num?)?.toDouble() ?? 0.0;
        if (id != null && lat != null && lng != null) {
          await _controller.updateCarPosition(
            id,
            LatLng(lat, lng),
            rotation: bearing,
            durationMs: 1400,
          );
        }
      } catch (_) {
        // ignore a bad driver entry
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Choose style based on darkStyle flag
    final styleJson = widget.darkStyle ? base.kGoogleMapsMonoBlackStyle : '';
    final brandPad = widget.brandSafePaddingBottom.isFinite
        ? widget.brandSafePaddingBottom.round()
        : 60;

    return LayoutBuilder(builder: (context, constraints) {
      return base.PickerMapNative(
        width: constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : double.infinity,
        height: constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : double.infinity,
        controller: _controller,
        userLocation: widget.userLocation,
        destination: widget.destination,
        mapStyleJson: styleJson,
        // Requested polyline color #fbb125
        routeColor: 0xFFFBB125,
        routeWidth: 6,
        enableRouteSnake: widget.enableRouteSnake,
        autoFitCamera: true,
        // Destination marker asset (ensure it exists in pubspec)
        destinationMarkerPngUrl:
            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png',
        userPhotoUrl: widget.userPhotoUrl,
        userMarkerSize: widget.userMarkerSize,
        userName: widget.userName,
        encodedPolyline: widget.encodedPolyline,
        driverIconWidth: 70,
        driverTaxiIconAsset: null,
        driverTaxiIconUrl: widget.driverTaxiIconUrl,
        driverDriverIconUrl: widget.driverDriverIconUrl,
        liteModeOnAndroid: false,
        ultraLowSpecMode: false,
        brandSafePaddingBottom: brandPad,
        showDebugPanel: false,
        borderRadius: 0,
      );
    });
  }
}
