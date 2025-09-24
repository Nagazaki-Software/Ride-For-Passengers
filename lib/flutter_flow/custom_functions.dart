import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/auth/firebase_auth/auth_util.dart';

List<String> nationalityList() {
  // all nationality list
  return [
    'Afghan',
    'Albanian',
    'Algerian',
    'American',
    'Andorran',
    'Angolan',
    'Antiguans',
    'Argentine',
    'Armenian',
    'Australian',
    'Austrian',
    'Azerbaijani',
    'Bahamian',
    'Bahraini',
    'Bangladeshi',
    'Barbadian',
    'Barber',
    'Belarusian',
    'Belgian',
    'Belizean',
    'Beninese',
    'Bhutanese',
    'Bolivian',
    'Bosnian',
    'Brazilian',
    'British',
    'Bruneian',
    'Bulgarian',
    'Burkinabe',
    'Burmese',
    'Burundian',
    'Cabo Verdean',
    'Cambodian',
    'Cameroonian',
    'Canadian',
    'Central African',
    'Chadian',
    'Chilean',
    'Chinese',
    'Colombian',
    'Comoran',
    'Congolese',
    'Costa Rican',
    'Croatian',
    'Cuban',
    'Cypriot',
    'Czech',
    'Danish',
    'Djiboutian',
    'Dominican',
    'Dutch',
    'Ecuadorian',
    'Egyptian',
    'Salvadoran',
    'Equatorial Guinean',
    'Eritrean',
    'Estonian',
    'Eswatini',
    'Ethiopian',
    'Fijian',
    'Finnish',
    'French',
    'Gabonese',
    'Gambian',
    'Georgian',
    'German',
    'Ghanaian',
    'Greek',
    'Grenadian',
    'Guatemalan',
    'Guinean',
    'Guyanese',
    'Haitian',
    'Honduran',
    'Hungarian',
    'Icelandic',
    'Indian',
    'Indonesian',
    'Iranian',
    'Iraqi',
    'Irish',
    'Israeli',
    'Italian',
    'Jamaican',
    'Japanese',
    'Jordanian',
    'Kazakhstani',
    'Kenyan',
    'Kiribati',
    'Kuwaiti',
    'Kyrgyz',
    'Laotian',
    'Latvian',
    'Lebanese',
    'Lesotho',
    'Liberian',
    'Libyan',
    'Liechtenstein',
    'Lithuanian',
    'Luxembourgish',
    'Malagasy',
    'Malawian',
    'Malaysian',
    'Maldivian',
    'Malian',
    'Maltese',
    'Marshallese',
    'Mauritanian',
    'Mauritian',
    'Mexican',
    'Micronesian',
    'Moldovan',
    'Monacan',
    'Mongolian',
    'Montenegrin',
    'Moroccan',
    'Mozambican',
    'Namibian',
    'Nauruan',
    'Nepalese',
    'Dutch',
    'New Zealander',
    'Nicaraguan',
    'Nigerien',
    'Nigerian',
    'North Korean',
    'Norwegian',
    'Omani',
    'Pakistani',
    'Palauan',
    'Palestinian',
    'Panamanian',
    'Papua New Guinean',
    'Paraguayan',
    'Peruvian',
    'Philippine',
    'Polish',
    'Portuguese',
    'Qatari',
    'Romanian',
    'Russian',
    'Rwandan',
    'Saint Lucian',
    'Saint Vincentian',
    'Samoan',
    'San Marinese',
    'Sao Tomean',
    'Saudi',
    'Scottish',
    'Senegalese',
    'Serbian',
    'Seychellois',
    'Sierra Leonean',
    'Singaporean',
    'Slovak',
    'Slovenian',
    'Solomon Islander',
    'Somali',
    'South African',
    'South Korean',
    'Spanish',
    'Sri Lankan',
    'Sudanese',
    'Surinamese',
    'Swedish',
    'Swiss',
    'Syrian',
    'Taiwanese',
    'Tajik',
    'Tanzanian',
    'Thai',
    'Togolese',
    'Tongan',
    'Trinidadian',
    'Tunisian',
    'Turkish',
    'Turkmen',
    'Tuvaluan',
    'Ugandan',
  ];
}

List<String> stateUsList() {
  // all state us
  return [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming',
  ];
}

String partesDoName(String name) {
  // se o nome do usuario for com uma palavra retorne as 2 primeiras letras se for composto os 2 primeiros do composto
  List<String> nameParts = name.split(' ');
  if (nameParts.length == 1) {
    return nameParts[0].substring(0, 2);
  } else {
    return nameParts[0].substring(0, 2) + nameParts[1].substring(0, 2);
  }
}

