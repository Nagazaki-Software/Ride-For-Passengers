// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class UserIdentifyDocumentStruct extends FFFirebaseStruct {
  UserIdentifyDocumentStruct({
    String? photo,
    bool? aceito,
    String? razoes,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _photo = photo,
        _aceito = aceito,
        _razoes = razoes,
        super(firestoreUtilData);

  // "photo" field.
  String? _photo;
  String get photo => _photo ?? '';
  set photo(String? val) => _photo = val;

  bool hasPhoto() => _photo != null;

  // "aceito" field.
  bool? _aceito;
  bool get aceito => _aceito ?? false;
  set aceito(bool? val) => _aceito = val;

  bool hasAceito() => _aceito != null;

  // "razoes" field.
  String? _razoes;
  String get razoes => _razoes ?? '';
  set razoes(String? val) => _razoes = val;

  bool hasRazoes() => _razoes != null;

  static UserIdentifyDocumentStruct fromMap(Map<String, dynamic> data) =>
      UserIdentifyDocumentStruct(
        photo: data['photo'] as String?,
        aceito: data['aceito'] as bool?,
        razoes: data['razoes'] as String?,
      );

  static UserIdentifyDocumentStruct? maybeFromMap(dynamic data) => data is Map
      ? UserIdentifyDocumentStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'photo': _photo,
        'aceito': _aceito,
        'razoes': _razoes,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'photo': serializeParam(
          _photo,
          ParamType.String,
        ),
        'aceito': serializeParam(
          _aceito,
          ParamType.bool,
        ),
        'razoes': serializeParam(
          _razoes,
          ParamType.String,
        ),
      }.withoutNulls;

  static UserIdentifyDocumentStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      UserIdentifyDocumentStruct(
        photo: deserializeParam(
          data['photo'],
          ParamType.String,
          false,
        ),
        aceito: deserializeParam(
          data['aceito'],
          ParamType.bool,
          false,
        ),
        razoes: deserializeParam(
          data['razoes'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UserIdentifyDocumentStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UserIdentifyDocumentStruct &&
        photo == other.photo &&
        aceito == other.aceito &&
        razoes == other.razoes;
  }

  @override
  int get hashCode => const ListEquality().hash([photo, aceito, razoes]);
}

UserIdentifyDocumentStruct createUserIdentifyDocumentStruct({
  String? photo,
  bool? aceito,
  String? razoes,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    UserIdentifyDocumentStruct(
      photo: photo,
      aceito: aceito,
      razoes: razoes,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

UserIdentifyDocumentStruct? updateUserIdentifyDocumentStruct(
  UserIdentifyDocumentStruct? userIdentifyDocument, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    userIdentifyDocument
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addUserIdentifyDocumentStructData(
  Map<String, dynamic> firestoreData,
  UserIdentifyDocumentStruct? userIdentifyDocument,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (userIdentifyDocument == null) {
    return;
  }
  if (userIdentifyDocument.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && userIdentifyDocument.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final userIdentifyDocumentData =
      getUserIdentifyDocumentFirestoreData(userIdentifyDocument, forFieldValue);
  final nestedData =
      userIdentifyDocumentData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      userIdentifyDocument.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getUserIdentifyDocumentFirestoreData(
  UserIdentifyDocumentStruct? userIdentifyDocument, [
  bool forFieldValue = false,
]) {
  if (userIdentifyDocument == null) {
    return {};
  }
  final firestoreData = mapToFirestore(userIdentifyDocument.toMap());

  // Add any Firestore field values
  userIdentifyDocument.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getUserIdentifyDocumentListFirestoreData(
  List<UserIdentifyDocumentStruct>? userIdentifyDocuments,
) =>
    userIdentifyDocuments
        ?.map((e) => getUserIdentifyDocumentFirestoreData(e, true))
        .toList() ??
    [];
