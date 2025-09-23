import 'package:flutter/material.dart';
import 'flutter_flow/request_manager.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _locationStatus = prefs.getString('ff_locationStatus') ?? _locationStatus;
    });
    _safeInit(() {
      _currentLat = prefs.getDouble('ff_currentLat') ?? _currentLat;
    });
    _safeInit(() {
      _currentLng = prefs.getDouble('ff_currentLng') ?? _currentLng;
    });
    _safeInit(() {
      _locationTimestamp = prefs.containsKey('ff_locationTimestamp')
          ? DateTime.fromMillisecondsSinceEpoch(
              prefs.getInt('ff_locationTimestamp')!)
          : _locationTimestamp;
    });
    _safeInit(() {
      _fraseInicial = prefs.getString('ff_fraseInicial') ?? _fraseInicial;
    });
    _safeInit(() {
      _locationsPorPerto =
          prefs.getStringList('ff_locationsPorPerto') ?? _locationsPorPerto;
    });
    _safeInit(() {
      _cardNumber = prefs.getString('ff_cardNumber') ?? _cardNumber;
    });
    _safeInit(() {
      _cardExpiry = prefs.getString('ff_cardExpiry') ?? _cardExpiry;
    });
    _safeInit(() {
      _cardCvv = prefs.getString('ff_cardCvv') ?? _cardCvv;
    });
    _safeInit(() {
      _cardHolder = prefs.getString('ff_cardHolder') ?? _cardHolder;
    });
    _safeInit(() {
      _latlngAtual =
          latLngFromString(prefs.getString('ff_latlngAtual')) ?? _latlngAtual;
    });
    _safeInit(() {
      _passangers = prefs.getInt('ff_passangers') ?? _passangers;
    });
    _safeInit(() {
      _creditCardSalves = prefs.getStringList('ff_creditCardSalves')?.map((x) {
            try {
              return jsonDecode(x);
            } catch (e) {
              print("Can't decode persisted json. Error: $e.");
              return {};
            }
          }).toList() ??
          _creditCardSalves;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_defaultCard')) {
        try {
          _defaultCard = jsonDecode(prefs.getString('ff_defaultCard') ?? '');
        } catch (e) {
          print("Can't decode persisted json. Error: $e.");
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _appVersion = '1.1.56+28';
  String get appVersion => _appVersion;
  set appVersion(String value) {
    _appVersion = value;
  }

  String _locationStatus = 'idle';
  String get locationStatus => _locationStatus;
  set locationStatus(String value) {
    _locationStatus = value;
    prefs.setString('ff_locationStatus', value);
  }

  double _currentLat = 0.0;
  double get currentLat => _currentLat;
  set currentLat(double value) {
    _currentLat = value;
    prefs.setDouble('ff_currentLat', value);
  }

  double _currentLng = 0.0;
  double get currentLng => _currentLng;
  set currentLng(double value) {
    _currentLng = value;
    prefs.setDouble('ff_currentLng', value);
  }

  DateTime? _locationTimestamp =
      DateTime.fromMillisecondsSinceEpoch(1755633600000);
  DateTime? get locationTimestamp => _locationTimestamp;
  set locationTimestamp(DateTime? value) {
    _locationTimestamp = value;
    value != null
        ? prefs.setInt('ff_locationTimestamp', value.millisecondsSinceEpoch)
        : prefs.remove('ff_locationTimestamp');
  }

  String _fraseInicial = 'Welcome to Ride';
  String get fraseInicial => _fraseInicial;
  set fraseInicial(String value) {
    _fraseInicial = value;
    prefs.setString('ff_fraseInicial', value);
  }

  List<String> _locationsPorPerto = [];
  List<String> get locationsPorPerto => _locationsPorPerto;
  set locationsPorPerto(List<String> value) {
    _locationsPorPerto = value;
    prefs.setStringList('ff_locationsPorPerto', value);
  }

  void addToLocationsPorPerto(String value) {
    locationsPorPerto.add(value);
    prefs.setStringList('ff_locationsPorPerto', _locationsPorPerto);
  }

  void removeFromLocationsPorPerto(String value) {
    locationsPorPerto.remove(value);
    prefs.setStringList('ff_locationsPorPerto', _locationsPorPerto);
  }

  void removeAtIndexFromLocationsPorPerto(int index) {
    locationsPorPerto.removeAt(index);
    prefs.setStringList('ff_locationsPorPerto', _locationsPorPerto);
  }

  void updateLocationsPorPertoAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    locationsPorPerto[index] = updateFn(_locationsPorPerto[index]);
    prefs.setStringList('ff_locationsPorPerto', _locationsPorPerto);
  }

  void insertAtIndexInLocationsPorPerto(int index, String value) {
    locationsPorPerto.insert(index, value);
    prefs.setStringList('ff_locationsPorPerto', _locationsPorPerto);
  }

  String _pagesNavBar = 'home';
  String get pagesNavBar => _pagesNavBar;
  set pagesNavBar(String value) {
    _pagesNavBar = value;
  }

  String _cardNumber = '';
  String get cardNumber => _cardNumber;
  set cardNumber(String value) {
    _cardNumber = value;
    prefs.setString('ff_cardNumber', value);
  }

  String _cardExpiry = '';
  String get cardExpiry => _cardExpiry;
  set cardExpiry(String value) {
    _cardExpiry = value;
    prefs.setString('ff_cardExpiry', value);
  }

  String _cardCvv = '';
  String get cardCvv => _cardCvv;
  set cardCvv(String value) {
    _cardCvv = value;
    prefs.setString('ff_cardCvv', value);
  }

  String _cardHolder = '';
  String get cardHolder => _cardHolder;
  set cardHolder(String value) {
    _cardHolder = value;
    prefs.setString('ff_cardHolder', value);
  }

  LatLng? _latlngAtual = LatLng(25.0443312, -77.3503609);
  LatLng? get latlngAtual => _latlngAtual;
  set latlngAtual(LatLng? value) {
    _latlngAtual = value;
    value != null
        ? prefs.setString('ff_latlngAtual', value.serialize())
        : prefs.remove('ff_latlngAtual');
  }

  LatLng? _latlangAondeVaiIr;
  LatLng? get latlangAondeVaiIr => _latlangAondeVaiIr;
  set latlangAondeVaiIr(LatLng? value) {
    _latlangAondeVaiIr = value;
  }

  String _locationAondeEleEsta = '';
  String get locationAondeEleEsta => _locationAondeEleEsta;
  set locationAondeEleEsta(String value) {
    _locationAondeEleEsta = value;
  }

  String _locationWhereTo = 'Where to?';
  String get locationWhereTo => _locationWhereTo;
  set locationWhereTo(String value) {
    _locationWhereTo = value;
  }

  String _listPerto = '';
  String get listPerto => _listPerto;
  set listPerto(String value) {
    _listPerto = value;
  }

  int _passangers = 0;
  int get passangers => _passangers;
  set passangers(int value) {
    _passangers = value;
    prefs.setInt('ff_passangers', value);
  }

  List<dynamic> _creditCardSalves = [];
  List<dynamic> get creditCardSalves => _creditCardSalves;
  set creditCardSalves(List<dynamic> value) {
    _creditCardSalves = value;
    prefs.setStringList(
        'ff_creditCardSalves', value.map((x) => jsonEncode(x)).toList());
  }

  void addToCreditCardSalves(dynamic value) {
    creditCardSalves.add(value);
    prefs.setStringList('ff_creditCardSalves',
        _creditCardSalves.map((x) => jsonEncode(x)).toList());
  }

  void removeFromCreditCardSalves(dynamic value) {
    creditCardSalves.remove(value);
    prefs.setStringList('ff_creditCardSalves',
        _creditCardSalves.map((x) => jsonEncode(x)).toList());
  }

  void removeAtIndexFromCreditCardSalves(int index) {
    creditCardSalves.removeAt(index);
    prefs.setStringList('ff_creditCardSalves',
        _creditCardSalves.map((x) => jsonEncode(x)).toList());
  }

  void updateCreditCardSalvesAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    creditCardSalves[index] = updateFn(_creditCardSalves[index]);
    prefs.setStringList('ff_creditCardSalves',
        _creditCardSalves.map((x) => jsonEncode(x)).toList());
  }

  void insertAtIndexInCreditCardSalves(int index, dynamic value) {
    creditCardSalves.insert(index, value);
    prefs.setStringList('ff_creditCardSalves',
        _creditCardSalves.map((x) => jsonEncode(x)).toList());
  }

  dynamic _defaultCard;
  dynamic get defaultCard => _defaultCard;
  set defaultCard(dynamic value) {
    _defaultCard = value;
    prefs.setString('ff_defaultCard', jsonEncode(value));
  }

  final _recentTripsManager = StreamRequestManager<List<RideOrdersRecord>>();
  Stream<List<RideOrdersRecord>> recentTrips({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<RideOrdersRecord>> Function() requestFn,
  }) =>
      _recentTripsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearRecentTripsCache() => _recentTripsManager.clear();
  void clearRecentTripsCacheKey(String? uniqueKey) =>
      _recentTripsManager.clearRequest(uniqueKey);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
