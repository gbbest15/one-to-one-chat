import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

class Controller {
  sendMessage({
    String? chatID,
    String? myID,
    String? selectedUserID,
    String? content,
  }) async {
    var documentReference = firestore
        .collection('chat')
        .doc(chatID)
        .collection('Messages')
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        {
          'idFrom': myID,
          'idTo': selectedUserID,
          'timestamp': FieldValue.serverTimestamp(),
          'content': content,
          'isread': false,
        },
      );
    });
  }
}

sendMessage({
  String? chatID,
  String? myID,
  String? selectedUserID,
  String? content,
}) async {
  var documentReference = firestore
      .collection('chat')
      .doc(chatID)
      .collection('Messages')
      .doc(DateTime.now().millisecondsSinceEpoch.toString());

  FirebaseFirestore.instance.runTransaction((transaction) async {
    transaction.set(
      documentReference,
      {
        'idFrom': myID,
        'idTo': selectedUserID,
        'timestamp': FieldValue.serverTimestamp(),
        'content': content,
        'isread': false,
      },
    );
  });
}
