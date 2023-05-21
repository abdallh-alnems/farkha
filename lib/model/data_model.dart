import 'package:cloud_firestore/cloud_firestore.dart';

class DataModel {
  final String priceToDay;
  

  DataModel({
    required this.priceToDay,
     
  });

  static DataModel fromSnapshot(DocumentSnapshot snap) {
    DataModel data = DataModel(
      
      priceToDay: snap['first yesterday'],
    );

    return data;
  }
}
