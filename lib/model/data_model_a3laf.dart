import 'package:cloud_firestore/cloud_firestore.dart';

class DataModel {
final String todayPrice;
final String yesterdayPrice;
final String firstYesterdayPrice;
final String fourDaysAgoPrice;
final String five;


DataModel(  {
required this.todayPrice,required this.yesterdayPrice, required this.firstYesterdayPrice, required this.fourDaysAgoPrice,required this.five,
});

static DataModel fromSnapshot(DocumentSnapshot snap) {
return DataModel(
todayPrice: snap.get('Today\'s price'),
yesterdayPrice: snap.get('yesterday\'s price'),
firstYesterdayPrice: snap.get('first yesterday'),
fourDaysAgoPrice: snap.get('from four days'),
five : snap.get('5')


);


}
}