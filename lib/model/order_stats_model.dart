import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:flutter/material.dart';

class OrderStats {
  final DateTime dateTime;
  final int index;
  final int orders;
  charts.Color? barColor;

  OrderStats(
      {required this.dateTime,
      required this.index,
      required this.orders,
      this.barColor}) {
    barColor = charts.ColorUtil.fromDartColor(Colors.black);
  }

  static final List<OrderStats> data = [
    OrderStats(
      dateTime: DateTime.now(),
      index: 0,
      orders: 10,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 1,
      orders: 16,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 2,
      orders: 13,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 3,
      orders: 11,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 4,
      orders: 24,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 5,
      orders: 12,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 6,
      orders: 21,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 7,
      orders: 19,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 8,
      orders: 27,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 9,
      orders: 30,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 10,
      orders: 30,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 11,
      orders: 30,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 12,
      orders: 25,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 15,
      orders: 50,
    ),
    OrderStats(
      dateTime: DateTime.now(),
      index: 14,
      orders: 35,
    ),
  ];
}
