import 'package:farkha_app/model/order_stats_model.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 250,
              padding: const EdgeInsets.all(10),
              child: CustomBarChart(
                orderStats: OrderStats.data,
              ),
            ),
            Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: InkWell(
                onTap: () {},
                child: const Card(
                  child: Center(
                    child: Text('Go to products'),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomBarChart extends StatelessWidget {
  const CustomBarChart({super.key, required this.orderStats});
  final List<OrderStats> orderStats;
  @override
  Widget build(BuildContext context) {
    List<charts.Series<OrderStats, String>> series = [
      charts.Series(
        id: 'order',
        data: orderStats,
        domainFn: (series, _) => series.index.toString(),
        measureFn: (series, _) => series.orders,
      )
    ];
    return charts.BarChart(
      series,
      animate: true,
    );
  }
}
