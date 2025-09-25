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

import '/custom_code/widgets/index.dart'; // other custom widgets
import '/custom_code/actions/index.dart'; // custom actions
import '/flutter_flow/custom_functions.dart'; // custom functions

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '/flutter_flow/lat_lng.dart' show LatLng;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '/app_state.dart';
import '/services/tts_service.dart';

/// ------------------------------------------------------------ AddressPicker
/// v4.5 - Quick Picks preenchem DESTINO por padrão antes de digitar/falar -
/// Param quickPicksDefaultToDestination=true - Ao tocar em chip sem foco nos
/// campos -> seta Destination (Where to?) - Mantém comportamento esperado
/// quando o usuário foca explicitamente Pickup Outras features mantidas: -
/// Reverse geocode do pickup (texto), autocomplete com bias na user location
/// - Labels abaixo; SEM “Where to?” no destino; mic sempre visível
/// (tap-to-speak)
class AddressPicker extends StatefulWidget {
  const AddressPicker({
    super.key,
    this.width,
    this.height,
    required this.googleApiKey,
    this.countriesCsv,
    this.country = 'br',
    this.language = 'en',
    this.initialPickup,
    this.initialDestination,
    this.title = 'Select location',
    this.confirmText = 'Confirm',
    this.onConfirm,
    this.latlngUser,
    this.quickPicksDefaultToDestination = true, // 👈 NOVO
  });

  final double? width;
  final double? height;
  final String googleApiKey;

  final String? countriesCsv;
  final String country;
  final String language;

  final String? initialPickup;
  final String? initialDestination;
  final String title;
  final String confirmText;
  final Future Function(dynamic result)? onConfirm;

  /// User location (FlutterFlow LatLng)
  final LatLng? latlngUser;

  /// Se true, Quick Picks (chips) preenchem o DESTINO por padrão quando
  /// o usuário ainda não focou em nenhum campo (pré-digitação/fala).
  final bool quickPicksDefaultToDestination; // 👈 NOVO

  @override
  State<AddressPicker> createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  final _pickupCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _pickupFocus = FocusNode();
  final _destFocus = FocusNode();

  bool _editingPickup = true;
  List<_PlacePrediction> _predictions = [];
  bool _loading = false;
  String? _error;
  PickedPlace? _pickup;
  PickedPlace? _destination;
  Timer? _debounce;
  final String _sessionToken = _randToken();

  // Nearby
  bool _loadingNearby = false;
  List<_NearbyPlace> _nearby = [];
  String? _nearbyError;

  // Speech-to-text
  late final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechReady = false;
  bool _isListening = false;

  // Helpers
  double? get _uLat => widget.latlngUser?.latitude;
  double? get _uLng => widget.latlngUser?.longitude;
  bool get _hasUserLL => _uLat != null && _uLng != null;

  static String _randToken() {
    final r = math.Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(24, (_) => chars[r.nextInt(chars.length)]).join();
  }

  String _componentsQuery() {
    final csv = (widget.countriesCsv ?? '').trim();
    if (csv.isNotEmpty) {
      final parts = csv
          .split(RegExp(r'[,\s|]+'))
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .map((e) => 'country:$e')
          .join('|');
      if (parts.isNotEmpty) return '&components=$parts';
    }
    final c = (widget.country).trim().toLowerCase();
    if (c.isNotEmpty) return '&components=country:$c';
    return '';
  }

  String _locationBiasQuery() {
    if (!_hasUserLL) return '';
    return '&locationbias=circle:3500@${_uLat},${_uLng}';
  }

