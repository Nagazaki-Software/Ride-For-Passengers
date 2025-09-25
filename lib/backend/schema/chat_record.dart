import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChatRecord extends FirestoreRecord {
  ChatRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "rideOrderReference" field.
  DocumentReference? _rideOrderReference;
  DocumentReference? get rideOrderReference => _rideOrderReference;
  bool hasRideOrderReference() => _rideOrderReference != null;

  // "ultimaMsg" field.
  DateTime? _ultimaMsg;
  DateTime? get ultimaMsg => _ultimaMsg;
  bool hasUltimaMsg() => _ultimaMsg != null;

  // "userDocument" field.
  DocumentReference? _userDocument;
  DocumentReference? get userDocument => _userDocument;
  bool hasUserDocument() => _userDocument != null;

  void _initializeFields() {
    _rideOrderReference =
        snapshotData['rideOrderReference'] as DocumentReference?;
    _ultimaMsg = snapshotData['ultimaMsg'] as DateTime?;
    _userDocument = snapshotData['userDocument'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('chat');

  static Stream<ChatRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ChatRecord.fromSnapshot(s));

  static Future<ChatRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ChatRecord.fromSnapshot(s));

  static ChatRecord fromSnapshot(DocumentSnapshot snapshot) => ChatRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ChatRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ChatRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ChatRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ChatRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createChatRecordData({
  DocumentReference? rideOrderReference,
  DateTime? ultimaMsg,
  DocumentReference? userDocument,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'rideOrderReference': rideOrderReference,
      'ultimaMsg': ultimaMsg,
      'userDocument': userDocument,
    }.withoutNulls,
  );

  return firestoreData;
}

class ChatRecordDocumentEquality implements Equality<ChatRecord> {
  const ChatRecordDocumentEquality();

  @override
  bool equals(ChatRecord? e1, ChatRecord? e2) {
    return e1?.rideOrderReference == e2?.rideOrderReference &&
        e1?.ultimaMsg == e2?.ultimaMsg &&
        e1?.userDocument == e2?.userDocument;
  }

  @override
  int hash(ChatRecord? e) => const ListEquality()
      .hash([e?.rideOrderReference, e?.ultimaMsg, e?.userDocument]);

  @override
  bool isValidKey(Object? o) => o is ChatRecord;
}
