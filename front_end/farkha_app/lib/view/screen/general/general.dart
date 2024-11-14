import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/services/open_gmail.dart';
import '../../widget/ad/banner/ad_second_banner.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/general/general_item.dart';

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
            onTap: () => Share.share(
                'حمل تطبيق فرخة \n https://play.google.com/store/apps/details?id=ni.nims.frkha'),
            title: 'مشاركة التطبيق',
            icon: Icons.share,
          ),
          GeneralItem(
            onTap: () => openGmail(),
            title: 'تواصل معنا',
            icon: Icons.message,
          ),
          GeneralItem(
            onTap: () => Get.toNamed(AppRoute.suggestion),
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
          ElevatedButton(
              onPressed: () {
           
              },
              child: Text("data"))
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
