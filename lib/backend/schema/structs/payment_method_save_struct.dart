// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class PaymentMethodSaveStruct extends FFFirebaseStruct {
  PaymentMethodSaveStruct({
    String? brand,
    bool? isDefault,
    String? last4Numbers,
    String? paymentMethodToken,
    bool? pass,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _brand = brand,
        _isDefault = isDefault,
        _last4Numbers = last4Numbers,
        _paymentMethodToken = paymentMethodToken,
        _pass = pass,
        super(firestoreUtilData);

  // "brand" field.
  String? _brand;
  String get brand => _brand ?? '';
  set brand(String? val) => _brand = val;

  bool hasBrand() => _brand != null;

  // "isDefault" field.
  bool? _isDefault;
  bool get isDefault => _isDefault ?? false;
  set isDefault(bool? val) => _isDefault = val;

  bool hasIsDefault() => _isDefault != null;

  // "last4Numbers" field.
  String? _last4Numbers;
  String get last4Numbers => _last4Numbers ?? '';
  set last4Numbers(String? val) => _last4Numbers = val;

  bool hasLast4Numbers() => _last4Numbers != null;

  // "paymentMethodToken" field.
  String? _paymentMethodToken;
  String get paymentMethodToken => _paymentMethodToken ?? '';
  set paymentMethodToken(String? val) => _paymentMethodToken = val;

  bool hasPaymentMethodToken() => _paymentMethodToken != null;

  // "pass" field.
  bool? _pass;
  bool get pass => _pass ?? false;
  set pass(bool? val) => _pass = val;

  bool hasPass() => _pass != null;

  static PaymentMethodSaveStruct fromMap(Map<String, dynamic> data) =>
      PaymentMethodSaveStruct(
        brand: data['brand'] as String?,
        isDefault: data['isDefault'] as bool?,
        last4Numbers: data['last4Numbers'] as String?,
        paymentMethodToken: data['paymentMethodToken'] as String?,
        pass: data['pass'] as bool?,
      );

  static PaymentMethodSaveStruct? maybeFromMap(dynamic data) => data is Map
      ? PaymentMethodSaveStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'brand': _brand,
        'isDefault': _isDefault,
        'last4Numbers': _last4Numbers,
        'paymentMethodToken': _paymentMethodToken,
        'pass': _pass,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'brand': serializeParam(
          _brand,
          ParamType.String,
        ),
        'isDefault': serializeParam(
          _isDefault,
          ParamType.bool,
        ),
        'last4Numbers': serializeParam(
          _last4Numbers,
          ParamType.String,
        ),
        'paymentMethodToken': serializeParam(
          _paymentMethodToken,
          ParamType.String,
        ),
        'pass': serializeParam(
          _pass,
          ParamType.bool,
        ),
      }.withoutNulls;

  static PaymentMethodSaveStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      PaymentMethodSaveStruct(
        brand: deserializeParam(
          data['brand'],
          ParamType.String,
          false,
        ),
        isDefault: deserializeParam(
          data['isDefault'],
          ParamType.bool,
          false,
        ),
        last4Numbers: deserializeParam(
          data['last4Numbers'],
          ParamType.String,
          false,
        ),
        paymentMethodToken: deserializeParam(
          data['paymentMethodToken'],
          ParamType.String,
          false,
        ),
        pass: deserializeParam(
          data['pass'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'PaymentMethodSaveStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PaymentMethodSaveStruct &&
        brand == other.brand &&
        isDefault == other.isDefault &&
        last4Numbers == other.last4Numbers &&
        paymentMethodToken == other.paymentMethodToken &&
        pass == other.pass;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([brand, isDefault, last4Numbers, paymentMethodToken, pass]);
}

PaymentMethodSaveStruct createPaymentMethodSaveStruct({
  String? brand,
  bool? isDefault,
  String? last4Numbers,
  String? paymentMethodToken,
  bool? pass,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    PaymentMethodSaveStruct(
      brand: brand,
      isDefault: isDefault,
      last4Numbers: last4Numbers,
      paymentMethodToken: paymentMethodToken,
      pass: pass,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

PaymentMethodSaveStruct? updatePaymentMethodSaveStruct(
  PaymentMethodSaveStruct? paymentMethodSave, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    paymentMethodSave
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addPaymentMethodSaveStructData(
  Map<String, dynamic> firestoreData,
  PaymentMethodSaveStruct? paymentMethodSave,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (paymentMethodSave == null) {
    return;
  }
  if (paymentMethodSave.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && paymentMethodSave.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final paymentMethodSaveData =
      getPaymentMethodSaveFirestoreData(paymentMethodSave, forFieldValue);
  final nestedData =
      paymentMethodSaveData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = paymentMethodSave.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getPaymentMethodSaveFirestoreData(
  PaymentMethodSaveStruct? paymentMethodSave, [
  bool forFieldValue = false,
]) {
  if (paymentMethodSave == null) {
    return {};
  }
  final firestoreData = mapToFirestore(paymentMethodSave.toMap());

  // Add any Firestore field values
  paymentMethodSave.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getPaymentMethodSaveListFirestoreData(
  List<PaymentMethodSaveStruct>? paymentMethodSaves,
) =>
    paymentMethodSaves
        ?.map((e) => getPaymentMethodSaveFirestoreData(e, true))
        .toList() ??
    [];
