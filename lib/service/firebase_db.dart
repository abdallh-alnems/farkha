import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farkha_app/model/data_model.dart';

class FirestoreDB {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<List<DataModel>> getAllData() {
    return _firebaseFirestore
        .collection("frakh")
        .doc('sasso')
        .snapshots()
        .map((snapshot) => [DataModel.fromSnapshot(snapshot)]);
  }
}

// class FirestoreDB {
 
// final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

//   Stream<List<DataModel>> getAllData() {
//     return _firebaseFirestore.collection("price").snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) => DataModel.fromSnapshot(doc)).toList();
//     });
//   }
// }



