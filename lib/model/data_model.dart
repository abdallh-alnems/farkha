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
  final String one;
  final String two;
  final String three;
  final String four;
  final String five;
  final String six;
  final String seven;
  final String eight;
  final String nine;
  final String ten;
  final String eleven;
  final String twelve;
  final String thirteen;
  final String fourteen;
  final String fifteen;
  final String sixteen;
  final String seventeen;
  final String eightTeen;
  final String nineteen;
  final String twenty;
  final String twentyOne;
  final String twentyTwo;
  final String twentyThree;
  final String twentyFour;
  final String twentyFive;
  final String twentySix;
  final String twentySeven;
  final String twentyEight;
  final String twentyNine;
  final String thirty;

  DataModel({
    required this.one,
    required this.two,
    required this.three,
    required this.four,
    required this.five,
    required this.six,
    required this.seven,
    required this.eight,
    required this.nine,
    required this.ten,
    required this.eleven,
    required this.twelve,
    required this.thirteen,
    required this.fourteen,
    required this.fifteen,
    required this.sixteen,
    required this.seventeen,
    required this.eightTeen,
    required this.nineteen,
    required this.twenty,
    required this.twentyOne,
    required this.twentyTwo,
    required this.twentyThree,
    required this.twentyFour,
    required this.twentyFive,
    required this.twentySix,
    required this.twentySeven,
    required this.twentyEight,
    required this.twentyNine,
    required this.thirty,
  });

  static DataModel fromSnapshot(DocumentSnapshot snap) {
    return DataModel(
      one: snap.get('1'),
      two: snap.get('2'),
      three: snap.get('3'),
      four: snap.get('4'),
      five: snap.get('5'),
      six: snap.get('6'),
      seven: snap.get('7'),
      eight: snap.get('8'),
      nine: snap.get('9'),
      ten: snap.get('10'),
      eleven: snap.get('11'),
      twelve: snap.get('12'),
      thirteen: snap.get('13'),
      fourteen: snap.get('14'),
      fifteen: snap.get('15'),
      sixteen: snap.get('16'),
      seventeen: snap.get('17'),
      eightTeen: snap.get('18'),
      nineteen: snap.get('19'),
      twenty: snap.get('20'),
      twentyOne: snap.get('21'),
      twentyTwo: snap.get('22'),
      twentyThree: snap.get('23'),
      twentyFour: snap.get('24'),
      twentyFive: snap.get('25'),
      twentySix: snap.get('26'),
      twentySeven: snap.get('27'),
      twentyEight: snap.get('28'),
      twentyNine: snap.get('29'),
      thirty: snap.get('30'),
    );
  }
}
