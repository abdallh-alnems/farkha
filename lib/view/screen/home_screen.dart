import 'package:farkha_app/logic/controller/data_controller.dart';
import 'package:farkha_app/view/widget/home/card_data.dart';
import 'package:farkha_app/view/widget/home/card_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  DataController dataController = Get.put(DataController());
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
       
      appBar: AppBar(),
      body: CardList(),
      );
  }
}
