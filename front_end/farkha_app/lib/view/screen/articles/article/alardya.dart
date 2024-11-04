import '../../../widget/ad/banner/ad_second_banner.dart';
import 'package:farkha_app/view/widget/follow_up_tools/articles/articles/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/follow_up_tools/articles/articles/divider_drawer.dart';
import 'package:farkha_app/view/widget/follow_up_tools/articles/articles/text_article/title_article.dart';
import '../../../widget/follow_up_tools/articles/articles/text_article/type_article.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../widget/ad/banner/ad_third_banner.dart';

class Alardya extends StatelessWidget {
  const Alardya({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ArrowBack(),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    TypeArticle(
                      type:
                          'تعتبر الأرضية من أهم العوامل التي يجب الانتباه إليها في تربية الفراخ البيضاء   حيث تؤثر بشكل كبير على صحة وراحة الدجاج وإنتاجيتهم. وبالتالي، يجب اختيار الأرضية المناسبة التي تتناسب مع احتياجات الدجاج ومتطلباتهم.وفيما يلي نقاط يجب اتخاذها بعين الاعتبار عند اختيار الأرضية لتربية الفراخ البيضاء  :',
                    ),
                    const TitleArticle(title: 'نوع الأرضية'),
                    TypeArticle(
                      type:
                          'توجد عدة خيارات للأرضية المناسبة لتربية الفراخ البيضاء  وتشمل القش الشنارة والأرضيات البلاستيكية. ويجب اختيار الأرضية المناسبة التي تتوافق مع سلالة الفراخ وظروف البيئة المحيطة. ويفضل استخدام الأرضيات البلاستيكية لأنها مقاومة للبكتيريا والفطريات وتساعد في تنظيف الأرضية بشكل أسهل وأكثر فعالية.',
                    ),
                    const DividerDrawer(),
                    const TitleArticle(title: 'النظافة'),
                    TypeArticle(
                      type:
                          'يجب الحرص على نظافة الأرضية بشكل دوري ومنتظم، حيث يمكن تكوين بكتيريا وفطريات على الأرضية والتي يمكن أن تؤثر بشكل سلبي على صحة الدجاج. ويجب تنظيف الأرضية بالماء والصابون وتطهيرها باستخدام المواد المعقمة.',
                    ),
                    const DividerDrawer(),
                    const TitleArticle(title: 'الحجم'),
                    TypeArticle(
                      type:
                          'يجب اختيار الأرضية المناسبة حسب عدد الفراخ وحجمها، حيث يجب توفير مساحة كافية للفراخ للحركة والتنقل والنمو. ويجب تجنب تجميع الفراخ في مساحات صغيرة جداً، حيث يؤدي ذلك إلى ارتفاع مستوى التوتر والإجهاد لديهم وتأثير سلبي على صحتهم وإنتاجيتهم.',
                    ),
                    const DividerDrawer(),
                    const TitleArticle(title: 'الراحة'),
                    TypeArticle(
                      type:
                          'يجب الحرص على توفير الراحة للفراخ عند اختيار الأرضية، حيث يجب أن تكون الأرضية ناعمة وخالية من العوائق والأشياء الحادة التي يمكن أن تؤذي الدجاج. ويمكن استخدام الرمل أو القش لزيادة الراحة وتقليل الاحتكاك بين الأرضية والأرجل.',
                    ),
                    const DividerDrawer(),
                    const TitleArticle(title: 'الحماية'),
                    TypeArticle(
                      type:
                          'يجب توفير الحماية للفراخ على الأرضية، حيث يمكن تعرضها للهجوم من الحيوانات المفترسة ويمكن استخدام الشبك الحديدي أو الأسلاك الشائكة لتأمين المكان وحماية الفراخ',
                    ),
                    const DividerDrawer(),
                    const TitleArticle(title: 'التكلفة'),
                    TypeArticle(
                      type:
                          'يجب اختيار الأرضية التي تتوافق مع الميزانية المتاحة لتربية الفراخ، حيث يمكن أن يكون تكلفة بعض الأرضيات مرتفعة جداً وغير متاحة للجميع. ويجب الاستفادة من الخيارات المتاحة والمناسبة لتوفير الأرضية الملائمة لتربية الفراخ بأفضل صورة ممكنة.',
                    ),
                    const DividerDrawer(),
                    const TitleArticle(title: 'النشاره'),
                    TypeArticle(
                      type:
                          'فرش الارضيه بالنشاره فى الصيف بسمك 5 سم وفى الشتاء 10 سم.',
                    ),
                  ]))
            ],
          ),
        ),
        bottomNavigationBar: AdThirdBanner(),
      ),
    );
  }
}
