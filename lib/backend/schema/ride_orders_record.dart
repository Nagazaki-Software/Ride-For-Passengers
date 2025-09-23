import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RideOrdersRecord extends FirestoreRecord {
  RideOrdersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "latlng" field.
  LatLng? _latlng;
  LatLng? get latlng => _latlng;
  bool hasLatlng() => _latlng != null;

  // "dia" field.
  DateTime? _dia;
  DateTime? get dia => _dia;
  bool hasDia() => _dia != null;

  // "option" field.
  String? _option;
  String get option => _option ?? '';
  bool hasOption() => _option != null;

  // "latlngAtual" field.
  LatLng? _latlngAtual;
  LatLng? get latlngAtual => _latlngAtual;
  bool hasLatlngAtual() => _latlngAtual != null;

  // "driver" field.
  DocumentReference? _driver;
  DocumentReference? get driver => _driver;
  bool hasDriver() => _driver != null;

  // "userPlataform" field.
  String? _userPlataform;
  String get userPlataform => _userPlataform ?? '';
  bool hasUserPlataform() => _userPlataform != null;

  // "salvarSomente" field.
  bool? _salvarSomente;
  bool get salvarSomente => _salvarSomente ?? false;
  bool hasSalvarSomente() => _salvarSomente != null;

  // "notas" field.
  String? _notas;
  String get notas => _notas ?? '';
  bool hasNotas() => _notas != null;

  // "repeat" field.
  String? _repeat;
  String get repeat => _repeat ?? '';
  bool hasRepeat() => _repeat != null;

  // "nomeOrigem" field.
  String? _nomeOrigem;
  String get nomeOrigem => _nomeOrigem ?? '';
  bool hasNomeOrigem() => _nomeOrigem != null;

  // "nomeDestino" field.
  String? _nomeDestino;
  String get nomeDestino => _nomeDestino ?? '';
  bool hasNomeDestino() => _nomeDestino != null;

  // "paid" field.
  bool? _paid;
  bool get paid => _paid ?? false;
  bool hasPaid() => _paid != null;

  // "rideShare" field.
  bool? _rideShare;
  bool get rideShare => _rideShare ?? false;
  bool hasRideShare() => _rideShare != null;

  // "participantes" field.
  List<DocumentReference>? _participantes;
  List<DocumentReference> get participantes => _participantes ?? const [];
  bool hasParticipantes() => _participantes != null;

  // "rideValue" field.
  double? _rideValue;
  double get rideValue => _rideValue ?? 0.0;
  bool hasRideValue() => _rideValue != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "whyCanceled" field.
  String? _whyCanceled;
  String get whyCanceled => _whyCanceled ?? '';
  bool hasWhyCanceled() => _whyCanceled != null;

  void _initializeFields() {
    _user = snapshotData['user'] as DocumentReference?;
    _latlng = snapshotData['latlng'] as LatLng?;
    _dia = snapshotData['dia'] as DateTime?;
    _option = snapshotData['option'] as String?;
    _latlngAtual = snapshotData['latlngAtual'] as LatLng?;
    _driver = snapshotData['driver'] as DocumentReference?;
    _userPlataform = snapshotData['userPlataform'] as String?;
    _salvarSomente = snapshotData['salvarSomente'] as bool?;
    _notas = snapshotData['notas'] as String?;
    _repeat = snapshotData['repeat'] as String?;
    _nomeOrigem = snapshotData['nomeOrigem'] as String?;
    _nomeDestino = snapshotData['nomeDestino'] as String?;
    _paid = snapshotData['paid'] as bool?;
    _rideShare = snapshotData['rideShare'] as bool?;
    _participantes = getDataList(snapshotData['participantes']);
    _rideValue = castToType<double>(snapshotData['rideValue']);
    _status = snapshotData['status'] as String?;
    _whyCanceled = snapshotData['whyCanceled'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('rideOrders');

  static Stream<RideOrdersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RideOrdersRecord.fromSnapshot(s));

  static Future<RideOrdersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RideOrdersRecord.fromSnapshot(s));

  static RideOrdersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RideOrdersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RideOrdersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RideOrdersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RideOrdersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RideOrdersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRideOrdersRecordData({
  DocumentReference? user,
  LatLng? latlng,
  DateTime? dia,
  String? option,
  LatLng? latlngAtual,
  DocumentReference? driver,
  String? userPlataform,
  bool? salvarSomente,
  String? notas,
  String? repeat,
  String? nomeOrigem,
  String? nomeDestino,
  bool? paid,
  bool? rideShare,
  double? rideValue,
  String? status,
  String? whyCanceled,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user': user,
      'latlng': latlng,
      'dia': dia,
      'option': option,
      'latlngAtual': latlngAtual,
      'driver': driver,
      'userPlataform': userPlataform,
      'salvarSomente': salvarSomente,
      'notas': notas,
      'repeat': repeat,
      'nomeOrigem': nomeOrigem,
      'nomeDestino': nomeDestino,
      'paid': paid,
      'rideShare': rideShare,
      'rideValue': rideValue,
      'status': status,
      'whyCanceled': whyCanceled,
    }.withoutNulls,
  );

  return firestoreData;
}

class RideOrdersRecordDocumentEquality implements Equality<RideOrdersRecord> {
  const RideOrdersRecordDocumentEquality();

  @override
  bool equals(RideOrdersRecord? e1, RideOrdersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.user == e2?.user &&
        e1?.latlng == e2?.latlng &&
        e1?.dia == e2?.dia &&
        e1?.option == e2?.option &&
        e1?.latlngAtual == e2?.latlngAtual &&
        e1?.driver == e2?.driver &&
        e1?.userPlataform == e2?.userPlataform &&
        e1?.salvarSomente == e2?.salvarSomente &&
        e1?.notas == e2?.notas &&
        e1?.repeat == e2?.repeat &&
        e1?.nomeOrigem == e2?.nomeOrigem &&
        e1?.nomeDestino == e2?.nomeDestino &&
        e1?.paid == e2?.paid &&
        e1?.rideShare == e2?.rideShare &&
        listEquality.equals(e1?.participantes, e2?.participantes) &&
        e1?.rideValue == e2?.rideValue &&
        e1?.status == e2?.status &&
        e1?.whyCanceled == e2?.whyCanceled;
  }

  @override
  int hash(RideOrdersRecord? e) => const ListEquality().hash([
        e?.user,
        e?.latlng,
        e?.dia,
        e?.option,
        e?.latlngAtual,
        e?.driver,
        e?.userPlataform,
        e?.salvarSomente,
        e?.notas,
        e?.repeat,
        e?.nomeOrigem,
        e?.nomeDestino,
        e?.paid,
        e?.rideShare,
        e?.participantes,
        e?.rideValue,
        e?.status,
        e?.whyCanceled
      ]);

  @override
  bool isValidKey(Object? o) => o is RideOrdersRecord;
}
