import 'package:farkha_app/view/widget/home/circle_master/card_data/card_data.dart';
import 'package:farkha_app/view/widget/home/circle_master/master_list.dart';
import 'package:farkha_app/view/widget/home/container_price/container_price.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        drawer: Drawer(
          backgroundColor: Colors.white,
          width: MediaQuery.of(context).size.width * 0.6,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 15, top: 35, bottom: 20),
              child: Column(children: [
                ListTile(
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
                  title: Text(
                    'توقعات',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.timeline,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'درجات الحرارة',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.thermostat,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'اوزان',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.adjust,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'سلالات',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.device_hub,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'امراض',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.bug_report,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'ادويه',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.local_pharmacy,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'نصائح',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.receipt,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'اخطاء',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.error,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'المزرعة',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.home,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'تطهير',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.cleaning_services,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'استقبال',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.check_box,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'تحصينات',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.security,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'تاكيل',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.grain,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'خلطات',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.compare_arrows,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'دورة',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.cached,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'من نحن',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.group,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
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
                  title: Text(
                    'مساعدة',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.help,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'قيمنا ',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: Icon(
                    Icons.star,
                    size: 25,
                    color: Colors.yellow,
                  ),
                ),
              ]),
            ),
          ),
        ),
        appBar: AppBar(),
        body: Column(
          children: [MasterList(), ContainerPrice()],
        )

        // MasterList(),
        );
  }
}