  @override
  void initState() {
    super.initState();

    // Garantia: nunca mostrar “Where to?” vindo de fora
    _pickupCtrl.text = widget.initialPickup ?? '';
    _destCtrl.text = (widget.initialDestination ?? '');
    if (_destCtrl.text.trim().toLowerCase() == 'where to?') {
      _destCtrl.clear();
    }
    _editingPickup = true;

    _pickupFocus.addListener(() {
      if (_pickupFocus.hasFocus) {
        setState(() => _editingPickup = true);
        _ensureSuggestionsEvenIfEmpty();
      } else {
        _maybeLoadNearby();
      }
    });
    _destFocus.addListener(() {
      if (_destFocus.hasFocus) {
        setState(() => _editingPickup = false);
        _ensureSuggestionsEvenIfEmpty();
      } else {
        _maybeLoadNearby();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Nearby/quick picks (logo de cara)
      _loadNearby();

      // Reverse geocode do pickup para preencher o 1º campo com TEXTO
      if (_hasUserLL && _pickupCtrl.text.isEmpty) {
        final p = await _reverseGeocode(_uLat!, _uLng!);
        if (p != null) {
          _pickup = p;
          _pickupCtrl.text = p.formattedAddress;
          setState(() {});
        }
      }

      // Speech init
      _speechReady =
          await _speech.initialize(onError: (_) {}, onStatus: (_) {});
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _destCtrl.dispose();
    _pickupFocus.dispose();
    _destFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _kickSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      final q =
          _editingPickup ? _pickupCtrl.text.trim() : _destCtrl.text.trim();
      if (q.isEmpty) {
        setState(() {
          _predictions = [];
          _error = null;
        });
        return;
      }
      _searchAutocomplete(q);
    });
  }

  Future<void> _searchAutocomplete(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeQueryComponent(query)}'
      '&language=${Uri.encodeQueryComponent(widget.language)}'
      '${_componentsQuery()}'
      '${_locationBiasQuery()}'
      '&sessiontoken=$_sessionToken'
      '&key=${widget.googleApiKey}',
    );

