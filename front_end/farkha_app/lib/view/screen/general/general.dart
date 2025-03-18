import 'package:farkha_app/core/constant/image_asset.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/package/snackbar_utils.dart';
import '../../../core/services/open_gmail.dart';
import '../../widget/ad/banner.dart';
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
            title: 'البريد الإلكتروني',
            icon: Icons.mail,
          ),
          GeneralItem(
            onTap: () => Get.toNamed(AppRoute.suggestion),
            title: 'اقتراح',
            icon: Icons.lightbulb,
          ),
          GeneralItem(
            onTap: () {
              SnackbarUtils.showSnackbar();
            },
            title: 'الموقع الالكتروني',
            icon: Icons.web_asset,
          ),
          GeneralItem(
            onTap: () {
              SnackbarUtils.showSnackbar();
            },
            title: 'من نحن',
            icon: Icons.group,
          ),
          GeneralItem(
            onTap: () {
              SnackbarUtils.showSnackbar();
            },
            title: 'مساعدة',
            icon: Icons.help,
            color: Colors.blue,
          ),
          GeneralItem(
            onTap: () {
            SnackbarUtils.showSnackbar();
            },
            title: 'قيمنا ',
            icon: Icons.star,
            color: Colors.yellow,
          ),
          SizedBox(height: 33),
          Text("تابعنا"),
          SizedBox(height: 17),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 79),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse(
                        'https://www.facebook.com/share/19u7rfbpcY/'));
                  },
                  child: Image.asset(
                    ImageAsset.facebook,
                    scale: 4.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse('https://nims.website/'));
                  },
                  child: Image.asset(
                    ImageAsset.web,
                    scale: 4.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse(
                        'https://whatsapp.com/channel/0029Vb3K1qa9xVJYrMm7fM3E'));
                  },
                  child: Image.asset(
                    ImageAsset.whatsApp,
                    scale: 4.5,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(adIndex: 1),
    );
  }
}
