import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farkha_app/model/data_model.dart';

class DataFirestore {
      List<DataModel> frakhAbid = <DataModel>[];

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final String collection;
  final String doc;

  DataFirestore({
    required this.collection,
    required this.doc,
  });

 

  Future<List<DataModel>> getAllData() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection(collection).doc(doc).get();

    return [DataModel.fromSnapshot(snapshot)];
  }
}



// هذا الكود الاولي اما المستعمل تبسيط
// Future<List<DataModel>> getAllData() async {
//     DocumentReference documentRef = _firebaseFirestore.collection(collection).doc(doc);

//     DocumentSnapshot documentSnapshot = await documentRef.get();

//     return [DataModel.fromSnapshot(documentSnapshot)];
//   }


//احضار جميع الدوكمين

  //   Future<List<DataModel>> getAllData() async {
  //   QuerySnapshot  snapshot = await _firebaseFirestore.collection(collection).get();
  //   return snapshot.docs.map((doc) => DataModel.fromSnapshot(doc)).toList();
  // }

// احضار البيانات والتغير بشكل مباشر
  // Stream<List<DataModel>> getAllData() {
  //   return _firebaseFirestore
  //       .collection(collection)
  //       .doc(doc)
  //       .snapshots()
  //       .map((snapshot) => [DataModel.fromSnapshot(snapshot)]);
  // }
// }

// class FirestoreDB {

// final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

//   Stream<List<DataModel>> getAllData() {
//     return _firebaseFirestore.collection("price").snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) => DataModel.fromSnapshot(doc)).toList();
//     });
//   }
// }