LatLng formatStringToLantLng(
  String lat,
  String lng,
) {
  // format string to latlng
  return LatLng(double.parse(lat), double.parse(lng));
}

String latlngForKm(
  LatLng latlngAtual,
  LatLng latlngWhereTo,
) {
  // 1) Curto-circuito: se for o mesmo ponto, zero.
  if (latlngAtual.latitude == latlngWhereTo.latitude &&
      latlngAtual.longitude == latlngWhereTo.longitude) {
    return '0 m';
  }

  // 2) Raio médio da Terra (km)
  const double earthRadiusKm = 6371.0;

  // 3) Utilitários
  double _degToRad(double deg) => deg * (math.pi / 180.0);

  // 4) Diferenças em radianos
  final double dLat = _degToRad(latlngWhereTo.latitude - latlngAtual.latitude);
  final double dLng =
      _degToRad(latlngWhereTo.longitude - latlngAtual.longitude);

  // 5) Latitude em radianos
  final double lat1 = _degToRad(latlngAtual.latitude);
  final double lat2 = _degToRad(latlngWhereTo.latitude);

  // 6) Haversine
  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);

  // Proteção contra possíveis problemas numéricos
  final double aClamped = a.clamp(0.0, 1.0);
  final double c = 2 * math.atan2(math.sqrt(aClamped), math.sqrt(1 - aClamped));

  // 7) Distância em km
  final double distanceKm = earthRadiusKm * c;

  // 8) Tratamento de NaN/∞
  if (distanceKm.isNaN || distanceKm.isInfinite) {
    // Se chegou aqui, tem algo estranho nas coordenadas.
    // Retorne algo seguro e logue se quiser.
    return '0 m';
  }

  // 9) Formatação amigável
  if (distanceKm < 1.0) {
    final int meters = (distanceKm * 1000).round();
    return '$meters m';
  } else {
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}

int quantasRidesNesteMes(
  List<RideOrdersRecord> rides,
  DateTime diaAtual,
) {
  // retorne quantas rides no mes baseado em rides.dia
  int count = 0;
  for (var ride in rides) {
    if (ride.hasDia() &&
        ride.dia!.year == diaAtual.year &&
        ride.dia!.month == diaAtual.month) {
      count++;
    }
  }
  return count;
}

double progressBarRidePoints(int ridePoints) {
  // Defina os limites para cada fase
  const int bronzeLimit = 10000;
  const int silverLimit = 20000;
  const int goldLimit = 30000;

  // Cálculo progressivo para cada fase
  if (ridePoints <= bronzeLimit) {
    return ridePoints / bronzeLimit; // Bronze
  } else if (ridePoints <= silverLimit) {
    return (ridePoints - bronzeLimit) / (silverLimit - bronzeLimit); // Silver
  } else if (ridePoints <= goldLimit) {
    return (ridePoints - silverLimit) / (goldLimit - silverLimit); // Gold
  } else {
    return 1.0; // Após Platinum, o progresso chega a 1
  }
}

LatLng? stringToLatlng(String txt) {
  // string to latlng if txt no latlng return null
  final regex = RegExp(r'([-+]?[0-9]*\.?[0-9]+),\s*([-+]?[0-9]*\.?[0-9]+)');
  final match = regex.firstMatch(txt);
  if (match != null) {
    final latitude = double.tryParse(match.group(1)!);
    final longitude = double.tryParse(match.group(2)!);
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }
  }
  return null;
}

String esconderCreditCard(String creditCard) {
  // 1) Mantém só os dígitos (remove espaços, traços, etc.)
  final onlyDigits = creditCard.replaceAll(RegExp(r'\D'), '');

  // 2) Se não sobrou nada, retorna só a máscara
  if (onlyDigits.isEmpty) return '****';

  // 3) Pega os últimos até 4 dígitos (se tiver menos de 4, mostra o que tiver)
  final end = onlyDigits.length;
  final start = math.max(0, end - 4);
  final last4 = onlyDigits.substring(start, end);

  // 4) Formato final: **** 1234
  return '**** $last4';
}

