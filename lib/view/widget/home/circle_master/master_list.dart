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
      child: Container(
        height: 150,
        child: Row(
          children: [
            SizedBox(
              width: 15,
            ),
            InkWell(
              onTap: () {
                 showDialog(
                  context: context,
                  builder: (context) {
                    return FrakhDialogWidget(
                      onPressed1: () {
                        Get.toNamed(Routes.FrakhAbid);
                      },
                      text1: 'فراخ بيضاء ',
                      onPressed2: () {
                        Get.toNamed(Routes.FrakhSasso);
                      },
                      text2: 'فراخ ساسو',
                      onPressed3: () {
                         Get.toNamed(Routes.FrakhBaladi);
                      },
                      text3: ' فراخ بلدي',
                      onPressed4: (){
                         Get.toNamed(Routes.FrakhAmhitAbid);
                      },
                      text4: 'فراخ امهات ابيض',
                    );
                  },
                );
              },
              child: CircleAvatarHome(
                type: 'فراخ',
              ),
            ),
            SizedBox(
              width: 25,
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MyDialogWidget(
                      onPressed1: () {
                        Get.toNamed(Routes.KatKitAbid);
                      },
                      text1: 'كتاكيت ابيض',
                      onPressed2: () {
                        Get.toNamed(Routes.KatkitSasso);
                      },
                      text2: 'كتاكيت ساسو',
                      onPressed3: () {
                         Get.toNamed(Routes.KatkitBaladi);
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
            SizedBox(
              width: 25,
            ),
            InkWell(
              onTap: () {
              Get.toNamed(Routes.A3laf);
              },
              child: CircleAvatarHome(
                type: 'اعلاف',
              ),
            ),
            SizedBox(
              width: 25,
            ),
            InkWell(
              onTap: () {
                  showDialog(
                  context: context,
                  builder: (context) {
                    return MyDialogWidget(
                      onPressed1: () {
                        Get.toNamed(Routes.BydAbid);
                      },
                      text1: 'بيض ابيض',
                      onPressed2: () {
                        Get.toNamed(Routes.BydAihmar);
                      },
                      text2: 'بيض احمر',
                      onPressed3: () {
                         Get.toNamed(Routes.BydBaladi);
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
            SizedBox(
              width: 25,
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MyDialogWidget(
                      onPressed1: () {
                        Get.toNamed(Routes.BatMolar);
                      },
                      text1: 'بط مولار',
                      onPressed2: () {
                        Get.toNamed(Routes.BatFiransawi);
                      },
                      text2: 'بط فرنساوي',
                      onPressed3: () {
                         Get.toNamed(Routes.BatMaskufi);
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
            SizedBox(
              width: 15,
            ),
          ],
        ),
      ),
    );
  }
}
