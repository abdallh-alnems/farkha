import 'package:farkha_app/logic/controller/ad/admob_controller.dart';
import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/home/advice/advice_home.dart';
import 'package:farkha_app/view/widget/home/circle_master/master_list.dart';
import 'package:farkha_app/view/widget/drawer/my_drawer.dart';
import 'package:farkha_app/view/widget/home/table_home/table_home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
    

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdController>();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.7,
          child: const MyDrawer(),
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
          children: const [
            MasterList(),
            AdviceScroll(),
            Expanded(child: TableHome()),
          ],
        ),
        bottomNavigationBar: GetBuilder<AdController>( 
          builder: (_) {
          return adController.isAdLoaded
              ? SizedBox(
                  height: adController.bannerAd.size.height.toDouble(),
                  width: adController.bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: adController.bannerAd),
                )
              : const SizedBox();
        }),
      ),
    );
  }
}