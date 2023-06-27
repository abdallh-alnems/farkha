import 'package:farkha_app/routes/routes.dart';
import 'package:farkha_app/utils/theme.dart';

import 'package:farkha_app/view/widget/home/circle_master/master_list.dart';
import 'package:farkha_app/view/widget/drawer/my_drawer.dart';
import 'package:farkha_app/view/widget/home/continar_almost.dart';
import 'package:farkha_app/view/widget/home/table_home/table_home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:launch_review/launch_review.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          drawer: Drawer(
            width: MediaQuery.of(context).size.width * 0.7,
            child: MyDrawer(),
          ),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: scaColor,
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Text(DateFormat('y/MM/dd').format(DateTime.now())),
                ),
              )
            ],
          ),
          body: Column(
            children: [
              MasterList(),             
              ContinarAlmost(),
             Expanded(child: TableHome())
            ],
          )),
    );
  }
}
