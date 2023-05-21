import 'package:cloud_firestore/cloud_firestore.dart';

class DataModel2 {
  
  final String ff;

  DataModel2({
    
    required this.ff,
  });

  static DataModel2 fromSnapshot(DocumentSnapshot snap) {
    DataModel2 data = DataModel2(
      ff: snap['price'],
      
    );

    return data;
  }
}