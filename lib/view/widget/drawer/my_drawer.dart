import 'package:farkha_app/routes/routes.dart';
import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/drawer/list_title_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: scaColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 10,
            top: 20,
            bottom: 20,
          ),
          child: Column(children: [
            ListTitleDrawer(
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
                    'هذه الميزة لم تفعل بعد',
                    style: TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              title: '  توقعات',
              icon: Icons.timeline,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.alida);
              },
              title: 'الاضاءه',
              icon: Icons.wb_incandescent,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.dartgetAl7rara);
              },
              title: 'درجات الحرارة',
              icon: Icons.thermostat,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.alrotoba);
              },
              title: 'الرطوبه',
              icon: Icons.water_drop,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.alsaf);
              },
              title: 'الصيف',
              icon: Icons.wb_sunny,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.alshata);
              },
              title: 'الشتاء',
              icon: Icons.ac_unit,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.altaganous);
              },
              title: 'التجانس',
              icon: Icons.layers,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.awzan);
              },
              title: 'اوزان',
              icon: Icons.adjust,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.asthlak);
              },
              title: 'استهلاك',
              icon: Icons.cable,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.solalat);
              },
              title: 'سلالات',
              icon: Icons.device_hub,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.alardya);
              },
              title: 'الارضية',
              icon: Icons.crop_square,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.amard);
              },
              title: 'امراض',
              icon: Icons.warning,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.a3ard);
              },
              title: 'اعراض',
              icon: Icons.delete_forever,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.aL3lag);
              },
              title: 'علاج',
              icon: Icons.local_pharmacy,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.nasa7a);
              },
              title: 'نصائح',
              icon: Icons.receipt,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.akhtaq);
              },
              title: 'اخطاء',
              icon: Icons.error,
            ),
            ListTitleDrawer(
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
                    'هذه الميزة لم تفعل بعد',
                    style: TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              title: 'مستلزمات',
              icon: Icons.radar,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.snackbar(
                  '',
                  '',
                  titleText: const Text(
                    '',
                    style:  TextStyle(fontSize: 0),
                    textAlign: TextAlign.center,
                  ),
                  messageText: const Text(
                    'هذه الميزة لم تفعل بعد',
                    style: TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              title: 'المزرعة',
              icon: Icons.home,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.tather);
              },
              title: 'تطهير',
              icon: Icons.cleaning_services,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.astaqbal);
              },
              title: 'استقبال',
              icon: Icons.check_box,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.ta7sen);
              },
              title: 'تحصينات',
              icon: Icons.security,
            ),
            ListTitleDrawer(
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
                    'هذه الميزة لم تفعل بعد',
                    style: TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              title: 'دورة',
              icon: Icons.cached,
            ),
           const Divider(
              color: Colors.white,
            ),
            ListTitleDrawer(
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
              color: Colors.white,
            ),
            ListTitleDrawer(
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
                    'هذه الميزة لم تفعل بعد',
                    style: TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              title: 'مساعدة',
              icon: Icons.help,
              color: Colors.blue,
            ),
            ListTitleDrawer(
              onTap: () {},
              title: 'قيمنا ',
              icon: Icons.star,
              color: Colors.yellow,
            ),
          ]),
        ),
      ),
    );
  }
}
