import '../../widget/ad/banner/ad_all_banner.dart';
import 'package:farkha_app/view/widget/drawer/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/drawer/divider_drawer.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/title_drawer.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
                    TypeDrawer(
                      type:
                          'تعتبر الأرضية من أهم العوامل التي يجب الانتباه إليها في تربية الفراخ البيضاء   حيث تؤثر بشكل كبير على صحة وراحة الدجاج وإنتاجيتهم. وبالتالي، يجب اختيار الأرضية المناسبة التي تتناسب مع احتياجات الدجاج ومتطلباتهم.وفيما يلي نقاط يجب اتخاذها بعين الاعتبار عند اختيار الأرضية لتربية الفراخ البيضاء  :',
                    ),
                    const TitleDrawer(title: 'نوع الأرضية'),
                    TypeDrawer(
                      type:
                          'توجد عدة خيارات للأرضية المناسبة لتربية الفراخ البيضاء  وتشمل القش الشنارة والأرضيات البلاستيكية. ويجب اختيار الأرضية المناسبة التي تتوافق مع سلالة الفراخ وظروف البيئة المحيطة. ويفضل استخدام الأرضيات البلاستيكية لأنها مقاومة للبكتيريا والفطريات وتساعد في تنظيف الأرضية بشكل أسهل وأكثر فعالية.',
                    ),
                    const DividerDrawer(),
                    const TitleDrawer(title: 'النظافة'),
                    TypeDrawer(
                      type:
                          'يجب الحرص على نظافة الأرضية بشكل دوري ومنتظم، حيث يمكن تكوين بكتيريا وفطريات على الأرضية والتي يمكن أن تؤثر بشكل سلبي على صحة الدجاج. ويجب تنظيف الأرضية بالماء والصابون وتطهيرها باستخدام المواد المعقمة.',
                    ),
                    const DividerDrawer(),
                    const TitleDrawer(title: 'الحجم'),
                    TypeDrawer(
                      type:
                          'يجب اختيار الأرضية المناسبة حسب عدد الفراخ وحجمها، حيث يجب توفير مساحة كافية للفراخ للحركة والتنقل والنمو. ويجب تجنب تجميع الفراخ في مساحات صغيرة جداً، حيث يؤدي ذلك إلى ارتفاع مستوى التوتر والإجهاد لديهم وتأثير سلبي على صحتهم وإنتاجيتهم.',
                    ),
                    const DividerDrawer(),
                    const TitleDrawer(title: 'الراحة'),
                    TypeDrawer(
                      type:
                          'يجب الحرص على توفير الراحة للفراخ عند اختيار الأرضية، حيث يجب أن تكون الأرضية ناعمة وخالية من العوائق والأشياء الحادة التي يمكن أن تؤذي الدجاج. ويمكن استخدام الرمل أو القش لزيادة الراحة وتقليل الاحتكاك بين الأرضية والأرجل.',
                    ),
                    const DividerDrawer(),
                    const TitleDrawer(title: 'الحماية'),
                    TypeDrawer(
                      type:
                          'يجب توفير الحماية للفراخ على الأرضية، حيث يمكن تعرضها للهجوم من الحيوانات المفترسة ويمكن استخدام الشبك الحديدي أو الأسلاك الشائكة لتأمين المكان وحماية الفراخ',
                    ),
                    const DividerDrawer(),
                    const TitleDrawer(title: 'التكلفة'),
                    TypeDrawer(
                      type:
                          'يجب اختيار الأرضية التي تتوافق مع الميزانية المتاحة لتربية الفراخ، حيث يمكن أن يكون تكلفة بعض الأرضيات مرتفعة جداً وغير متاحة للجميع. ويجب الاستفادة من الخيارات المتاحة والمناسبة لتوفير الأرضية الملائمة لتربية الفراخ بأفضل صورة ممكنة.',
                    ),
                    const DividerDrawer(),
                    const TitleDrawer(title: 'النشاره'),
                    TypeDrawer(
                      type:
                          'فرش الارضيه بالنشاره فى الصيف بسمك 5 سم وفى الشتاء 10 سم.',
                    ),
                  ]))
            ],
          ),
        ),
        bottomNavigationBar: AdAllBanner(),
      ),
    );
  }
}
