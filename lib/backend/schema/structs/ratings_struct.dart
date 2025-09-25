// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class RatingsStruct extends FFFirebaseStruct {
  RatingsStruct({
    DocumentReference? user,
    int? value,
    DateTime? data,
    String? text,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _user = user,
        _value = value,
        _data = data,
        _text = text,
        super(firestoreUtilData);

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  set user(DocumentReference? val) => _user = val;

  bool hasUser() => _user != null;

  // "value" field.
  int? _value;
  int get value => _value ?? 0;
  set value(int? val) => _value = val;

  void incrementValue(int amount) => value = value + amount;

  bool hasValue() => _value != null;

  // "data" field.
  DateTime? _data;
  DateTime? get data => _data;
  set data(DateTime? val) => _data = val;

  bool hasData() => _data != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  set text(String? val) => _text = val;

  bool hasText() => _text != null;

  static RatingsStruct fromMap(Map<String, dynamic> data) => RatingsStruct(
        user: data['user'] as DocumentReference?,
        value: castToType<int>(data['value']),
        data: data['data'] as DateTime?,
        text: data['text'] as String?,
      );

  static RatingsStruct? maybeFromMap(dynamic data) =>
      data is Map ? RatingsStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'user': _user,
        'value': _value,
        'data': _data,
        'text': _text,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'user': serializeParam(
          _user,
          ParamType.DocumentReference,
        ),
        'value': serializeParam(
          _value,
          ParamType.int,
        ),
        'data': serializeParam(
          _data,
          ParamType.DateTime,
        ),
        'text': serializeParam(
          _text,
          ParamType.String,
        ),
      }.withoutNulls;

  static RatingsStruct fromSerializableMap(Map<String, dynamic> data) =>
      RatingsStruct(
        user: deserializeParam(
          data['user'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['users'],
        ),
        value: deserializeParam(
          data['value'],
          ParamType.int,
          false,
        ),
        data: deserializeParam(
          data['data'],
          ParamType.DateTime,
          false,
        ),
        text: deserializeParam(
          data['text'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'RatingsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is RatingsStruct &&
        user == other.user &&
        value == other.value &&
        data == other.data &&
        text == other.text;
  }

  @override
  int get hashCode => const ListEquality().hash([user, value, data, text]);
}

RatingsStruct createRatingsStruct({
  DocumentReference? user,
  int? value,
  DateTime? data,
  String? text,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    RatingsStruct(
      user: user,
      value: value,
      data: data,
      text: text,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

RatingsStruct? updateRatingsStruct(
  RatingsStruct? ratings, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    ratings
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addRatingsStructData(
  Map<String, dynamic> firestoreData,
  RatingsStruct? ratings,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (ratings == null) {
    return;
  }
  if (ratings.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && ratings.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final ratingsData = getRatingsFirestoreData(ratings, forFieldValue);
  final nestedData = ratingsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = ratings.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getRatingsFirestoreData(
  RatingsStruct? ratings, [
  bool forFieldValue = false,
]) {
  if (ratings == null) {
    return {};
  }
  final firestoreData = mapToFirestore(ratings.toMap());

  // Add any Firestore field values
  ratings.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getRatingsListFirestoreData(
  List<RatingsStruct>? ratingss,
) =>
    ratingss?.map((e) => getRatingsFirestoreData(e, true)).toList() ?? [];
