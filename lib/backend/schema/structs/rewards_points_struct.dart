// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class RewardsPointsStruct extends FFFirebaseStruct {
  RewardsPointsStruct({
    int? points,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _points = points,
        super(firestoreUtilData);

  // "points" field.
  int? _points;
  int get points => _points ?? 0;
  set points(int? val) => _points = val;

  void incrementPoints(int amount) => points = points + amount;

  bool hasPoints() => _points != null;

  static RewardsPointsStruct fromMap(Map<String, dynamic> data) =>
      RewardsPointsStruct(
        points: castToType<int>(data['points']),
      );

  static RewardsPointsStruct? maybeFromMap(dynamic data) => data is Map
      ? RewardsPointsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'points': _points,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'points': serializeParam(
          _points,
          ParamType.int,
        ),
      }.withoutNulls;

  static RewardsPointsStruct fromSerializableMap(Map<String, dynamic> data) =>
      RewardsPointsStruct(
        points: deserializeParam(
          data['points'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'RewardsPointsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is RewardsPointsStruct && points == other.points;
  }

  @override
  int get hashCode => const ListEquality().hash([points]);
}

RewardsPointsStruct createRewardsPointsStruct({
  int? points,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    RewardsPointsStruct(
      points: points,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

RewardsPointsStruct? updateRewardsPointsStruct(
  RewardsPointsStruct? rewardsPoints, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    rewardsPoints
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addRewardsPointsStructData(
  Map<String, dynamic> firestoreData,
  RewardsPointsStruct? rewardsPoints,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (rewardsPoints == null) {
    return;
  }
  if (rewardsPoints.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && rewardsPoints.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final rewardsPointsData =
      getRewardsPointsFirestoreData(rewardsPoints, forFieldValue);
  final nestedData =
      rewardsPointsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = rewardsPoints.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getRewardsPointsFirestoreData(
  RewardsPointsStruct? rewardsPoints, [
  bool forFieldValue = false,
]) {
  if (rewardsPoints == null) {
    return {};
  }
  final firestoreData = mapToFirestore(rewardsPoints.toMap());

  // Add any Firestore field values
  rewardsPoints.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getRewardsPointsListFirestoreData(
  List<RewardsPointsStruct>? rewardsPointss,
) =>
    rewardsPointss
        ?.map((e) => getRewardsPointsFirestoreData(e, true))
        .toList() ??
    [];