    try {
      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        setState(() {
          _loading = false;
          _error = 'Failed (${resp.statusCode})';
        });
        return;
      }
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final status = (data['status'] ?? '').toString();
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        setState(() {
          _loading = false;
          _error = 'Error: $status';
          _predictions = [];
        });
        return;
      }

      final list = (data['predictions'] as List?) ?? [];
      final preds = list.map((e) {
        final s = (e['structured_formatting'] ?? {}) as Map;
        return _PlacePrediction(
          placeId: (e['place_id'] ?? '').toString(),
          mainText: (s['main_text'] ?? '').toString(),
          secondaryText: (s['secondary_text'] ?? '').toString(),
          description: (e['description'] ?? '').toString(),
        );
      }).toList();

      setState(() {
        _loading = false;
        _predictions = preds;
        _error = null;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Network error';
      });
    }
  }

  Future<PickedPlace?> _fetchDetailsById(String placeId,
      {String? fallbackDesc}) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=${Uri.encodeQueryComponent(placeId)}'
      '&language=${Uri.encodeQueryComponent(widget.language)}'
      '&fields=name,formatted_address,geometry/location'
      '&sessiontoken=$_sessionToken'
      '&key=${widget.googleApiKey}',
    );
    try {
      final resp = await http.get(uri);
      if (resp.statusCode != 200) return null;
      final data = json.decode(resp.body) as Map<String, dynamic>;
      if ((data['status'] ?? '') != 'OK') return null;
      final r = (data['result'] ?? {}) as Map<String, dynamic>;
      final loc =
          ((r['geometry'] ?? {})['location'] ?? {}) as Map<String, dynamic>;
      final lat = (loc['lat'] as num?)?.toDouble();
      final lng = (loc['lng'] as num?)?.toDouble();
      final name = (r['name'] ?? '').toString();
      return PickedPlace(
        placeId: placeId,
        mainText: name.isEmpty ? (fallbackDesc ?? '') : name,
        secondaryText: '',
        formattedAddress:
            (r['formatted_address'] ?? (fallbackDesc ?? '')).toString(),
        lat: lat,
        lng: lng,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PickedPlace?> _reverseGeocode(double lat, double lng) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng'
      '&language=${Uri.encodeQueryComponent(widget.language)}'
      '&key=${widget.googleApiKey}',
    );
    try {
      final resp = await http.get(uri);
      if (resp.statusCode != 200) return null;
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final status = (data['status'] ?? '').toString();
      if (status != 'OK' || (data['results'] as List?)?.isEmpty != false) {
        return null;
      }
      final first = (data['results'] as List).first as Map<String, dynamic>;
      final formatted = (first['formatted_address'] ?? '').toString();
      return PickedPlace(
        placeId: (first['place_id'] ?? '').toString(),
        mainText: formatted,
        secondaryText: '',
        formattedAddress: formatted,
        lat: lat,
        lng: lng,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _onPick(_PlacePrediction p) async {
    final details =
        await _fetchDetailsById(p.placeId, fallbackDesc: p.description);
    if (details == null) return;

    if (_editingPickup) {
      _pickup = details;
      _pickupCtrl.text = details.mainText;
      _destFocus.requestFocus();
      setState(() => _editingPickup = false);
    } else {
      _destination = details;
      _destCtrl.text = details.mainText;
      setState(() {});
    }
  }

  bool get _canConfirm => _pickup != null && _destination != null;

  Future<void> _confirm() async {
    final result =
        AddressPickerResult(pickup: _pickup!, destination: _destination!)
            .toMap();
    if (widget.onConfirm != null) {
      await widget.onConfirm!(result);
    }
    if (context.mounted) {
      Navigator.of(context).maybePop(result);
    }
  }

  // ---------------- Nearby ----------------
  void _maybeLoadNearby() {
    if (_hasUserLL) _loadNearby();
  }

  void _ensureSuggestionsEvenIfEmpty() {
    final q = (_editingPickup ? _pickupCtrl.text : _destCtrl.text).trim();
    if (q.isEmpty) {
      setState(() {
        _predictions = [];
        _error = null;
      });
      if (_hasUserLL) _loadNearby(); // garante nearby ao focar sem digitar
    } else {
      _kickSearch();
    }
  }

  Future<void> _loadNearby() async {
    if (_loadingNearby || !_hasUserLL) return;

    setState(() {
      _loadingNearby = true;
      _nearbyError = null;
    });

    final lat = _uLat!;
    final lng = _uLng!;
    final keyword =
        'supermarket grocery restaurant mall museum stadium park landmark pharmacy bank university hospital bakery cafe bar resort hotel';

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=3500'
      '&keyword=${Uri.encodeQueryComponent(keyword)}'
      '&language=${Uri.encodeQueryComponent(widget.language)}'
      '&key=${widget.googleApiKey}',
    );

    try {
      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        setState(() {
          _loadingNearby = false;
          _nearbyError = 'Failed (${resp.statusCode})';
          _nearby = [];
        });
        return;
      }
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final status = (data['status'] ?? '').toString();
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        setState(() {
          _loadingNearby = false;
          _nearbyError = 'Error: $status';
          _nearby = [];
        });
        return;
      }
      final results = (data['results'] as List?) ?? [];
      final parsed = results.map((e) {
        final m = e as Map<String, dynamic>;
        return _NearbyPlace(
          placeId: (m['place_id'] ?? '').toString(),
          name: (m['name'] ?? '').toString(),
          vicinity: (m['vicinity'] ?? '').toString(),
        );
      }).toList();

      setState(() {
        _loadingNearby = false;
        _nearby = parsed.take(24).toList();
        _nearbyError = null;
      });
    } catch (_) {
      setState(() {
        _loadingNearby = false;
        _nearbyError = 'Network error';
        _nearby = [];
      });
    }
  }

  Future<void> _onPickNearby(_NearbyPlace n) async {
    final details = await _fetchDetailsById(n.placeId, fallbackDesc: n.name);
    if (details == null) return;

    // ---------------- NOVA LÓGICA ----------------
    // Antes de digitar/falar (sem foco), os chips devem preencher o DESTINO.
    final noFieldFocused = !_pickupFocus.hasFocus && !_destFocus.hasFocus;

    // useDest = (sem foco E preferimos destino) OU (usuário já está no destino)
    final bool useDest =
        (noFieldFocused && widget.quickPicksDefaultToDestination) ||
            !_editingPickup;

    if (useDest) {
      _destination = details;
      _destCtrl.text = details.mainText;
      setState(() {});
    } else {
      // Caso o usuário tenha focado explicitamente o Pickup, respeitamos.
      _pickup = details;
      _pickupCtrl.text = details.mainText;
      _destFocus.requestFocus();
      setState(() => _editingPickup = false);
    }
  }

  // ---------------- Voice (Destination) ----------------
  Future<void> _toggleVoiceDestination() async {
    if (!_speechReady) return;
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      listenMode: stt.ListenMode.dictation,
      onResult: (res) {
        final text = res.recognizedWords.trim();
        _destCtrl.text = text; // sempre mostra o texto NO CAMPO
        setState(() {});
        if (text.isNotEmpty) {
          _editingPickup = false;
          _kickSearch(); // puxa sugestões com bias no user
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? double.infinity;
    final h = widget.height ?? double.infinity;

    return Container(
      width: w,
      height: h,
      color: const Color(0xFF0E0E0E),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        child: Column(
          children: [
            // handle
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),

            // Inputs
            _InputsCard(
              pickupCtrl: _pickupCtrl,
              destCtrl: _destCtrl,
              onPickupChanged: (_) {
                setState(() {
                  _editingPickup = true;
                  _pickup = null;
                });
                _kickSearch();
              },
              onDestChanged: (_) {
                setState(() {
                  _editingPickup = false;
                  _destination = null;
                });
                _kickSearch();
              },
              pickupFocus: _pickupFocus,
              destFocus: _destFocus,
              editingPickup: _editingPickup,
              showUseMyLocation: _hasUserLL,
              onUseMyLocation: () async {
                if (_hasUserLL) {
                  final p = await _reverseGeocode(_uLat!, _uLng!);
                  if (p != null) {
                    _pickup = p;
                    _pickupCtrl.text = p.formattedAddress;
                    setState(() {});
                  }
                }
              },
              // Botão de VOZ por TOQUE (fica sempre visível)
              voiceTrailing: _VoiceTapButton(
                isListening: _isListening,
                enabled: _speechReady && FFAppState().voiceRequestEnabled,
                onTap: _toggleVoiceDestination,
              ),
            ),

            const SizedBox(height: 10),

            // Quick picks (chips) — aparecem ANTES de digitar/falar
            if (_hasUserLL)
              _QuickPicks(
                nearby: _nearby,
                loading: _loadingNearby,
                error: _nearbyError,
                onTap: _onPickNearby,
              ),

            const SizedBox(height: 8),

            // Lista (Autocomplete ou Nearby)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildContentArea(),
              ),
            ),

            const SizedBox(height: 10),

            // Confirm
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _canConfirm ? _confirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canConfirm
                      ? const Color(0xFFFFA000)
                      : const Color(0xFF3A3A3A),
                  disabledBackgroundColor: const Color(0xFF3A3A3A),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.confirmText,
                  style: TextStyle(
                    color: _canConfirm ? Colors.black : const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    final query = (_editingPickup ? _pickupCtrl.text : _destCtrl.text).trim();
    final anyFocused = _pickupFocus.hasFocus || _destFocus.hasFocus;

    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_error != null) {
      return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.white70)));
    }

    // Autocomplete quando tem texto
    if (anyFocused && query.isNotEmpty) {
      if (_predictions.isEmpty) return const SizedBox.shrink();
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _predictions.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
        itemBuilder: (ctx, i) {
          final p = _predictions[i];
          return _PlaceTile(p: p, onTap: () => _onPick(p));
        },
      );
    }

    // Nearby quando vazio (focado ou não) -> SEM texto de placeholder
    if (_hasUserLL) {
      if (_loadingNearby) {
        return const Center(
          child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }
      if (_nearby.isEmpty) return const SizedBox.shrink();
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _nearby.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
        itemBuilder: (ctx, i) {
          final n = _nearby[i];
          return _NearbyTile(n: n, onTap: () => _onPickNearby(n));
        },
      );
    }

    // Sem coords -> não mostra nada
    return const SizedBox.shrink();
  }
}

