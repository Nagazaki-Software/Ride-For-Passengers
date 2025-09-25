// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '/flutter_flow/lat_lng.dart';

/// Reverse geocode robusto:
/// - language: pt-BR
/// - filtra por street_address/route
/// - monta "Rua X, Bairro – Cidade/UF"
/// - logs úteis para 403/REQUEST_DENIED
Future<String> latlngToString(
  LatLng latlng,
  String apiKey,
) async {
  String _coordsFallback() =>
      '${latlng.latitude.toStringAsFixed(6)}, ${latlng.longitude.toStringAsFixed(6)}';

  try {
    final key = (apiKey).trim(); // String já é non-nullable no FF
    if (key.isEmpty) return _coordsFallback();

    // Primeiro, tenta identificar um lugar importante próximo e retornar o nome
    try {
      final nearbyUri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/nearbysearch/json',
        {
          'location': '${latlng.latitude},${latlng.longitude}',
          'radius': '120', // raio curto para captar o local exato
          'language': 'en-US',
          'key': key,
        },
      );

      final nearbyResp =
          await http.get(nearbyUri).timeout(const Duration(seconds: 8));
      if (nearbyResp.statusCode == 200) {
        final nearby = json.decode(nearbyResp.body) as Map<String, dynamic>;
        final status = (nearby['status'] ?? '').toString();
        if (status == 'OK') {
          final results = (nearby['results'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              const [];

          const important = <String>{
            'airport',
            'hospital',
            'police',
            'fire_station',
            'pharmacy',
            'supermarket',
            'shopping_mall',
            'bank',
            'atm',
            'train_station',
            'subway_station',
            'bus_station',
            'university',
            'school',
            'museum',
            'tourist_attraction',
            'park',
            'stadium',
            'city_hall',
            'embassy',
          };

          double distanceMeters(
            double lat1,
            double lon1,
            double lat2,
            double lon2,
          ) {
            const R = 6371000.0;
            final dLat = (lat2 - lat1) * math.pi / 180.0;
            final dLon = (lon2 - lon1) * math.pi / 180.0;
            final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
                math.cos(lat1 * math.pi / 180.0) *
                    math.cos(lat2 * math.pi / 180.0) *
                    math.sin(dLon / 2) *
                    math.sin(dLon / 2);
            final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
            return R * c;
          }

          Map<String, dynamic>? pick;
          double best = double.infinity;
          for (final m in results) {
            final types =
                ((m['types'] as List?)?.map((e) => e.toString()).toList()) ??
                    const <String>[];
            final isImportant = types.any(important.contains);
            if (!isImportant) continue;

            final loc =
                (((m['geometry'] ?? {}) as Map)['location'] ?? {})
                    as Map<String, dynamic>;
            final pLat = (loc['lat'] is num) ? (loc['lat'] as num).toDouble() : null;
            final pLng = (loc['lng'] is num) ? (loc['lng'] as num).toDouble() : null;
            if (pLat == null || pLng == null) continue;

            final d = distanceMeters(
              latlng.latitude,
              latlng.longitude,
              pLat,
              pLng,
            );
            if (d < best) {
              best = d;
              pick = m;
            }
          }

          if (pick != null) {
            final name = (pick['name'] ?? '').toString().trim();
            if (name.isNotEmpty) {
              return name; // Preferir o nome do local importante
            }
          }
        }
      }
    } catch (_) {
      // Ignora e segue para o geocode normal
    }

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=${latlng.latitude},${latlng.longitude}'
      '&language=en-US'
      '&key=$key',
    );

    // timeout pra evitar “nada acontece feijoada”
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));

    // Logs leves para depurar (apenas no debug)
    // ignore: avoid_print
    print('[latlngToString] HTTP ${resp.statusCode}');

    if (resp.statusCode == 403) {
      // ignore: avoid_print
      print(
          '[latlngToString] 403: verifique Billing e API restrictions (habilite Geocoding API para esta key). Body=${resp.body}');
      return _coordsFallback();
    }
    if (resp.statusCode != 200) return _coordsFallback();

    final data = json.decode(resp.body) as Map<String, dynamic>;
    final status = (data['status'] ?? '').toString();

    if (status == 'REQUEST_DENIED' || status == 'OVER_DAILY_LIMIT') {
      // ignore: avoid_print
      print(
          '[latlngToString] $status: confira faturamento e permissões da key. Body=${resp.body}');
      return _coordsFallback();
    }
    if (status != 'OK') {
      // ignore: avoid_print
      print('[latlngToString] status=$status (sem endereço).');
      return _coordsFallback();
    }

    final results = (data['results'] as List?) ?? const [];
    if (results.isEmpty) return _coordsFallback();

    // 1) tenta um resultado com tipo "street_address" ou "route"
    Map<String, dynamic>? best =
        results.cast<Map<String, dynamic>?>().firstWhere(
      (r) {
        final types = (r?['types'] as List?)?.cast<String>() ?? const [];
        return types.contains('street_address') || types.contains('route');
      },
      orElse: () => null,
    );

    // 2) se não achou, pega o primeiro mesmo
    best ??= results.first as Map<String, dynamic>;

    // Tenta formatted_address direto
    final formatted = best['formatted_address']?.toString();
    if (formatted != null && formatted.trim().isNotEmpty) {
      return formatted.trim();
    }

    // Monta manualmente: Rua, Bairro – Cidade/UF
    String? route,
        neighborhood,
        sublocality,
        locality,
        admin1Short; // UF/estado (short)

    final comps =
        (best['address_components'] as List?)?.cast<Map<String, dynamic>>() ??
            const [];

    String? _get(List<String> wanted, {bool short = false}) {
      for (final c in comps) {
        final types = (c['types'] as List?)?.cast<String>() ?? const [];
        if (types.any(wanted.contains)) {
          return short
              ? (c['short_name']?.toString())
              : (c['long_name']?.toString());
        }
      }
      return null;
    }

    route = _get(['route']);
    neighborhood = _get(['neighborhood']);
    sublocality = _get(['sublocality', 'sublocality_level_1']);
    locality = _get(['locality', 'postal_town']);
    admin1Short = _get(['administrative_area_level_1'], short: true);

    final bairro = (neighborhood ?? sublocality);
    final partes = <String>[];
    if (route != null && route!.trim().isNotEmpty) partes.add(route!.trim());
    if (bairro != null && bairro!.trim().isNotEmpty) partes.add(bairro!.trim());

    final cidadeUf = [
      if (locality != null && locality!.trim().isNotEmpty) locality!.trim(),
      if (admin1Short != null && admin1Short!.trim().isNotEmpty)
        admin1Short!.trim(),
    ].join('/');

    String montado;
    if (partes.isNotEmpty && cidadeUf.isNotEmpty) {
      montado = '${partes.join(', ')} – $cidadeUf';
    } else if (partes.isNotEmpty) {
      montado = partes.join(', ');
    } else if (cidadeUf.isNotEmpty) {
      montado = cidadeUf;
    } else {
      montado = _coordsFallback();
    }

    return montado;
  } catch (e) {
    // ignore: avoid_print
    print('[latlngToString] erro: $e');
    return _coordsFallback();
  }
}
