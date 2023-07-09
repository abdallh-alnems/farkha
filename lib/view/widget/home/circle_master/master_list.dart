import 'package:farkha_app/routes/routes.dart';
import 'package:farkha_app/view/widget/home/circle_master/circle_avatar.dart';
import 'package:farkha_app/view/widget/home/circle_master/show_dialog/frakh_dialog.dart';
import 'package:farkha_app/view/widget/home/circle_master/show_dialog/my_dialogWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MasterList extends StatelessWidget {
  const MasterList({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 110,
        child: Row(
          children: [
           const SizedBox(
              width: 15,
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return FrakhDialogWidget(
                      onPressed1: () {
                        Get.toNamed(Routes.frakhAbid);
                      },
                      text1: 'فرخ ابيض ',
                      onPressed2: () {
                        Get.toNamed(Routes.frakhSasso);
                      },
                      text2: 'فرخ ساسو',
                      onPressed3: () {
                        Get.toNamed(Routes.frakhBaladi);
                      },
                      text3: ' فرخ بلدي',
                      onPressed4: () {
                        Get.toNamed(Routes.frakhAmhitAbid);
                      },
                      text4: 'فرخ امهات ابيض',
                    );
                  },
                );
              },
              child: CircleAvatarHome(
                type: 'فراخ',
              ),
            ),
          const  SizedBox(
              width: 25,
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MyDialogWidget(
                      onPressed1: () {
                        Get.toNamed(Routes.katKitAbid);
                      },
                      text1: 'كتاكيت ابيض',
                      onPressed2: () {
                        Get.toNamed(Routes.katkitSasso);
                      },
                      text2: 'كتاكيت ساسو',
                      onPressed3: () {
                        Get.toNamed(Routes.katkitBaladi);
                      },
                      text3: ' كتاكيت بلدي',
                    );
                  },
                );
              },
              child: CircleAvatarHome(
                type: 'كتاكيت',
              ),
            ),
           const SizedBox(
              width: 25,
            ),
            InkWell(
              onTap: () {
                Get.toNamed(Routes.a3laf);
              },
              child: CircleAvatarHome(
                type: 'أعلاف',
              ),
            ),
           const SizedBox(
              width: 25,
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MyDialogWidget(
                      onPressed1: () {
                        Get.toNamed(Routes.bydAbid);
                      },
                      text1: 'بيض ابيض',
                      onPressed2: () {
                        Get.toNamed(Routes.bydAihmar);
                      },
                      text2: 'بيض احمر',
                      onPressed3: () {
                        Get.toNamed(Routes.bydBaladi);
                      },
                      text3: ' بيض بلدي',
                    );
                  },
                );
              },
              child: CircleAvatarHome(
                type: 'بيض',
              ),
            ),
          const  SizedBox(
              width: 25,
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MyDialogWidget(
                      onPressed1: () {
                        Get.toNamed(Routes.batMolar);
                      },
                      text1: 'بط مولار',
                      onPressed2: () {
                        Get.toNamed(Routes.batFiransawi);
                      },
                      text2: 'بط فرنساوي',
                      onPressed3: () {
                        Get.toNamed(Routes.batMaskufi);
                      },
                      text3: ' بط مسكوفي',
                    );
                  },
                );
              },
              child: CircleAvatarHome(
                type: 'بط',
              ),
            ),
          const  SizedBox(
              width: 15,
            ),
          ],
        ),
      ),
    );
  }
}
