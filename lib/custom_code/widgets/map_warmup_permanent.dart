import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_native_sdk/google_maps_native_sdk.dart' as nmap;
import 'icon_global_cache.dart';

/// Permanent hidden warmup for google_maps_native_sdk.
/// - Keeps a tiny native map alive for the whole app lifetime.
/// - Pre-downloads and decodes common marker icon URLs into memory.
class MapWarmupPermanent extends StatefulWidget {
  const MapWarmupPermanent({Key? key}) : super(key: key);

  @override
  State<MapWarmupPermanent> createState() => _MapWarmupPermanentState();
}

class _MapWarmupPermanentState extends State<MapWarmupPermanent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  nmap.GoogleMapController? _controller;
  bool _didWarm = false;

  static const List<String> _iconUrls = <String>[
    // Default icons used around the app (PickerMap & others)
    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/bgmclb0d2bsd/ChatGPT_Image_3_de_set._de_2025%2C_19_17_48.png',
    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png',
  ];

  @override
  void initState() {
    super.initState();
    // Kick off icon prefetch immediately.
    _prefetchIcons();
  }

  Future<void> _prefetchIcons() async {
    // Prefetch a few common target sizes to avoid resize work at runtime.
    const List<int> sizes = <int>[32, 64, 128, 160];
    for (final url in _iconUrls) {
      for (final targetPx in sizes) {
        if (IconGlobalCache.contains(url, targetPx)) continue;
        try {
          final resp = await http
              .get(Uri.parse(url), headers: {'accept': 'image/*'})
              .timeout(const Duration(seconds: 8));
          if (resp.statusCode >= 200 && resp.statusCode < 300) {
            final bytes = resp.bodyBytes;
            final ui.Codec codec = await ui.instantiateImageCodec(bytes,
                targetWidth: targetPx);
            final ui.FrameInfo frame = await codec.getNextFrame();
            final ui.Image img = frame.image;
            final ByteData? out =
                await img.toByteData(format: ui.ImageByteFormat.png);
            if (out != null) {
              IconGlobalCache.put(url, targetPx, out.buffer.asUint8List());
            }
          }
        } catch (_) {
          // ignore failures; warmup is best-effort
        }
      }
    }
  }

  Future<void> _warmCamera() async {
    if (_controller == null) return;
    final dynamic dc = _controller;
    try {
      await dc.animateCameraTo(
        target: const nmap.LatLng(0, 0),
        zoom: 2.0,
        bearing: 0.0,
        tilt: 0.0,
        durationMs: 220,
      );
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await dc.animateCameraTo(
        target: const nmap.LatLng(37.7749, -122.4194), // SF
        zoom: 10.0,
        bearing: 0.0,
        tilt: 0.0,
        durationMs: 220,
      );
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await dc.animateCameraTo(
        target: const nmap.LatLng(-23.5505, -46.6333), // São Paulo
        zoom: 10.0,
        bearing: 0.0,
        tilt: 0.0,
        durationMs: 220,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Keep a tiny hidden native map alive.
    return IgnorePointer(
      ignoring: true,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: SizedBox(
          width: 2,
          height: 2,
          child: Opacity(
            opacity: 0.0,
            child: nmap.GoogleMapView(
              initialCameraPosition: const nmap.CameraPosition(
                target: nmap.LatLng(0, 0),
                zoom: 1.0,
              ),
              myLocationEnabled: false,
              buildingsEnabled: false,
              trafficEnabled: false,
              padding: const nmap.MapPadding(),
              onMapCreated: (c) async {
                _controller = c;
                try {
                  await c.onMapLoaded;
                } catch (_) {}
                if (!_didWarm) {
                  _didWarm = true;
                  // One-off camera hops to populate internal pipelines.
                  // Intentionally not awaited.
                  _warmCamera();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
