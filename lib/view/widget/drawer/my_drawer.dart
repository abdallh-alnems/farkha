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
          padding: EdgeInsets.only(
            left: 10,
            top: 35,
            bottom: 20,
          ),
          child: Column(children: [
            ListTitleDrawer(
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
                    'هذا الميزة لم تفعل بعد',
                    style: TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              title: '  توقعات',
              icon: Icons.timeline,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Alida);
              },
              title: 'الاضاءه',
              icon: Icons.wb_incandescent,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.DartgetAl7rara);
              },
              title: 'درجات الحرارة',
              icon: Icons.thermostat,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Alrotoba);
              },
              title: 'الرطوبه',
              icon: Icons.water_drop,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Alsaf);
              },
              title: 'الصيف',
              icon: Icons.wb_sunny,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Alshata);
              },
              title: 'الشتاء',
              icon: Icons.ac_unit,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Altaganous);
              },
              title: 'التجانس',
              icon: Icons.layers,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Awzan);
              },
              title: 'اوزان',
              icon: Icons.adjust,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Asthlak);
              },
              title: 'استهلاك',
              icon: Icons.cable,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Solalat);
              },
              title: 'سلالات',
              icon: Icons.device_hub,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Alardya);
              },
              title: 'الارضية',
              icon: Icons.crop_square,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Amard);
              },
              title: 'امراض',
              icon: Icons.warning,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.A3ard);
              },
              title: 'اعراض',
              icon: Icons.delete_forever,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.AL3lag);
              },
              title: 'علاج',
              icon: Icons.local_pharmacy,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Nasa7a);
              },
              title: 'نصائح',
              icon: Icons.receipt,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Akhtaq);
              },
              title: 'اخطاء',
              icon: Icons.error,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
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
                    'هذا الميزة لم تفعل بعد',
                    style: TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              title: 'مستلزمات',
              icon: Icons.radar,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
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
                    'هذا الميزة لم تفعل بعد',
                    style: TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              title: 'المزرعة',
              icon: Icons.home,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Tather);
              },
              title: 'تطهير',
              icon: Icons.cleaning_services,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Astaqbal);
              },
              title: 'استقبال',
              icon: Icons.check_box,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {
                Get.toNamed(Routes.Ta7sen);
              },
              title: 'تحصينات',
              icon: Icons.security,
              color: Colors.cyan,
            ),
            ListTitleDrawer(
              onTap: () {},
              title: 'دورة',
              icon: Icons.cached,
              color: Colors.cyan,
            ),
            Divider(
              color: Colors.white,
            ),
            ListTitleDrawer(
              onTap: () {},
              title: 'من نحن',
              icon: Icons.group,
              color: Colors.white,
            ),
            ListTitleDrawer(
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
                    'هذا الميزة لم تفعل بعد',
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


// ListTitleDrawer(onTap:(){} ,title:'' ,icon: ,color: ,),
