import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/routes/route.dart';
import '../widget/ad/banner/ad_all_banner.dart';
import '../widget/ad/banner/ad_home_banner.dart';
import '../widget/ad/native/ad_home_native.dart';
import '../widget/app_bar/app_bar_home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHome(),
      drawer: Drawer(
        backgroundColor: Colors.red,
        child: Container(
          color: Colors.red,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: double.infinity,
              color: Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.arrow_outward),
                  Text("55"),
                  Text("56"),
                  Text("اللحم االابيض"),
                ],
              ),
            ),
          ),
           AdHomeNative(),
          Center(child: ElevatedButton(onPressed: (){Get.toNamed(AppRoute.test);}, child: Text("ad"))),
          //  ElevatedButton(onPressed: (){Get.toNamed(AppRoute.adad);}, child: Text("adad"))
        ],
      ),
               bottomNavigationBar: const AdHomeBanner(),

    );
  }
}
