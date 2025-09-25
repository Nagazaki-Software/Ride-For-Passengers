// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class EmergencyContactStruct extends FFFirebaseStruct {
  EmergencyContactStruct({
    String? contactName,
    String? number,
    String? relationship,
    bool? principalEmergency,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _contactName = contactName,
        _number = number,
        _relationship = relationship,
        _principalEmergency = principalEmergency,
        super(firestoreUtilData);

  // "contactName" field.
  String? _contactName;
  String get contactName => _contactName ?? '';
  set contactName(String? val) => _contactName = val;

  bool hasContactName() => _contactName != null;

  // "number" field.
  String? _number;
  String get number => _number ?? '';
  set number(String? val) => _number = val;

  bool hasNumber() => _number != null;

  // "relationship" field.
  String? _relationship;
  String get relationship => _relationship ?? '';
  set relationship(String? val) => _relationship = val;

  bool hasRelationship() => _relationship != null;

  // "principalEmergency" field.
  bool? _principalEmergency;
  bool get principalEmergency => _principalEmergency ?? false;
  set principalEmergency(bool? val) => _principalEmergency = val;

  bool hasPrincipalEmergency() => _principalEmergency != null;

  static EmergencyContactStruct fromMap(Map<String, dynamic> data) =>
      EmergencyContactStruct(
        contactName: data['contactName'] as String?,
        number: data['number'] as String?,
        relationship: data['relationship'] as String?,
        principalEmergency: data['principalEmergency'] as bool?,
      );

  static EmergencyContactStruct? maybeFromMap(dynamic data) => data is Map
      ? EmergencyContactStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'contactName': _contactName,
        'number': _number,
        'relationship': _relationship,
        'principalEmergency': _principalEmergency,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'contactName': serializeParam(
          _contactName,
          ParamType.String,
        ),
        'number': serializeParam(
          _number,
          ParamType.String,
        ),
        'relationship': serializeParam(
          _relationship,
          ParamType.String,
        ),
        'principalEmergency': serializeParam(
          _principalEmergency,
          ParamType.bool,
        ),
      }.withoutNulls;

  static EmergencyContactStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      EmergencyContactStruct(
        contactName: deserializeParam(
          data['contactName'],
          ParamType.String,
          false,
        ),
        number: deserializeParam(
          data['number'],
          ParamType.String,
          false,
        ),
        relationship: deserializeParam(
          data['relationship'],
          ParamType.String,
          false,
        ),
        principalEmergency: deserializeParam(
          data['principalEmergency'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'EmergencyContactStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is EmergencyContactStruct &&
        contactName == other.contactName &&
        number == other.number &&
        relationship == other.relationship &&
        principalEmergency == other.principalEmergency;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([contactName, number, relationship, principalEmergency]);
}

EmergencyContactStruct createEmergencyContactStruct({
  String? contactName,
  String? number,
  String? relationship,
  bool? principalEmergency,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    EmergencyContactStruct(
      contactName: contactName,
      number: number,
      relationship: relationship,
      principalEmergency: principalEmergency,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

EmergencyContactStruct? updateEmergencyContactStruct(
  EmergencyContactStruct? emergencyContact, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    emergencyContact
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addEmergencyContactStructData(
  Map<String, dynamic> firestoreData,
  EmergencyContactStruct? emergencyContact,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (emergencyContact == null) {
    return;
  }
  if (emergencyContact.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && emergencyContact.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final emergencyContactData =
      getEmergencyContactFirestoreData(emergencyContact, forFieldValue);
  final nestedData =
      emergencyContactData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = emergencyContact.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getEmergencyContactFirestoreData(
  EmergencyContactStruct? emergencyContact, [
  bool forFieldValue = false,
]) {
  if (emergencyContact == null) {
    return {};
  }
  final firestoreData = mapToFirestore(emergencyContact.toMap());

  // Add any Firestore field values
  emergencyContact.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getEmergencyContactListFirestoreData(
  List<EmergencyContactStruct>? emergencyContacts,
) =>
    emergencyContacts
        ?.map((e) => getEmergencyContactFirestoreData(e, true))
        .toList() ??
    [];