double mediaCorridaNesseKm(
  LatLng laltngOrigem,
  LatLng latlngDestino,
  List<RideOrdersRecord> order,
) {
  // ===== Parâmetros de cálculo =====
  const double toleranciaRelativa =
      0.20; // ±20% do alvo p/ considerar "semelhante"
  const double minDistFiltroKm =
      0.05; // evita dividir por ~zero ao ler histórico
  const double minCobrancaKm = 1.0; // distância mínima cobrada (garante > 0)
  const double pi180 = math.pi / 180.0;

  // Fallback GLOBAL (mesma moeda de rideValue)
  // Ajuste estes números p/ sua cidade/app:
  const double basePadrao = 5.0; // tarifa base
  const double ppkPadrao = 3.5; // preço por km

  // --- Haversine inline ---
  double haversineKm(LatLng a, LatLng b) {
    final dLat = (b.latitude - a.latitude) * pi180;
    final dLon = (b.longitude - a.longitude) * pi180;
    final la1 = a.latitude * pi180;
    final la2 = b.latitude * pi180;
    final hav = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 6371.0 * 2 * math.atan2(math.sqrt(hav), math.sqrt(1 - hav));
  }

  // Distância solicitada e "km cobrados" (nunca menor que minCobrancaKm)
  final double alvoKm = haversineKm(laltngOrigem, latlngDestino);
  final double kmCobrados = math.max(alvoKm, minCobrancaKm);

  // Coleta de PPKs do histórico
  final List<double> ppkTodas = <double>[];
  final List<double> ppkSemelhantes = <double>[];

  for (final o in order) {
    final LatLng? origem = o.latlngAtual;
    final LatLng? destino = o.latlng;
    final num? valorNum = o.rideValue; // pode vir int/double do Firestore
    if (origem == null || destino == null || valorNum == null) continue;

    final double valor = valorNum.toDouble();
    if (valor <= 0) continue;

    final double distKm = haversineKm(origem, destino);
    if (distKm < minDistFiltroKm) continue;

    final double ppk = valor / distKm;
    if (ppk.isFinite && ppk > 0) {
      ppkTodas.add(ppk);

      final double delta = (distKm - alvoKm).abs();
      if (alvoKm == 0) {
        // Se o alvo é 0 (mesmo lugar), use a janela em torno de minCobrancaKm
        if ((distKm - minCobrancaKm).abs() <=
            minCobrancaKm * toleranciaRelativa) {
          ppkSemelhantes.add(ppk);
        }
      } else if (delta <= alvoKm * toleranciaRelativa) {
        ppkSemelhantes.add(ppk);
      }
    }
  }

  // Estatísticas robustas
  double media(List<double> xs) =>
      xs.isEmpty ? 0.0 : xs.reduce((a, b) => a + b) / xs.length;

  double mediana(List<double> xs) {
    if (xs.isEmpty) return 0.0;
    final s = [...xs]..sort();
    final m = s.length ~/ 2;
    return s.length.isOdd ? s[m] : (s[m - 1] + s[m]) / 2.0;
    // (Mediana é menos sensível a outliers do que a média)
  }

  // Preferir mediana das semelhantes; senão, mediana geral; senão, média geral
  final double ppkSemMed = mediana(ppkSemelhantes);
  final double ppkGeralMed = mediana(ppkTodas);
  final double ppkGeralAvg = media(ppkTodas);

  final double ppkHist = (ppkSemMed > 0.0)
      ? ppkSemMed
      : (ppkGeralMed > 0.0 ? ppkGeralMed : ppkGeralAvg);

  if (ppkHist > 0.0) {
    return ppkHist * kmCobrados;
  }

  // Sem histórico útil? Cai no fallback GLOBAL (nunca 0.0)
  return basePadrao + ppkPadrao * kmCobrados;
}

String minCar(
  List<UsersRecord> drivers,
  LatLng userLocation,
) {
  // Velocidade média urbana (ajuste conforme sua cidade)
  const double avgSpeedKmh = 30.0;

  // Helpers locais
  double _deg2rad(double deg) => deg * (math.pi / 180.0);

  // Distância Haversine em km
  double _haversineKm(LatLng a, LatLng b) {
    const double R = 6371.0;
    final double dLat = _deg2rad(b.latitude - a.latitude);
    final double dLon = _deg2rad(b.longitude - a.longitude);
    final double lat1 = _deg2rad(a.latitude);
    final double lat2 = _deg2rad(b.latitude);

    final double h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(h), math.sqrt(1.0 - h));
    return R * c;
  }

  // Lista vazia? Sem como estimar
  if (drivers.isEmpty) return '—';

  // Encontra a menor distância válida até um motorista
  double? closestKm;
  for (final d in drivers) {
    final dLoc = d.location; // UsersRecord.location deve ser LatLng
    if (dLoc == null) continue;
    final km = _haversineKm(userLocation, dLoc);
    if (closestKm == null || km < closestKm) closestKm = km;
  }

  // Ninguém com localização válida
  if (closestKm == null) return '—';

  // Estimativa de minutos
  final double rawMinutes = (closestKm / avgSpeedKmh) * 60.0;

  // Formatação amigável
  if (rawMinutes > 120.0) return '120+ min';
  final int minutes = rawMinutes.ceil().clamp(1, 120);
  return '$minutes min';
}

