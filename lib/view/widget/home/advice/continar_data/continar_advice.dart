import 'package:farkha_app/routes/routes.dart';
import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/home/advice/continar_data/adivce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContinarAdvice extends StatelessWidget {
  const ContinarAdvice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      color: scaColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: (){
Scaffold.of(context).openDrawer();
            },
            child: const Advice(
              text: 'الكل',
              icon: Icons.all_inbox,
            ),
          ),
          InkWell(
             onTap: (){
                              Get.toNamed(Routes.dartgetAl7rara);
            },
            child: const Advice(
              text: 'درجات الحرارة',
              icon: Icons.thermostat,
            ),
          ),
          InkWell(
             onTap: (){
                              Get.toNamed(Routes.awzan);

            },
            child: const Advice(
              text: 'أوزان',
              icon: Icons.adjust,
            ),
          ),
          InkWell(
             onTap: (){
                              Get.toNamed(Routes.nasa7a);

            },
            child: const Advice(
              text: 'نصائح',
              icon: Icons.receipt,
            ),
          ),
          InkWell(
             onTap: (){
                              Get.toNamed(Routes.ta7sen);

            },
            child: const Advice(
              text: 'تحصينات',
              icon: Icons.security,
            ),
          ),
        ],
      ),
    );
  }
}
