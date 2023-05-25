

// import 'package:cloud_firestore/cloud_firestore.dart';

// class DataModel {
//   final String todayPrice;
//   final String yesterdayPrice;
//   final String firstYesterdayPrice;
//   final String fourDaysAgoPrice;

//   DataModel({
//     required this.todayPrice,
//     required this.yesterdayPrice,
//     required this.firstYesterdayPrice,
//     required this.fourDaysAgoPrice,
//   });

//   factory DataModel.fromSnapshot(DocumentSnapshot snap) {
//     return DataModel(
//       todayPrice: snap['Today\'s price'],
//       yesterdayPrice: snap['yesterday\'s price'],
//       firstYesterdayPrice: snap['first yesterday\'s price'],
//       fourDaysAgoPrice: snap['from four days ago\'s price'],
//     );
//   }
// }









import 'package:cloud_firestore/cloud_firestore.dart';

class DataModel {
  final String todayPrice;
  final String yesterdayPrice;
  final String firstYesterdayPrice;
  final String fourDaysAgoPrice;
  

  DataModel( {
    required this.todayPrice,required this.yesterdayPrice, required this.firstYesterdayPrice, required this.fourDaysAgoPrice,
  });

  static DataModel fromSnapshot(DocumentSnapshot snap) {
    DataModel dataFire = DataModel(
      todayPrice: snap["Today's price"],
      yesterdayPrice: snap["yesterday's price"],
      firstYesterdayPrice: snap['first yesterday'],
      fourDaysAgoPrice: snap['from four days'],
      
    );

    return dataFire;
  }
}
