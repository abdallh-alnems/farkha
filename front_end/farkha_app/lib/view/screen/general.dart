import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:launch_review/launch_review.dart';
import '../../core/shared/custom_divider.dart';
import '../widget/ad/banner/ad_first_banner.dart';
import '../widget/ad/banner/ad_second_banner.dart';
import '../widget/app_bar/custom_app_bar.dart';
import '../widget/general/general_item.dart';

class General extends StatelessWidget {
  const General({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "عام",
            arrowDirection: false,
          ),
          GeneralItem(
            onTap: () {
              Get.snackbar(
                '',
                '',
                titleText: const Text(
                  '',
                  style: TextStyle(fontSize: 0),
                  textAlign: TextAlign.center,
                ),
                messageText: const Text(
                  'قريبا',
                  style: TextStyle(fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              );
            },
            title: 'مشاركة التطبيق',
            icon: Icons.share,
          ),
          GeneralItem(
            onTap: () {
              Get.snackbar(
                '',
                '',
                titleText: const Text(
                  '',
                  style: TextStyle(fontSize: 0),
                  textAlign: TextAlign.center,
                ),
                messageText: const Text(
                  'قريبا',
                  style: TextStyle(fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              );
            },
            title: 'تواصل معنا',
            icon: Icons.message,
          ),
          GeneralItem(
            onTap: () {
              Get.snackbar(
                '',
                '',
                titleText: const Text(
                  '',
                  style: TextStyle(fontSize: 0),
                  textAlign: TextAlign.center,
                ),
                messageText: const Text(
                  'قريبا',
                  style: TextStyle(fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              );
            },
            title: 'اقتراح',
            icon: Icons.lightbulb,
          ),
          GeneralItem(
            onTap: () {
              Get.snackbar(
                '',
                '',
                titleText: const Text(
                  '',
                  style: TextStyle(fontSize: 0),
                  textAlign: TextAlign.center,
                ),
                messageText: const Text(
                  'قريبا',
                  style: TextStyle(fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              );
            },
            title: 'الموقع الالكتروني',
            icon: Icons.web_asset,
          ),
          GeneralItem(
            onTap: () {
              Get.snackbar(
                '',
                '',
                titleText: const Text(
                  '',
                  style: TextStyle(fontSize: 0),
                  textAlign: TextAlign.center,
                ),
                messageText: const Text(
                  'قريبا',
                  style: TextStyle(fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              );
            },
            title: 'من نحن',
            icon: Icons.group,
          ),
          GeneralItem(
            onTap: () {
              Get.snackbar(
                '',
                '',
                titleText: const Text(
                  '',
                  style: TextStyle(fontSize: 0),
                  textAlign: TextAlign.center,
                ),
                messageText: const Text(
                  'قريبا',
                  style: TextStyle(fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              );
            },
            title: 'مساعدة',
            icon: Icons.help,
            color: Colors.blue,
          ),
          GeneralItem(
            onTap: () {
              LaunchReview.launch();
            },
            title: 'قيمنا ',
            icon: Icons.star,
            color: Colors.yellow,
          ),
        ],
        
      ),
       bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