/// -------------------- UI pieces --------------------

class _VoiceTapButton extends StatelessWidget {
  const _VoiceTapButton({
    required this.isListening,
    required this.enabled,
    required this.onTap,
  });

  final bool isListening;
  final bool enabled;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? const Color(0xFF5A5A5A)
        : (isListening ? const Color(0xFFFF4D4D) : const Color(0xFFFFC107));
    final label = !enabled
        ? 'Voice unavailable'
        : (isListening ? 'Listening… tap to stop' : 'Tap to speak');

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Icon(Icons.mic, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _QuickPicks extends StatelessWidget {
  const _QuickPicks({
    required this.nearby,
    required this.loading,
    required this.error,
    required this.onTap,
  });

  final List<_NearbyPlace> nearby;
  final bool loading;
  final String? error;
  final void Function(_NearbyPlace n) onTap;

  @override
  Widget build(BuildContext context) {
    if (loading || error != null || nearby.isEmpty) {
      return const SizedBox.shrink();
    }
    final picks = nearby.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Quick picks near you',
              style: TextStyle(color: Colors.white70, fontSize: 12.5)),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final n in picks)
              GestureDetector(
                onTap: () => onTap(n),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Text(
                    n.name, // ex.: "Padaria Bla bla", "Supermarket Foo"
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _InputsCard extends StatelessWidget {
  const _InputsCard({
    required this.pickupCtrl,
    required this.destCtrl,
    required this.onPickupChanged,
    required this.onDestChanged,
    required this.pickupFocus,
    required this.destFocus,
    required this.editingPickup,
    this.showUseMyLocation = false,
    this.onUseMyLocation,
    this.voiceTrailing,
  });

  final TextEditingController pickupCtrl;
  final TextEditingController destCtrl;
  final ValueChanged<String> onPickupChanged;
  final ValueChanged<String> onDestChanged;
  final FocusNode pickupFocus;
  final FocusNode destFocus;
  final bool editingPickup;

  final bool showUseMyLocation;
  final VoidCallback? onUseMyLocation;

  final Widget? voiceTrailing; // botão de voz (sempre visível)

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _InputRow(
            icon: Icons.location_pin,
            iconColor: Colors.white,
            controller: pickupCtrl,
            placeholder: 'Search place or address',
            helperBelow: 'Pickup',
            onChanged: onPickupChanged,
            focusNode: pickupFocus,
            isActive: editingPickup,
            trailing: showUseMyLocation
                ? TextButton.icon(
                    onPressed: onUseMyLocation,
                    icon: const Icon(Icons.my_location,
                        size: 16, color: Color(0xFFFFC107)),
                    label: const Text('Use my location',
                        style:
                            TextStyle(color: Color(0xFFFFC107), fontSize: 12)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          _InputRow(
            icon: Icons.local_taxi,
            iconColor: const Color(0xFFFFC107),
            controller: destCtrl,
            placeholder: '', // sem placeholder no destino
            helperBelow: 'Destination', // label abaixo
            onChanged: onDestChanged,
            focusNode: destFocus,
            isActive: !editingPickup,
            trailing: voiceTrailing, // mic sempre visível
          ),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.icon,
    required this.iconColor,
    required this.controller,
    required this.placeholder,
    required this.helperBelow,
    required this.onChanged,
    required this.focusNode,
    required this.isActive,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;
  final String placeholder;
  final String helperBelow; // label abaixo
  final ValueChanged<String> onChanged;
  final FocusNode focusNode;
  final bool isActive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final fill = isActive ? const Color(0xFF1B1B1B) : const Color(0xFF161616);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: fill,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  cursorColor: const Color(0xFFFFC107),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: placeholder,
                    hintStyle: const TextStyle(color: Color(0xFF7A7A7A)),
                  ),
                ),
              ),
              // Clear (se houver texto)
              if (controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                    focusNode.requestFocus();
                  },
                  child: const Icon(Icons.close,
                      size: 18, color: Color(0xFF7A7A7A)),
                ),
              // Mic SEMPRE visível se fornecido
              if (trailing != null) ...[
                const SizedBox(width: 6),
                trailing!,
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(helperBelow,
            style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
      ],
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.p, required this.onTap});
  final _PlacePrediction p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF232323),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.place, color: Colors.white70, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.mainText.isEmpty ? '[\$.mainText]' : p.mainText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.secondaryText.isEmpty ? '' : p.secondaryText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyTile extends StatelessWidget {
  const _NearbyTile({required this.n, required this.onTap});
  final _NearbyPlace n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF232323),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.star, color: Colors.white70, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.vicinity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- Models --------------------
class _PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;
  _PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
  });
}

class _NearbyPlace {
  final String placeId;
  final String name;
  final String vicinity;
  _NearbyPlace({
    required this.placeId,
    required this.name,
    required this.vicinity,
  });
}

class PickedPlace {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String formattedAddress;
  final double? lat;
  final double? lng;
  const PickedPlace({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toMap() => {
        'placeId': placeId,
        'mainText': mainText,
        'secondaryText': secondaryText,
        'formattedAddress': formattedAddress,
        'lat': lat,
        'lng': lng,
      };
}

/// Flat result
class AddressPickerResult {
  final PickedPlace pickup;
  final PickedPlace destination;
  const AddressPickerResult({required this.pickup, required this.destination});

  Map<String, dynamic> toMap() => {
        "pickupMainText": pickup.mainText,
        "pickupFormattedAddress": pickup.formattedAddress,
        "pickupLat": pickup.lat,
        "pickupLng": pickup.lng,
        "destinationMainText": destination.mainText,
        "destinationFormattedAddress": destination.formattedAddress,
        "destinationLat": destination.lat,
        "destinationLng": destination.lng,
      };
}
