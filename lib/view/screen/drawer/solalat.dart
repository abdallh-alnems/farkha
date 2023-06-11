import 'package:farkha_app/view/widget/home/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Solalat extends StatelessWidget {
  const Solalat({super.key});

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
                  child: Column(children: [
                    TypeDrawer(
                      type:
                          'تعتبر تربية الفراخ البيضاء أحد الأنشطة الزراعية الرئيسية في مصر، حيث تمتلك البلاد الإمكانيات الطبيعية والبشرية المناسبة لتحقيق هذا النوع من الإنتاج الداجني. وتتوفر في مصر عدة سلالات من الفراخ البيضاء، والتي تختلف في مجالات مثل النمو، الإنتاجية، وجودة اللحم والبيض  \n وفيما يلي نلقي نظرة على بعض السلالات الأكثر شيوعًا في مصر:.',
                    ),
                    Text('سلالة روس البيضاء (الاشهر)'),
                    TypeDrawer(
                      type:
                          'تعدّ هذه السلالة من أشهر سلالات الفراخ البيضاء في مصر، وهي ذات جودة عالية في الإنتاجية وسرعة النمو. وتصل وزن الفرخ من هذه السلالة إلى المستوى المطلوب، ما يجعلها مناسبة جدًا لتربية الدواجن للحصول على اللحوم البيضاء. ',
                    ),
                    Text('سلالة كوب'),
                    TypeDrawer(
                      type:
                          'تمتلك سلالة كوب خصائص مماثلة لسلالة هبارد، حيث يمكن تربيتها في ظروف صعبة، وهي تنتج كمية كبيرة من  واللحم. وتمتلك هذه السلالة نسبة عالية من الأحماض الأمينية الضرورية للجسم البشري، مما يجعلها مفضلة للأشخاص الذين يهتمون بالصحة.',
                    ),
                    Text('سلالة هاي لاين'),
                    TypeDrawer(
                      type:
                          'تعتبر سلالة هاي لاين من السلالات الأكثر شهرة في العالم، وهي مستوردة من الدول الأوروبية. وتمتاز بنمو سريع وإنتاجية عالية في اللحم  وتستخدم بشكل واسع في مصر لإنتاج اللحم الابيض .',
                    ),
                    Text('سلالة كوب 500'),
                    TypeDrawer(
                      type:
                          'تمثل سلالة كوب 500 من السلالات الحديثة التي تم تدشينها في مصر، وهي تعتبر من السلالات الهجينة التي تتميز بإنتاجية عالية في اللحم والبيض. وتتميز هذه السلالة بقدرتها على التحمل في ظروف المناخ الصعبة، وتعتبر مثالية للمزارعين الذين يرغبون في تحقيق الأرباح العالية.',
                    ),
                  ]))
            ],
          ),
        ),
      ),
    );
  }
}
