import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/model/ll.dart';

class FirestoreDB2 {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<List<DataModel2>> getAllData2() {
    return _firebaseFirestore
        .collection("a3laf")
        .doc('Nahi 19')
        .snapshots()
        .map((snapshot) => [DataModel2.fromSnapshot(snapshot)]);
  }
}
