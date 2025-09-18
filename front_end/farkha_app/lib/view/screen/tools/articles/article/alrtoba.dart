import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../widget/ad/banner.dart';
import '../../../../widget/ad/native.dart';
import '../../../../widget/app_bar/custom_app_bar.dart';
import '../../../../widget/tools/articles/type_article.dart';

class Alrotoba extends StatelessWidget {
  const Alrotoba({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "الرطوبة"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: const Column(
                  children: [
                    TypeArticle(
                      type:
                          'تربية الفراخ البيضاء تحتاج إلى اهتمام كبير بمستوى الرطوبة في البيئة التي تعيش فيها، حيث يؤثر ارتفاع أو انخفاض الرطوبة على صحة الفراخ ونموها. فيما يلي نقاط مهمة حول الرطوبة في تربية الفراخ البيضاء:',
                    ),
                    AdNativeWidget(),
                    TypeArticle(
                      type:
                          '1- مستوى الرطوبة المناسب: يجب أن يتراوح مستوى الرطوبة في بيئة تربية الفراخ بين 50-70%، حيث إن ارتفاع الرطوبة يزيد من احتمالية ظهور الأمراض الفطرية والجراثيم، في حين يؤدي انخفاض الرطوبة إلى جفاف الجلد والأنسجة الحساسة للفراخ.',
                    ),
                    TypeArticle(
                      type:
                          '2- تهوية البيئة: يجب أن تكون البيئة التي تعيش فيها الفراخ مهواة جيدًا وتحتوي على نظام تهوية فعال، حيث يمكن للتهوية الجيدة التحكم في مستوى الرطوبة والحفاظ عليها في المستوى المناسب',
                    ),
                    TypeArticle(
                      type:
                          '3- استخدام الأرضيات المناسبة: يجب استخدام أرضيات مصنوعة من مواد تسمح بامتصاص الرطوبة وتسمح بتدفق الهواء، حيث يمكن لهذا النوع من الأرضيات الحفاظ على مستوى الرطوبة في المستوى المناسب وتجنب تراكم الرطوبة في البيئة التي تعيش فيها الفراخ.',
                    ),
                    TypeArticle(
                      type:
                          '4- تحديد مستوى الرطوبة: ينصح باستخدام جهاز قياس الرطوبة لتحديد مستوى الرطوبة في البيئة التي تعيش فيها الفراخ، وذلك للتحكم في مستوى الرطوبة والحفاظ على صحة ونمو الفراخ.',
                    ),
                    TypeArticle(
                      type:
                          '5- تنظيف البيئة وتجنب التراكمات: يجب تنظيف البيئة التي تعيش فيها الفراخ بانتظام وتجنب تراكمات المواد العضوية والرطوبة، حيث تزيد هذه التراكمات من مستوى الرطوبة في البيئة.',
                    ),
                    TypeArticle(
                      type:
                          'باختصار، يجب تحديد مستوى الرطوبة في بيئة تربية الفراخ البيضاء والحفاظ على مستواها في المستوى المناسب، وذلك من خلال تهوية البيئة واستخدام الأرضيات المناسبة وتنظيف البيئة بانتظام.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
