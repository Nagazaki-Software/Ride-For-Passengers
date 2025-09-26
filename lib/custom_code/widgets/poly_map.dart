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

import 'index.dart'; // Imports other custom widgets

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:convert';
import 'package:characters/characters.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart' as fa;

import '/flutter_flow/lat_lng.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_native_sdk/google_maps_native_sdk.dart' as nmap;

class PolyMap extends StatefulWidget {
  const PolyMap({
    super.key,
    this.width,
    this.height,
    required this.userLocation,
    this.userName,
    this.userPhotoUrl,
    this.driversRefs,
    this.refreshMs = 8000,
    this.userMarkerSize = 112,
    this.driverIconWidth = 128,
    this.driverDriverIconUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/bgmclb0d2bsd/ChatGPT_Image_3_de_set._de_2025%2C_19_17_48.png',
    this.driverTaxiIconUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
    this.searchMessage = 'Procurando motoristas',
    this.showSearchHud = true,
    this.focusIntervalMs = 6400,
    this.focusHoldMs = 1800,
    this.enableDriverFocus = true,
    this.showPulseHalo = true,
    this.showViewingBubble = true,
  });

  final double? width;
  final double? height;
  final LatLng userLocation;
  final String? userName;
  final String? userPhotoUrl;
  final List<DocumentReference>? driversRefs;
  final int refreshMs;
  final int userMarkerSize;
  final int driverIconWidth;
  final String driverDriverIconUrl;
  final String driverTaxiIconUrl;
  final String searchMessage;
  final bool showSearchHud;
  final int focusIntervalMs;
  final int focusHoldMs;
  final bool enableDriverFocus;
  final bool showPulseHalo; // aneis de pulso grandes em volta do usuario
  final bool showViewingBubble; // balÃ£o "..." acima do usuÃ¡rio

  @override
  State<PolyMap> createState() => _PolyMapState();
}

class _PolyMapState extends State<PolyMap> with SingleTickerProviderStateMixin {
  nmap.GoogleMapController? _controller;

  final Set<String> _markerIds = <String>{};
  final Map<String, nmap.LatLng> _markerPos = {};
  final Map<String, String> _markerTitle = {};

  final Map<String, StreamSubscription<DocumentSnapshot>> _refsSubs = {};

  Timer? _autoFitTimer;
  ui.Image? _userAvatarImage;
  int _userAvatarSize = 112;
  int _lastPulseMs = 0;
  String? _lastUserName;
  String? _lastUserPhoto;
  AnimationController? _pulseController;
  Timer? _ellipsisTimer;
  int _ellipsisDots = 0;
  Timer? _focusTimer;
  int _focusIndex = 0;
  bool _focusInFlight = false;
  final Map<String, Uint8List> _iconCache = {};
  DateTime? _autoFitResumeAt;

  // Pixel transparente para evitar o pin vermelho enquanto carrega ícone real
  static final Uint8List _transparentPixel = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=');

  String _bytesToDataUrl(Uint8List bytes) =>
      'data:image/png;base64,' + base64Encode(bytes);

