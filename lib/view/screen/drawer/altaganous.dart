import 'package:farkha_app/view/widget/home/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Altaganous extends StatelessWidget {
  const Altaganous({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(left: 3),
                  alignment: Alignment.bottomLeft,
                  child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        size: 28,
                      ))),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TypeDrawer(
                        type:
                            'تربية الفراخ البيضاء في التجانس في الأحجام هو عملية تحقيق توازن مثالي في الحجم بين الفراخ المختلفة في المزرعة وهو يعتبر عاملاً هاماً في تحقيق الإنتاجية والأرباح المرتبطة بتربية الفراخ. إليك بعض النقاط التي يمكن توسيعها في هذا الموضوع:'),
                    TypeDrawer(
                        type:
                            '1- التحكم في وزن الفراخ: يجب مراقبة وزن الفراخ بشكل دوري وتقييم أحجامها، ويمكن استخدام أدوات الوزن الخاصة بالفراخ لتحقيق ذلك.'),
                    TypeDrawer(
                        type:
                            '2- الاهتمام بمستوى التغذية: يجب توفير كمية كافية من الطعام والمياه النظيفة والصحية للفراخ، وذلك لتحقيق نمو متساوٍ بين الفراخ.'),
                    TypeDrawer(
                        type:
                            '3- توفير مساحة كافية: يجب توفير مساحة كافية للفراخ للتحرك والتمدد وتجنب التزاحم، ويمكن تخصيص مساحات خاصة للعب والتسلية.'),
                    TypeDrawer(
                        type:
                            '4- الاهتمام بنوعية الفراخ: يجب اختيار فراخ صحية وذات جودة عالية لضمان نمو صحي وإنتاجية جيدة، ويمكن الحصول على الفراخ ذات الحجم المتجانس عن طريق اختيار نوعيات فراخ معينة ذات خصائص وراثية متجانسة.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
