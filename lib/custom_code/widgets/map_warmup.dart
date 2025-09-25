// Simple hidden map warmup to pre-initialize map engines and caches.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:google_maps_native_sdk/google_maps_native_sdk.dart' as nmap;

class MapWarmupOverlay extends StatefulWidget {
  const MapWarmupOverlay({Key? key, this.googleApiKey}) : super(key: key);
  final String? googleApiKey;

  @override
  State<MapWarmupOverlay> createState() => _MapWarmupOverlayState();
}

class _MapWarmupOverlayState extends State<MapWarmupOverlay> {
  bool _nativeReady = false;
  bool _flutterReady = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // Safety timeout to not keep warming forever.
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_done) setState(() => _done = true);
    });
  }

  void _maybeFinish() {
    if (_nativeReady && _flutterReady && !_done) {
      // Give a short grace period to let caches settle.
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _done = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();
    // Keep very small to reduce cost, but non-zero to initialize properly.
    return IgnorePointer(
      ignoring: true,
      child: Align(
        alignment: Alignment.bottomRight,
        child: SizedBox(
          width: kIsWeb ? 2 : 2,
          height: kIsWeb ? 2 : 2,
          child: Opacity(
            opacity: 0.0,
            child: Stack(
              children: [
                // Native SDK warmup (Android/iOS)
                nmap.GoogleMapView(
                  initialCameraPosition: const nmap.CameraPosition(
                    target: nmap.LatLng(0, 0),
                    zoom: 1,
                  ),
                  myLocationEnabled: false,
                  buildingsEnabled: false,
                  trafficEnabled: false,
                  padding: const nmap.MapPadding(),
                  onMapCreated: (c) async {
                    try {
                      await c.onMapLoaded;
                    } catch (_) {}
                    if (mounted) setState(() => _nativeReady = true);
                    _maybeFinish();
                  },
                ),
                // Flutter google_maps_flutter warmup
                gmf.GoogleMap(
                  initialCameraPosition: const gmf.CameraPosition(
                    target: gmf.LatLng(0, 0),
                    zoom: 1,
                  ),
                  myLocationEnabled: false,
                  buildingsEnabled: false,
                  trafficEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  onMapCreated: (controller) async {
                    if (mounted) setState(() => _flutterReady = true);
                    _maybeFinish();
                  },
                  gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