  // ===== Helpers para URLs/Assets (alinhado com PickerMap) =====
  String? _cleanUrl(String? url) {
    if (url == null) return null;
    final String trimmed = url.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _looksSvg(String? url) {
    final u = (url ?? '').toLowerCase();
    return u.endsWith('.svg') || u.contains('image/svg');
  }

  String _massageUrl(String url) {
    String s = url.trim();
    if (s.startsWith('http://')) s = 'https://${s.substring(7)}';

    if (s.startsWith('gs://')) {
      final noGs = s.substring(5);
      final slash = noGs.indexOf('/');
      if (slash > 0) {
        final bucket = noGs.substring(0, slash);
        final path = noGs.substring(slash + 1);
        final encodedPath = Uri.encodeComponent(path);
        s =
            'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
      }
    }

    if (s.contains('firebasestorage.googleapis.com') &&
        !s.contains('alt=media')) {
      s += s.contains('?') ? '&alt=media' : '?alt=media';
    }

    if (s.contains('storage.googleapis.com') && !s.contains('%')) {
      try {
        final u = Uri.parse(s);
        final fixed = Uri(
          scheme: u.scheme.isEmpty ? 'https' : u.scheme,
          host: u.host,
          port: u.hasPort ? u.port : null,
          pathSegments: u.pathSegments.map(Uri.encodeComponent).toList(),
          query: u.query.isEmpty ? null : u.query,
        );
        s = fixed.toString();
      } catch (_) {
        s = Uri.encodeFull(s);
      }
    }
    return s;
  }

  String? _assetPathFromUrlOrName(String? urlOrName) {
    final s = (urlOrName ?? '').trim();
    if (s.isEmpty) return null;
    try {
      final uri = Uri.parse(s);
      final seg = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : s;
      final decoded = Uri.decodeComponent(seg);
      final name = decoded.endsWith('.png') ? decoded : '$decoded.png';
      return 'assets/images/$name';
    } catch (_) {
      final base = s.endsWith('.png') ? s : '$s.png';
      return 'assets/images/$base';
    }
  }

  Future<Uint8List?> _tryLoadAssetPng(String? urlOrName, int targetWidthPx) async {
    final String? asset = _assetPathFromUrlOrName(urlOrName);
    if (asset == null) return null;
    try {
      final data = await rootBundle.load(asset);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: targetWidthPx,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image img = frame.image;
      final ByteData? out = await img.toByteData(format: ui.ImageByteFormat.png);
      return out?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  bool _looksFirebaseStorageUrl(String s) {
    final u = s.toLowerCase();
    return u.contains('firebasestorage.googleapis.com') ||
        u.contains('storage.googleapis.com');
  }

  Future<Map<String, String>> _authHeadersForFirebaseIfAny() async {
    try {
      final user = fa.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String? token = await user.getIdToken();
        if ((token ?? '').isNotEmpty) {
          return {'Authorization': 'Bearer ${token!}'};
        }
      }
    } catch (_) {}
    return const {};
  }

  static const _darkMapStyle =
      '[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#2b2b2b"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f2f2f"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}]';

  nmap.LatLng _gm(LatLng p) => nmap.LatLng(p.latitude, p.longitude);

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(_handlePulseTick)
          ..repeat();
    _ellipsisTimer = Timer.periodic(const Duration(milliseconds: 520), (_) {
      if (!mounted) return;
      setState(() {
        _ellipsisDots = (_ellipsisDots + 1) % 4;
      });
    });
    _autoFitTimer =
        Timer.periodic(Duration(milliseconds: widget.refreshMs), (_) async {
      await _fitToContent(padding: 60);
    });
  }

  @override
  void dispose() {
    _pulseController?.removeListener(_handlePulseTick);
    _pulseController?.dispose();
    _ellipsisTimer?.cancel();
    _focusTimer?.cancel();
    _autoFitTimer?.cancel();
    for (final s in _refsSubs.values) {
      s.cancel();
    }
    _refsSubs.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PolyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshMs != widget.refreshMs) {
      _autoFitTimer?.cancel();
      _autoFitTimer =
          Timer.periodic(Duration(milliseconds: widget.refreshMs), (_) async {
        await _fitToContent(padding: 60);
      });
    }
    if (oldWidget.userName != widget.userName ||
        oldWidget.userPhotoUrl != widget.userPhotoUrl) {
      _userAvatarImage = null;
      _lastUserName = null;
      _lastUserPhoto = null;
      _placeUserMarker();
    } else if (oldWidget.userLocation != widget.userLocation) {
      _placeUserMarker();
    }
    if (!_listEquals(oldWidget.driversRefs, widget.driversRefs)) {
      _subscribeDriversRefs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? double.infinity;
    final h = widget.height ?? 320.0;

    final initialCamera = nmap.CameraPosition(
      target: _gm(widget.userLocation),
      zoom: 13.0,
    );

    return SizedBox(
      width: w,
      height: h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
            nmap.GoogleMapView(
              key: const ValueKey('PolyMapNative'),
              initialCameraPosition: initialCamera,
              myLocationEnabled: false,
              trafficEnabled: false,
              buildingsEnabled: false,
              mapStyleJson: _darkMapStyle,
              onMapCreated: (nmap.GoogleMapController c) async {
                _controller = c;
                try {
                  await c.onMapLoaded;
                } catch (_) {}
                await _placeUserMarker();
                _subscribeDriversRefs();
                await _fitToContent(padding: 60);
              },
            ),
            if (widget.showSearchHud)
              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: IgnorePointer(
                  ignoring: true,
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 320),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1.4,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 16,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation(
                                    Colors.amber.shade400),
                                backgroundColor: Colors.white.withOpacity(0.12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${widget.searchMessage}${'.' * _ellipsisDots}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeUserMarker() async {
    if (_controller == null) return;
    final id = 'user';
    final pos = _gm(widget.userLocation);

    if (!_markerIds.contains(id)) {
      await _controller!.addMarker(nmap.MarkerOptions(
        id: id,
        position: pos,
        title: 'VocÃª',
        anchorU: 0.5,
        anchorV: 0.5,
        zIndex: 30.0,
      ));
      _markerIds.add(id);
      _markerPos[id] = pos;
      _markerTitle[id] = 'VocÃª';
    } else {
      await _controller!.updateMarker(id, position: pos);
      _markerPos[id] = pos;
    }

    await _ensureUserAvatar();
    await _refreshUserMarkerIcon(force: true);
  }

  void _subscribeDriversRefs() {
    for (final s in _refsSubs.values) {
      s.cancel();
    }
    _refsSubs.clear();

    final refs = widget.driversRefs;
    if (refs == null || refs.isEmpty) {
      _onDriverMarkersChanged();
      return;
    }

    for (final ref in refs) {
      final id = ref.id;
      _refsSubs[id] = ref.snapshots().listen((snap) async {
        if (!mounted) return;
        if (!snap.exists) {
          if (_markerIds.contains('driver_$id')) {
            try {
              await _controller?.removeMarker('driver_$id');
            } catch (_) {}
            _markerIds.remove('driver_$id');
          }
          _markerPos.remove('driver_$id');
          _markerTitle.remove('driver_$id');
          _onDriverMarkersChanged();
          return;
        }

        final data = snap.data() as Map<String, dynamic>?;
        nmap.LatLng? p;
        final loc = data?['location'];
        if (loc is GeoPoint) {
          p = nmap.LatLng(loc.latitude, loc.longitude);
        } else {
          final lat = (data?['lat'] as num?)?.toDouble();
          final lng = (data?['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) p = nmap.LatLng(lat, lng);
        }
        if (p == null) return;

        final String name = (data?['display_name'] ?? 'Driver').toString();
        final String photoUrl = (data?['photo_url'] ?? '').toString();

        await _upsertDriverMarker(
          id: id,
          name: name,
          photoUrl: photoUrl,
          position: p,
          data: data,
        );
      });
    }
  }

  Future<void> _upsertDriverMarker({
    required String id,
    required String name,
    required String photoUrl,
    required nmap.LatLng position,
    required Map<String, dynamic>? data,
  }) async {
    final mid = 'driver_$id';

    if (_markerIds.contains(mid)) {
      await _controller?.updateMarker(mid, position: position);
      _markerPos[mid] = position;
    } else {
      await _controller?.addMarker(nmap.MarkerOptions(
        id: mid,
        position: position,
        title: name,
        iconUrl:
            'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
        anchorU: 0.5,
        anchorV: 0.62,
        zIndex: 22.0,
      ));
      _markerIds.add(mid);
      _markerPos[mid] = position;
      _markerTitle[mid] = name;
    }

    final Uint8List? bytes = await _driverMarkerBytes(
      data: data,
      photoUrl: photoUrl,
    );

    try {
      final dynamic dc = _controller;
      if (bytes != null) {
        await dc.setMarkerIconBytes(
          id: mid,
          bytes: bytes,
          anchorU: 0.5,
          anchorV: 0.62,
        );
      }
    } catch (_) {}
    _onDriverMarkersChanged();
  }

  Future<void> _fitToContent({double padding = 60}) async {
    if (_controller == null) return;
    if (_markerIds.isEmpty) return;
    if (!_isAutoFitAllowed()) return;

    double? minLat, maxLat, minLng, maxLng;
    for (final id in _markerIds) {
      final p = _markerPos[id];
      if (p == null) continue;
      minLat = (minLat == null) ? p.latitude : math.min(minLat, p.latitude);
      maxLat = (maxLat == null) ? p.latitude : math.max(maxLat, p.latitude);
      minLng = (minLng == null) ? p.longitude : math.min(minLng, p.longitude);
      maxLng = (maxLng == null) ? p.longitude : math.max(maxLng, p.longitude);
    }
    if (minLat == null || minLng == null || maxLat == null || maxLng == null)
      return;

    final ne = nmap.LatLng(maxLat!, maxLng!);
    final sw = nmap.LatLng(minLat!, minLng!);
    try {
      await _controller!.animateToBounds(ne, sw, padding: padding);
    } catch (_) {}
  }

  Future<Uint8List> _buildDotPng(
      {Color color = const Color(0xFFFFC107),
      int size = 28,
      bool ring = true}) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final c = ui.Offset(size / 2, size / 2);
    final r = size / 2.0;

    if (ring) {
      final ringPaint = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = (size * 0.16)
        ..color = color.withOpacity(0.9)
        ..isAntiAlias = true;
      canvas.drawCircle(c, r - ringPaint.strokeWidth / 2, ringPaint);
    }

    final dot = ui.Paint()
      ..color = color
      ..isAntiAlias = true;
    canvas.drawCircle(c, r * 0.62, dot);

    final img = await recorder.endRecording().toImage(size, size);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<Uint8List?> _download(String url) async {
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) return resp.bodyBytes;
    } catch (_) {}
    return null;
  }

  Future<Uint8List> _circleImagePng(String url, {int size = 96}) async {
    final raw = await _download(url);
    if (raw == null) return _buildDotPng();
    final codec = await ui.instantiateImageCodec(raw,
        targetWidth: size, targetHeight: size);
    final frame = await codec.getNextFrame();
    final img = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final rect = ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
    final r = size / 2.0;
    final clip = ui.Path()
      ..addOval(ui.Rect.fromCircle(center: ui.Offset(r, r), radius: r));
    canvas.clipPath(clip);

    final paint = ui.Paint()..isAntiAlias = true;
    canvas.drawImageRect(
      img,
      ui.Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      rect,
      paint,
    );

    final border = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0xFFFFC107);
    canvas.drawCircle(ui.Offset(r, r), r - 3, border);

    final outImg = await recorder.endRecording().toImage(size, size);
    final bytes = await outImg.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> _ensureUserAvatar() async {
    final String name =
        (widget.userName == null || widget.userName!.trim().isEmpty)
            ? 'VocÃª'
            : widget.userName!.trim();
    final String? photo =
        (widget.userPhotoUrl == null || widget.userPhotoUrl!.trim().isEmpty)
            ? null
            : widget.userPhotoUrl!.trim();

    if (_userAvatarImage != null &&
        _lastUserName == name &&
        _lastUserPhoto == photo) {
      return;
    }

    _userAvatarSize = widget.userMarkerSize.clamp(56, 196);
    _userAvatarImage = await _buildUserAvatarImage(
      name: name,
      photoUrl: photo,
      size: _userAvatarSize,
    );
    _lastUserName = name;
    _lastUserPhoto = photo;
  }

  Future<ui.Image> _buildUserAvatarImage({
    required String name,
    required String? photoUrl,
    required int size,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final rect = ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
    final center = ui.Offset(size / 2.0, size / 2.0);
    final double radius = size / 2.0;

    if (photoUrl != null) {
      final Uint8List? raw = await _download(photoUrl);
      if (raw != null) {
        final ui.Codec codec = await ui.instantiateImageCodec(raw,
            targetWidth: size, targetHeight: size);
        final ui.FrameInfo frame = await codec.getNextFrame();
        final ui.Image img = frame.image;
        final ui.Path clip = ui.Path()
          ..addOval(ui.Rect.fromCircle(center: center, radius: radius));
        canvas.save();
        canvas.clipPath(clip);
        canvas.drawImageRect(
          img,
          ui.Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          rect,
          ui.Paint()..isAntiAlias = true,
        );
        canvas.restore();
      } else {
        _drawInitialsAvatar(canvas, rect, name);
      }
    } else {
      _drawInitialsAvatar(canvas, rect, name);
    }

    final border = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = math.max(4.0, size * 0.08)
      ..color = const Color(0xFFFFC107)
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius - border.strokeWidth / 2, border);

    final ui.Image image = await recorder.endRecording().toImage(size, size);
    return image;
  }

  void _drawInitialsAvatar(ui.Canvas canvas, ui.Rect rect, String name) {
    final ui.Offset center =
        ui.Offset(rect.width / 2.0 + rect.left, rect.height / 2.0 + rect.top);
    final double radius = rect.width / 2.0;
    final Color base = _colorFromName(name);
    final Color accent = Color.lerp(base, Colors.white, 0.25)!;

    final ui.Paint paint = ui.Paint()
      ..shader = ui.Gradient.linear(
        ui.Offset(rect.left, rect.top),
        ui.Offset(rect.right, rect.bottom),
        [base, accent],
      )
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, paint);

    final String initials = _initialsFromName(name);

    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: rect.width * 0.42,
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
      ),
    )
      ..pushStyle(ui.TextStyle(color: Colors.white))
      ..addText(initials);
    final ui.Paragraph paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: rect.width));
    final double textY = rect.top + (rect.height - paragraph.height) / 2.0;
    canvas.drawParagraph(paragraph, ui.Offset(rect.left, textY));
  }

  String _initialsFromName(String name) {
    final Characters chars = name.characters.where((c) => c.trim().isNotEmpty);
    if (chars.isEmpty) {
      return 'V';
    }
    final List<String> parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final String first =
        parts.isNotEmpty ? parts.first.characters.first : chars.first;
    String second = '';
    if (parts.length > 1) {
      second = parts.last.characters.first;
    } else if (chars.length > 1) {
      second = chars.elementAt(1);
    }
    return (first + second).toUpperCase();
  }

  Color _colorFromName(String name) {
    int hash = 0;
    for (final int codeUnit in name.codeUnits) {
      hash = (hash * 37 + codeUnit) & 0xFFFFFF;
    }
    final int r = ((hash >> 16) & 0xFF) ^ 0x55;
    final int g = ((hash >> 8) & 0xFF) ^ 0x88;
    final int b = (hash & 0xFF) ^ 0x33;
    return Color.fromARGB(255, r, g, b);
  }

  Future<void> _refreshUserMarkerIcon({bool force = false}) async {
    if (_controller == null) return;
    if (_userAvatarImage == null) {
      await _ensureUserAvatar();
      if (_userAvatarImage == null) return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    if (!force && now - _lastPulseMs < 120) {
      return;
    }
    _lastPulseMs = now;

    final double progress = _pulseController?.value ?? 0;
    final ui.Image base = _userAvatarImage!;
    final double baseSize = _userAvatarSize.toDouble();
    final double expand = baseSize * 0.65 * progress;
    final double stroke = baseSize * (0.2 - 0.12 * progress).clamp(0.08, 0.22);
    final double opacity = (1.0 - progress).clamp(0.0, 1.0);

    // EspaÃ§o extra para aneis e balÃ£o
    final double bubbleHeight = widget.showViewingBubble ? baseSize * 0.7 : 0.0;
    final double canvasSize = baseSize + expand * 2 + stroke * 2 + bubbleHeight;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    // centro levemente deslocado para deixar espaÃ§o para o balÃ£o
    final ui.Offset center = ui.Offset(
      canvasSize / 2.0,
      (canvasSize - bubbleHeight) / 2.0 + bubbleHeight * 0.06,
    );

    if (widget.showPulseHalo && opacity > 0.01) {
      // preenchidos (discos) + aneis para parecer pulsar
      final Color halo = const Color(0xFFFFC107);
      final double r0 = baseSize / 2 + expand * 0.35;
      final double r1 = baseSize / 2 + expand * 0.65;
      final double r2 = baseSize / 2 + expand;

      // Discos suaves
      final ui.Paint p0 = ui.Paint()
        ..style = ui.PaintingStyle.fill
        ..color = halo.withOpacity(0.08 * opacity)
        ..isAntiAlias = true;
      final ui.Paint p1 = ui.Paint()
        ..style = ui.PaintingStyle.fill
        ..color = halo.withOpacity(0.06 * opacity)
        ..isAntiAlias = true;
      final ui.Paint p2 = ui.Paint()
        ..style = ui.PaintingStyle.fill
        ..color = halo.withOpacity(0.04 * opacity)
        ..isAntiAlias = true;
      canvas.drawCircle(center, r0, p0);
      canvas.drawCircle(center, r1, p1);
      canvas.drawCircle(center, r2, p2);

      // Contornos finos
      final ui.Paint ring = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = halo.withOpacity(0.32 * opacity)
        ..isAntiAlias = true;
      canvas.drawCircle(center, r2, ring);
      final ui.Paint inner = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = stroke * 0.6
        ..color = halo.withOpacity(0.20 * opacity)
        ..isAntiAlias = true;
      canvas.drawCircle(center, r1, inner);
    }

    final ui.Rect dst = ui.Rect.fromCenter(
      center: center,
      width: baseSize,
      height: baseSize,
    );
    canvas.drawImageRect(
      base,
      ui.Rect.fromLTWH(0, 0, base.width.toDouble(), base.height.toDouble()),
      dst,
      ui.Paint()..isAntiAlias = true,
    );

    // BalÃ£o de "..." indicando motoristas visualizando
    final bool anyDriver = _markerIds.any((id) => id.startsWith('driver_'));
    if (widget.showViewingBubble && anyDriver) {
      final double bob = math.sin(progress * 2 * math.pi) * (baseSize * 0.04);
      final double bw = baseSize * 0.9;
      final double bh = baseSize * 0.42;
      final double tail = baseSize * 0.14;
      final ui.Offset bCenter = center.translate(0, -baseSize / 2 - bh / 2 - 10 - tail + bob);
      final ui.Rect bRect = ui.Rect.fromCenter(
        center: bCenter,
        width: bw,
        height: bh,
      );

      final ui.RRect rrect = ui.RRect.fromRectAndRadius(bRect, ui.Radius.circular(bh * 0.5));
      final ui.Paint bubblePaint = ui.Paint()
        ..color = const Color(0xFF1F1F1F).withOpacity(0.88)
        ..isAntiAlias = true;
      final ui.Paint border = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white.withOpacity(0.08)
        ..isAntiAlias = true;
      canvas.drawRRect(rrect, bubblePaint);
      canvas.drawRRect(rrect, border);

      // rabinho do balÃ£o
      final ui.Path tailPath = ui.Path()
        ..moveTo(bRect.center.dx, bRect.bottom)
        ..relativeLineTo(-tail * 0.35, tail * 0.55)
        ..relativeLineTo(tail * 0.7, 0)
        ..close();
      canvas.drawPath(tailPath, bubblePaint);

      // Dots
      final int dots = _ellipsisDots.clamp(1, 3); // 1..3
      final double dotR = bh * 0.08;
      final double spacing = dotR * 3.2;
      final double startX = bRect.center.dx - spacing;
      final double y = bRect.center.dy + 0.5;
      final ui.Paint dotPaint = ui.Paint()
        ..color = Colors.white.withOpacity(0.92)
        ..isAntiAlias = true;
      for (int i = 0; i < dots; i++) {
        canvas.drawCircle(ui.Offset(startX + i * spacing, y), dotR, dotPaint);
      }
    }

    final ui.Image composed = await recorder
        .endRecording()
        .toImage(canvasSize.round(), canvasSize.round());
    final ByteData? data =
        await composed.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return;
    final Uint8List bytes = data.buffer.asUint8List();
    try {
      final dynamic dc = _controller;
      await dc.setMarkerIconBytes(
        id: 'user',
        bytes: bytes,
        anchorU: 0.5,
        anchorV: 0.5,
      );
    } catch (_) {}
  }

  void _handlePulseTick() {
    if (!mounted) return;
    _refreshUserMarkerIcon();
  }

  Future<Uint8List?> _driverMarkerBytes({
    required Map<String, dynamic>? data,
    required String photoUrl,
  }) async {
    final bool isTaxi = _isTaxi(data);
    final String? preferred = _markerUrlFromData(data, isTaxi: isTaxi);
    final String fallback =
        isTaxi ? widget.driverTaxiIconUrl : widget.driverDriverIconUrl;
    final int size = widget.driverIconWidth.clamp(48, 220);

    final Uint8List? brandBytes =
        await _loadMarkerIcon(preferred ?? fallback, size);
    if (brandBytes != null) {
      return brandBytes;
    }

    if (photoUrl.trim().isNotEmpty) {
      final Uint8List? circle =
          await _circleImagePng(photoUrl.trim(), size: size);
      if (circle != null) return circle;
    }

    return _buildDotPng(color: const Color(0xFFFFC107), size: 32);
  }

  Future<Uint8List?> _loadMarkerIcon(String? url, int size) async {
    if (url == null || url.trim().isEmpty) return null;
    final String key = '${url.trim()}@$size';
    if (_iconCache.containsKey(key)) {
      return _iconCache[key];
    }

    final String rawUrl = url.trim();

    // 1) Data URL inline
    if (rawUrl.startsWith('data:image/')) {
      final Uint8List? d = _decodeDataUrl(rawUrl);
      if (d != null) {
        _iconCache[key] = d;
        return d;
      }
    }

    // 2) Asset shorthand or explicit asset://
    final String lower = rawUrl.toLowerCase();
    if (lower.startsWith('asset://')) {
      final String asset = rawUrl.substring('asset://'.length);
      final Uint8List? bytes = await _tryLoadAssetPng(asset, size);
      if (bytes != null) {
        _iconCache[key] = bytes;
        return bytes;
      }
    } else {
      final String? assetPath = _assetPathFromUrlOrName(rawUrl);
      if (assetPath != null) {
        final Uint8List? bytes = await _tryLoadAssetPng(assetPath, size);
        if (bytes != null) {
          _iconCache[key] = bytes;
          return bytes;
        }
      }
    }

    // 3) Network (http/https/gs/firebasestorage/storage.googleapis)
    if (_looksSvg(rawUrl)) return null; // não renderiza SVG
    final String net = _massageUrl(rawUrl);
    try {
      final Uri uri = Uri.parse(net);
      final Map<String, String> baseHeaders = {
        'accept': 'image/*,*/*;q=0.8',
        'user-agent': 'PolyMap/1.0',
      };
      Future<http.Response> doGet([Map<String, String>? extra]) {
        final headers = Map<String, String>.from(baseHeaders);
        if (extra != null) headers.addAll(extra);
        return http.get(uri, headers: headers).timeout(const Duration(seconds: 8));
      }

      http.Response resp = await doGet();
      if ((resp.statusCode == 401 || resp.statusCode == 403) &&
          _looksFirebaseStorageUrl(uri.toString())) {
        final auth = await _authHeadersForFirebaseIfAny();
        if (auth.isNotEmpty) {
          resp = await doGet(auth);
        }
      }
      if (resp.statusCode < 200 || resp.statusCode >= 300) return null;
      final Uint8List raw = resp.bodyBytes;
      final ui.Codec codec =
          await ui.instantiateImageCodec(raw, targetWidth: size, targetHeight: size);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image image = frame.image;
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);
      final ui.Rect rect =
          ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        rect,
        ui.Paint()..isAntiAlias = true,
      );
      final ui.Image out = await recorder.endRecording().toImage(size, size);
      final ByteData? data = await out.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return null;
      final Uint8List bytes = data.buffer.asUint8List();
      _iconCache[key] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Uint8List? _decodeDataUrl(String url) {
    final int comma = url.indexOf(',');
    if (comma <= 0) return null;
    final String data = url.substring(comma + 1);
    try {
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }

  bool _isTaxi(Map<String, dynamic>? data) {
    final Set<String> tokens = <String>{};
    void add(dynamic source) {
      if (source == null) return;
      if (source is String) {
        final String val = source.trim().toLowerCase();
        if (val.isNotEmpty) tokens.add(val);
      } else if (source is Iterable) {
        for (final dynamic item in source) {
          add(item);
        }
      }
    }

    if (data?['users'] is Map) {
      final Map users = data!['users'] as Map;
      add(users['platform']);
      add(users['plataform']);
      add(users['platforms']);
      add(users['plataforms']);
      add(users['type']);
    }
    add(data?['platform']);
    add(data?['plataform']);
    add(data?['platforms']);
    add(data?['plataforms']);
    add(data?['type']);

    if (tokens.any((value) => value.contains('taxi'))) {
      return true;
    }
    if (tokens.any((value) => value.contains('driver'))) {
      return false;
    }

    final String? marker = _markerUrlFromData(data, isTaxi: true);
    if (marker != null) return true;
    return false;
  }

  // Robust reader similar to PickerMap
  Map<String, String> _markerUrlsFromData(Map<String, dynamic>? data) {
    final Map<String, String> result = <String, String>{};

    void absorb(String? key, dynamic value) {
      if (value == null) return;
      if (value is String) {
        final String trimmed = value.trim();
        if (trimmed.isEmpty) return;
        result[key ?? 'default'] = trimmed;
        return;
      }
      if (value is Iterable) {
        for (final dynamic item in value) {
          if (item is Map) {
            final dynamic innerKey = item['key'] ?? item['name'] ?? key;
            final dynamic innerValue = item['url'] ?? item['value'] ?? item['src'];
            if (innerKey != null || innerValue != null) {
              absorb(innerKey?.toString() ?? key, innerValue);
            } else {
              absorb(key, item);
            }
          } else {
            absorb(key, item);
          }
        }
        return;
      }
      if (value is Map) {
        if (value.containsKey('url') || value.containsKey('value')) {
          final dynamic innerKey = value['key'] ?? value['name'] ?? key;
          final dynamic innerValue = value['url'] ?? value['value'];
          absorb(innerKey?.toString() ?? key, innerValue);
          return;
        }
        value.forEach((dynamic k, dynamic v) {
          absorb(k?.toString(), v);
        });
      }
    }

    void readField(dynamic source) {
      if (source == null) return;
      if (source is Map) {
        source.forEach((dynamic k, dynamic v) {
          absorb(k?.toString(), v);
        });
      } else if (source is Iterable) {
        for (final dynamic item in source) {
          if (item is Map) {
            final dynamic innerKey = item['key'] ?? item['name'];
            final dynamic innerValue = item['url'] ?? item['value'] ?? item['src'];
            if (innerKey != null || innerValue != null) {
              absorb(innerKey?.toString(), innerValue);
            } else {
              absorb(null, item);
            }
          } else {
            absorb(null, item);
          }
        }
      } else if (source is String) {
        absorb(null, source);
      }
    }

    readField(data?['markersUrls']);
    readField(data?['markerUrls']);
    readField(data?['markers_url']);
    readField(data?['marker_url']);
    readField(data?['markers']);

    final dynamic users = data?['users'];
    if (users is Map<String, dynamic>) {
      readField(users['markersUrls']);
      readField(users['markerUrls']);
      readField(users['markers_url']);
      readField(users['marker_url']);
    }

    return result;
  }

  String? _markerUrlForKeys(Map<String, String> map, List<String> keys) {
    if (map.isEmpty) return null;
    String normalize(String value) =>
        value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    final Map<String, String> normalized = <String, String>{};
    map.forEach((String key, String value) {
      final String norm = normalize(key);
      if (norm.isNotEmpty && value.trim().isNotEmpty) {
        normalized[norm] = value.trim();
      }
    });
    for (final String key in keys) {
      final String normKey = normalize(key);
      final String? candidate = normalized[normKey];
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }
    return null;
  }

  String? _markerUrlFromData(Map<String, dynamic>? data,
      {required bool isTaxi}) {
    final Map<String, String> urls = _markerUrlsFromData(data);
    final List<String> keys = isTaxi
        ? <String>['ride taxi', 'ride_taxi', 'taxi', 'car', 'vehicle']
        : <String>['ride driver', 'driver', 'default', 'principal', 'main', 'primary'];

    String? url = _markerUrlForKeys(urls, keys);
    if (url != null && url.trim().isNotEmpty) return url.trim();

    // Fallbacks comuns
    final Map<String, dynamic>? usersMap =
        (data?['users'] is Map<String, dynamic>) ? (data?['users'] as Map<String, dynamic>?) : null;
    final List<String?> fallback = <String?>[
      data?['markerUrl']?.toString(),
      data?['marker_url']?.toString(),
      usersMap?['markerUrl']?.toString(),
      usersMap?['marker_url']?.toString(),
      data?['vehiclePhoto']?.toString(),
      data?['carPhoto']?.toString(),
      usersMap?['vehiclePhoto']?.toString(),
      usersMap?['carPhoto']?.toString(),
    ];
    for (final String? raw in fallback) {
      if (raw != null && raw.trim().isNotEmpty) {
        return raw.trim();
      }
    }
    return null;
  }

  void _onDriverMarkersChanged() {
    if (!widget.enableDriverFocus) return;
    final List<String> drivers =
        _markerIds.where((id) => id.startsWith('driver_')).toList();
    if (drivers.isEmpty) {
      _focusTimer?.cancel();
      _focusTimer = null;
      _focusIndex = 0;
      return;
    }
    if (_focusTimer != null) {
      return;
    }
    final int interval = widget.focusIntervalMs.clamp(2500, 12000);
    _focusTimer = Timer.periodic(Duration(milliseconds: interval), (_) {
      _focusNextDriver();
    });
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      _focusNextDriver();
    });
  }

  Future<void> _focusNextDriver() async {
    if (_focusInFlight || _controller == null) return;
    final List<String> drivers =
        _markerIds.where((id) => id.startsWith('driver_')).toList();
    if (drivers.isEmpty) {
      return;
    }
    if (_focusIndex >= drivers.length) {
      _focusIndex = 0;
    }
    final String id = drivers[_focusIndex];
    _focusIndex = (_focusIndex + 1) % drivers.length;
    final nmap.LatLng? pos = _markerPos[id];
    if (pos == null) {
      return;
    }
    _focusInFlight = true;
    _suspendAutoFitFor(Duration(milliseconds: widget.focusHoldMs + 1600));
    await _animateCameraTo(
      target: pos,
      zoom: 15.6,
      durationMs: 900,
    );
    await Future<void>.delayed(
        Duration(milliseconds: widget.focusHoldMs.clamp(900, 4000)));
    if (!mounted) {
      _focusInFlight = false;
      return;
    }
    await _animateCameraTo(
      target: _gm(widget.userLocation),
      zoom: 14.2,
      durationMs: 920,
    );
    _focusInFlight = false;
  }

  Future<void> _animateCameraTo({
    required nmap.LatLng target,
    double? zoom,
    int durationMs = 900,
  }) async {
    if (_controller == null) return;
    try {
      final dynamic dc = _controller;
      await dc.animateCameraTo(
        target: target,
        zoom: zoom ?? 14.5,
        durationMs: durationMs,
      );
    } catch (_) {}
  }

  void _suspendAutoFitFor(Duration duration) {
    _autoFitResumeAt = DateTime.now().add(duration);
  }

  bool _isAutoFitAllowed() {
    final DateTime? resume = _autoFitResumeAt;
    if (resume == null) return true;
    if (DateTime.now().isAfter(resume)) {
      _autoFitResumeAt = null;
      return true;
    }
    return false;
  }

  bool _listEquals(List<DocumentReference>? a, List<DocumentReference>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].path != b[i].path) return false;
    }
    return true;
  }
}
