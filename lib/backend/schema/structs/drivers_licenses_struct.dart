// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DriversLicensesStruct extends FFFirebaseStruct {
  DriversLicensesStruct({
    List<String>? veiculoPhotos,
    String? carName,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _veiculoPhotos = veiculoPhotos,
        _carName = carName,
        super(firestoreUtilData);

  // "veiculoPhotos" field.
  List<String>? _veiculoPhotos;
  List<String> get veiculoPhotos => _veiculoPhotos ?? const [];
  set veiculoPhotos(List<String>? val) => _veiculoPhotos = val;

  void updateVeiculoPhotos(Function(List<String>) updateFn) {
    updateFn(_veiculoPhotos ??= []);
  }

  bool hasVeiculoPhotos() => _veiculoPhotos != null;

  // "carName" field.
  String? _carName;
  String get carName => _carName ?? '';
  set carName(String? val) => _carName = val;

  bool hasCarName() => _carName != null;

  static DriversLicensesStruct fromMap(Map<String, dynamic> data) =>
      DriversLicensesStruct(
        veiculoPhotos: getDataList(data['veiculoPhotos']),
        carName: data['carName'] as String?,
      );

  static DriversLicensesStruct? maybeFromMap(dynamic data) => data is Map
      ? DriversLicensesStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'veiculoPhotos': _veiculoPhotos,
        'carName': _carName,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'veiculoPhotos': serializeParam(
          _veiculoPhotos,
          ParamType.String,
          isList: true,
        ),
        'carName': serializeParam(
          _carName,
          ParamType.String,
        ),
      }.withoutNulls;

  static DriversLicensesStruct fromSerializableMap(Map<String, dynamic> data) =>
      DriversLicensesStruct(
        veiculoPhotos: deserializeParam<String>(
          data['veiculoPhotos'],
          ParamType.String,
          true,
        ),
        carName: deserializeParam(
          data['carName'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'DriversLicensesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is DriversLicensesStruct &&
        listEquality.equals(veiculoPhotos, other.veiculoPhotos) &&
        carName == other.carName;
  }

  @override
  int get hashCode => const ListEquality().hash([veiculoPhotos, carName]);
}

DriversLicensesStruct createDriversLicensesStruct({
  String? carName,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    DriversLicensesStruct(
      carName: carName,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

DriversLicensesStruct? updateDriversLicensesStruct(
  DriversLicensesStruct? driversLicenses, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    driversLicenses
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addDriversLicensesStructData(
  Map<String, dynamic> firestoreData,
  DriversLicensesStruct? driversLicenses,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (driversLicenses == null) {
    return;
  }
  if (driversLicenses.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && driversLicenses.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final driversLicensesData =
      getDriversLicensesFirestoreData(driversLicenses, forFieldValue);
  final nestedData =
      driversLicensesData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = driversLicenses.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getDriversLicensesFirestoreData(
  DriversLicensesStruct? driversLicenses, [
  bool forFieldValue = false,
]) {
  if (driversLicenses == null) {
    return {};
  }
  final firestoreData = mapToFirestore(driversLicenses.toMap());

  // Add any Firestore field values
  driversLicenses.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getDriversLicensesListFirestoreData(
  List<DriversLicensesStruct>? driversLicensess,
) =>
    driversLicensess
        ?.map((e) => getDriversLicensesFirestoreData(e, true))
        .toList() ??
    [];
