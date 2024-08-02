import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slush/constants/LocalHandler.dart';

class FireStoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addCollection() async {
    try {
      await firestore.collection("collection")
          .doc(LocaleHandler.eventId.toString())
          .collection("${LocaleHandler.dateno}")
          .doc(LocaleHandler.channelId)
          .set({
        "createdUserId": LocaleHandler.userId,
        "callstatus": "wait"
      });
    } catch (e) {
      // Handle any errors here
      print("Error adding collection: $e");
    }
  }

  Future<void> updateCallStatusToPicked(String status) async {
    try {
      await firestore.collection("collection")
          .doc(LocaleHandler.eventId.toString())
          .collection("${LocaleHandler.dateno}")
          .doc(LocaleHandler.channelId)
          .update({
        "callstatus": status
      });
    } catch (e) {
      // Handle any errors here
      print("Error updating call status: $e");
    }
  }

  Stream<DocumentSnapshot> getCallStatusStream() {
    return firestore.collection("collection")
        .doc(LocaleHandler.eventId.toString())
        .collection("${LocaleHandler.dateno}")
        .doc(LocaleHandler.channelId)
        .snapshots();
  }

  Future<void> deleteCallStatusToPicked() async {
    try {
      await firestore.collection("collection")
          .doc(LocaleHandler.eventId.toString())
          .collection("${LocaleHandler.dateno}")
          .doc(LocaleHandler.channelId)
          .delete();
    } catch (e) {
      // Handle any errors here
      print("Error updating call status: $e");
    }
  }
}