// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class ActivityStruct extends FFFirebaseStruct {
  ActivityStruct({
    String? nameActivity,
    DateTime? date,
    int? points,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _nameActivity = nameActivity,
        _date = date,
        _points = points,
        super(firestoreUtilData);

  // "nameActivity" field.
  String? _nameActivity;
  String get nameActivity => _nameActivity ?? '';
  set nameActivity(String? val) => _nameActivity = val;

  bool hasNameActivity() => _nameActivity != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  set date(DateTime? val) => _date = val;

  bool hasDate() => _date != null;

  // "points" field.
  int? _points;
  int get points => _points ?? 0;
  set points(int? val) => _points = val;

  void incrementPoints(int amount) => points = points + amount;

  bool hasPoints() => _points != null;

  static ActivityStruct fromMap(Map<String, dynamic> data) => ActivityStruct(
        nameActivity: data['nameActivity'] as String?,
        date: data['date'] as DateTime?,
        points: castToType<int>(data['points']),
      );

  static ActivityStruct? maybeFromMap(dynamic data) =>
      data is Map ? ActivityStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'nameActivity': _nameActivity,
        'date': _date,
        'points': _points,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'nameActivity': serializeParam(
          _nameActivity,
          ParamType.String,
        ),
        'date': serializeParam(
          _date,
          ParamType.DateTime,
        ),
        'points': serializeParam(
          _points,
          ParamType.int,
        ),
      }.withoutNulls;

  static ActivityStruct fromSerializableMap(Map<String, dynamic> data) =>
      ActivityStruct(
        nameActivity: deserializeParam(
          data['nameActivity'],
          ParamType.String,
          false,
        ),
        date: deserializeParam(
          data['date'],
          ParamType.DateTime,
          false,
        ),
        points: deserializeParam(
          data['points'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'ActivityStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ActivityStruct &&
        nameActivity == other.nameActivity &&
        date == other.date &&
        points == other.points;
  }

  @override
  int get hashCode => const ListEquality().hash([nameActivity, date, points]);
}

ActivityStruct createActivityStruct({
  String? nameActivity,
  DateTime? date,
  int? points,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ActivityStruct(
      nameActivity: nameActivity,
      date: date,
      points: points,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ActivityStruct? updateActivityStruct(
  ActivityStruct? activity, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    activity
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addActivityStructData(
  Map<String, dynamic> firestoreData,
  ActivityStruct? activity,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (activity == null) {
    return;
  }
  if (activity.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && activity.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final activityData = getActivityFirestoreData(activity, forFieldValue);
  final nestedData = activityData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = activity.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getActivityFirestoreData(
  ActivityStruct? activity, [
  bool forFieldValue = false,
]) {
  if (activity == null) {
    return {};
  }
  final firestoreData = mapToFirestore(activity.toMap());

  // Add any Firestore field values
  activity.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getActivityListFirestoreData(
  List<ActivityStruct>? activitys,
) =>
    activitys?.map((e) => getActivityFirestoreData(e, true)).toList() ?? [];