List<String> nassauList() {
  const east = <String>[
    'Blair Estates',
    'Eastern Road',
    'Sans Souci',
    'Winton Heights',
    'Winton Meadows',
    'Elizabeth Estates',
    'Seabreeze Estates',
    'Gleniston Gardens',
    'Johnson Road Estates',
    'Fox Hill',
    'Nassau Village',
    'Yamacraw',
    'Yamacraw Beach Estates',
    'Port New Providence',
    'Palm Cay',
    'Treasure Cove',
    'Montagu Area',
    'High Vista',
    'Little Blair',
    'Village Road Area',
  ];

  const middle = <String>[
    'Downtown Nassau',
    'Centreville',
    'Fort Fincastle/Queen’s Staircase',
    'Fort Charlotte/Chippingham',
    'Palmdale',
    'Oakes Field',
    'Big Pond Subdivision',
    'Englerston',
    'Bain Town',
    'Grants Town',
    'St. Barnabas',
    'Mason’s Addition',
    'East Street Corridor',
    'Wulff Road Corridor',
    'Shirley Street Area',
  ];

  const west = <String>[
    'Cable Beach',
    'Delaporte Point',
    'Sandyport',
    'Sea Beach Estates',
    'Highland Park',
    'Skyline Drive',
    'Westridge',
    'South Westridge',
    'Balmoral',
    'Prospect Ridge',
    'Old Fort Bay',
    'Lyford Cay',
    'Albany',
    'Mount Pleasant Village',
    'Venetian West',
    'West Winds',
    'Serenity',
    'Charlotteville',
    'Turnberry',
    'Tropical Gardens',
    'Gambier',
    'Love Beach',
    'Adelaide Village',
    'Coral Harbour',
    'South Ocean Estates',
    'Coral Heights',
  ];

  // Lista única sem prefixos (boa pra Dropdown, Chips, etc.)
  return <String>[
    ...east,
    ...middle,
    ...west,
  ];
}

String estimativeTime(
  LatLng latlngOrigem,
  LatLng latlngDestino,
) {
  // Velocidade média assumida (km/h). Ajuste conforme seu caso de uso.
  const double averageSpeedKmh = 40.0;

  // Se coordenadas iguais, tempo zero.
  if (latlngOrigem.latitude == latlngDestino.latitude &&
      latlngOrigem.longitude == latlngDestino.longitude) {
    return '0 minutes';
  }

  // --- Haversine para distância em km ---
  double _degToRad(double deg) => deg * (math.pi / 180.0);
  const double earthRadiusKm = 6371.0;

  final double dLat = _degToRad(latlngDestino.latitude - latlngOrigem.latitude);
  final double dLon =
      _degToRad(latlngDestino.longitude - latlngOrigem.longitude);

  final double lat1 = _degToRad(latlngOrigem.latitude);
  final double lat2 = _degToRad(latlngDestino.latitude);

  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  final double distanceKm = earthRadiusKm * c;

  // --- Tempo estimado ---
  // horas = km / (km/h)
  final double hours = distanceKm / averageSpeedKmh;

  // Arredonda para cima para evitar "0 minutes" quando há deslocamento.
  int totalMinutes = (hours * 60).ceil();

  // Segurança: nunca negativo.
  if (totalMinutes < 0) totalMinutes = 0;

  // Formatação em inglês: "x minutes" ou "x hour(s) y minute(s)"
  if (totalMinutes < 60) {
    final unit = totalMinutes == 1 ? 'minute' : 'minutes';
    return '$totalMinutes $unit';
  } else {
    final int h = totalMinutes ~/ 60;
    final int m = totalMinutes % 60;
    final String hUnit = h == 1 ? 'hour' : 'hours';
    if (m == 0) {
      return '$h $hUnit';
    } else {
      final String mUnit = m == 1 ? 'minute' : 'minutes';
      return '$h $hUnit $m $mUnit';
    }
  }
}

double gastosMensal(
  List<RideOrdersRecord> orders,
  DateTime atualDay,
) {
  if (orders.isEmpty) return 0.0;

  double total = 0.0;
  final int targetYear = atualDay.year;
  final int targetMonth = atualDay.month;

  for (final o in orders) {
    final DateTime? dia = o.dia; // data do pedido
    final double? valor = o.rideValue; // valor do pedido
    if (dia == null || valor == null) continue;

    // soma somente pedidos do mesmo mês/ano de atualDay
    if (dia.year == targetYear && dia.month == targetMonth) {
      total += valor;
    }
  }

  // Se quiser arredondar para 2 casas, descomente a linha abaixo:
  // total = (total * 100).roundToDouble() / 100.0;

  return total;
}
