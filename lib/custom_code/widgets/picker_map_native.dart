// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
import 'native_google_map.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/flutter_flow/lat_lng.dart';

class PickerMapNative extends StatefulWidget {
  const PickerMapNative({
    Key? key,
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
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

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
  final void Function(LatLng)? onTap;
  final void Function(LatLng)? onLongPress;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  NativeGoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: NativeGoogleMap(
          initialPosition: widget.userLocation,
          zoom: widget.destination == null ? 13.0 : 12.5,
          onMapCreated: (c) async {
            _controller = c;
            await _sync();
          },
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
        ),
      ),
    );
  }

  Future<void> _sync() async {
    if (_controller == null) return;
    final markers = <Map<String, dynamic>>[
      {
        'id': 'user',
        'lat': widget.userLocation.latitude,
        'lng': widget.userLocation.longitude,
      }
    ];
    if (widget.destination != null) {
      markers.add({
        'id': 'dest',
        'lat': widget.destination!.latitude,
        'lng': widget.destination!.longitude,
      });
    }
    await _controller!.setMarkers(markers);
  }
}
