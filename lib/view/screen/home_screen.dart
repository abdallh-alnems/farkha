import 'package:farkha_app/view/widget/home/card_item.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CardItem(
                type: 'الابيض',
              ),
              CardItem(
                type: 'الابيض',
              ),
              CardItem(
                type: 'الابيض',
              ),
              CardItem(
                type: 'الابيض',
              ),
              CardItem(
                type: 'الابيض',
              ),
              CardItem(
                type: 'الابيض',
              ),
              CardItem(
                type: 'الابيض',
              ),
              CardItem(
                type: 'الابيض',
              ),
              CardItem(
                type: 'الابيض',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
