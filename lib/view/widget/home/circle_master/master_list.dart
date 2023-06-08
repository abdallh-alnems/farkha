import 'package:farkha_app/routes/routes.dart';
import 'package:farkha_app/view/widget/home/circle_master/circle_avatar.dart';
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
                Get.toNamed(Routes.FrakhType);
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
                Get.toNamed(Routes.KatkitType);
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
                Get.toNamed(Routes.A3lafType);
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
                Get.toNamed(Routes.BydType);
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
                Get.toNamed(Routes.BatType);
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
