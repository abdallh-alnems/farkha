import 'package:farkha_app/routes/routes.dart';
import 'package:farkha_app/utils/theme.dart';

import 'package:farkha_app/view/widget/home/circle_master/master_list.dart';
import 'package:farkha_app/view/widget/home/container_price/container_price.dart';
import 'package:farkha_app/view/widget/home/drawer/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
       drawer: Drawer(
              width: MediaQuery.of(context).size.width * 0.7,
              child: MyDrawer(),
            ),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: scaColor,
        ),
        body: Column(
          children: [MasterList(), ContainerPrice()],
        )

        // MasterList(),
        );
  }
}
