import 'package:farkha_app/routes/routes.dart';
import 'package:farkha_app/view/widget/home/circle_master/circle_avatar.dart';
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
                Get.snackbar(
                  '',
                  '',
                  titleText: Text(
                    '',
                    style: TextStyle(fontSize: 0),
                    textAlign: TextAlign.center,
                  ),
                  messageText: Text(
                    'سيتم التفعيل قريبا',
                    style: TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                );
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
