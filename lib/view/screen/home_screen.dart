import 'package:farkha_app/logic/controller/data_controller.dart';
import 'package:farkha_app/view/widget/home/card_home/card_data.dart';
import 'package:farkha_app/view/widget/home/card_home/card_list.dart';
import 'package:farkha_app/view/widget/home/circle_master/master_list.dart';
import 'package:farkha_app/view/widget/home/test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(),
        appBar: AppBar(),
        body: Column(
          children: [
            MasterList(),
            
            Expanded(
              child: CardList(),
            ),
          ],
        )

        // MasterList(),
        );
  }
}
