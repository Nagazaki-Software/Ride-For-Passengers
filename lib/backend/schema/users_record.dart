import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "plataform" field.
  List<String>? _plataform;
  List<String> get plataform => _plataform ?? const [];
  bool hasPlataform() => _plataform != null;

  // "saldo" field.
  double? _saldo;
  double get saldo => _saldo ?? 0.0;
  bool hasSaldo() => _saldo != null;

  // "driver" field.
  bool? _driver;
  bool get driver => _driver ?? false;
  bool hasDriver() => _driver != null;

  // "driverOnline" field.
  bool? _driverOnline;
  bool get driverOnline => _driverOnline ?? false;
  bool hasDriverOnline() => _driverOnline != null;

  // "passe" field.
  String? _passe;
  String get passe => _passe ?? '';
  bool hasPasse() => _passe != null;

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  // "ridePoints" field.
  int? _ridePoints;
  int get ridePoints => _ridePoints ?? 0;
  bool hasRidePoints() => _ridePoints != null;

  // "codeUser" field.
  String? _codeUser;
  String get codeUser => _codeUser ?? '';
  bool hasCodeUser() => _codeUser != null;

  // "verifyaccount" field.
  bool? _verifyaccount;
  bool get verifyaccount => _verifyaccount ?? false;
  bool hasVerifyaccount() => _verifyaccount != null;

  // "etnia" field.
  String? _etnia;
  String get etnia => _etnia ?? '';
  bool hasEtnia() => _etnia != null;

  // "activitys" field.
  List<ActivityStruct>? _activitys;
  List<ActivityStruct> get activitys => _activitys ?? const [];
  bool hasActivitys() => _activitys != null;

  // "emergencyContacts" field.
  List<EmergencyContactStruct>? _emergencyContacts;
  List<EmergencyContactStruct> get emergencyContacts =>
      _emergencyContacts ?? const [];
  bool hasEmergencyContacts() => _emergencyContacts != null;

  // "identifyDocument" field.
  UserIdentifyDocumentStruct? _identifyDocument;
  UserIdentifyDocumentStruct get identifyDocument =>
      _identifyDocument ?? UserIdentifyDocumentStruct();
  bool hasIdentifyDocument() => _identifyDocument != null;

  // "ratings" field.
  int? _ratings;
  int get ratings => _ratings ?? 0;
  bool hasRatings() => _ratings != null;

  // "licences" field.
  DriversLicensesStruct? _licences;
  DriversLicensesStruct get licences => _licences ?? DriversLicensesStruct();
  bool hasLicences() => _licences != null;

  // "rating" field.
  List<RatingsStruct>? _rating;
  List<RatingsStruct> get rating => _rating ?? const [];
  bool hasRating() => _rating != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _plataform = getDataList(snapshotData['plataform']);
    _saldo = castToType<double>(snapshotData['saldo']);
    _driver = snapshotData['driver'] as bool?;
    _driverOnline = snapshotData['driverOnline'] as bool?;
    _passe = snapshotData['passe'] as String?;
    _location = snapshotData['location'] as LatLng?;
    _ridePoints = castToType<int>(snapshotData['ridePoints']);
    _codeUser = snapshotData['codeUser'] as String?;
    _verifyaccount = snapshotData['verifyaccount'] as bool?;
    _etnia = snapshotData['etnia'] as String?;
    _activitys = getStructList(
      snapshotData['activitys'],
      ActivityStruct.fromMap,
    );
    _emergencyContacts = getStructList(
      snapshotData['emergencyContacts'],
      EmergencyContactStruct.fromMap,
    );
    _identifyDocument =
        snapshotData['identifyDocument'] is UserIdentifyDocumentStruct
            ? snapshotData['identifyDocument']
            : UserIdentifyDocumentStruct.maybeFromMap(
                snapshotData['identifyDocument']);
    _ratings = castToType<int>(snapshotData['ratings']);
    _licences = snapshotData['licences'] is DriversLicensesStruct
        ? snapshotData['licences']
        : DriversLicensesStruct.maybeFromMap(snapshotData['licences']);
    _rating = getStructList(
      snapshotData['rating'],
      RatingsStruct.fromMap,
    );
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  double? saldo,
  bool? driver,
  bool? driverOnline,
  String? passe,
  LatLng? location,
  int? ridePoints,
  String? codeUser,
  bool? verifyaccount,
  String? etnia,
  UserIdentifyDocumentStruct? identifyDocument,
  int? ratings,
  DriversLicensesStruct? licences,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'saldo': saldo,
      'driver': driver,
      'driverOnline': driverOnline,
      'passe': passe,
      'location': location,
      'ridePoints': ridePoints,
      'codeUser': codeUser,
      'verifyaccount': verifyaccount,
      'etnia': etnia,
      'identifyDocument': UserIdentifyDocumentStruct().toMap(),
      'ratings': ratings,
      'licences': DriversLicensesStruct().toMap(),
    }.withoutNulls,
  );

  // Handle nested data for "identifyDocument" field.
  addUserIdentifyDocumentStructData(
      firestoreData, identifyDocument, 'identifyDocument');

  // Handle nested data for "licences" field.
  addDriversLicensesStructData(firestoreData, licences, 'licences');

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        listEquality.equals(e1?.plataform, e2?.plataform) &&
        e1?.saldo == e2?.saldo &&
        e1?.driver == e2?.driver &&
        e1?.driverOnline == e2?.driverOnline &&
        e1?.passe == e2?.passe &&
        e1?.location == e2?.location &&
        e1?.ridePoints == e2?.ridePoints &&
        e1?.codeUser == e2?.codeUser &&
        e1?.verifyaccount == e2?.verifyaccount &&
        e1?.etnia == e2?.etnia &&
        listEquality.equals(e1?.activitys, e2?.activitys) &&
        listEquality.equals(e1?.emergencyContacts, e2?.emergencyContacts) &&
        e1?.identifyDocument == e2?.identifyDocument &&
        e1?.ratings == e2?.ratings &&
        e1?.licences == e2?.licences &&
        listEquality.equals(e1?.rating, e2?.rating);
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.plataform,
        e?.saldo,
        e?.driver,
        e?.driverOnline,
        e?.passe,
        e?.location,
        e?.ridePoints,
        e?.codeUser,
        e?.verifyaccount,
        e?.etnia,
        e?.activitys,
        e?.emergencyContacts,
        e?.identifyDocument,
        e?.ratings,
        e?.licences,
        e?.rating
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
