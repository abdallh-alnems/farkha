import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../widget/app/ad/native/ad_third_native.dart';
import '../../../../widget/app/app_bar/custom_app_bar.dart';
import '../../../../widget/app/follow_up_tools/articles/title_article.dart';
import '../../../../widget/app/follow_up_tools/articles/type_article.dart';
import 'package:flutter/material.dart';
import '../../../../widget/app/ad/banner/banner.dart';

class Amard extends StatelessWidget {
  const Amard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "امراض"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: const Column(children: [
                  TitleArticle(title: 'الماريك'),
                  TypeArticle(
                    type:
                        'مرض الماريك هو مرض فيروسي سرطاني خبيث كابت للمناعة يصب الدواجن ابتداء من عمر 6 أسابيع ولكنه ينتشر عاده في الدجاج البالغ ما بين 12-24 أسبوع وفترة حضانة المرض حوالي 6 أسابيع والمرض وبائي شديد العدوه حيث تصل نسبه النفوق في القطعان الغير محصنه إلى حوالي 10-30% وقد تصل أحيانا إلى 80%.',
                  ),
                  AdThirdNative(),
                  TitleArticle(title: 'النيوكاسل'),
                  TypeArticle(
                    type:
                        'يعد النيوكاسل من الأمراض الفيروسية الوبائية السريعة الانتشار والتي تسبب خسائر فادحه للمربى وهو يعد من أهم الأمراض التي يحاذر منها المربين في مصر حيث أن هذا الفيروس له القدرة على إحداث الإصابة بالقطيع إلى 100% وكذلك نسبه النفوق إلى 100% والفيروس لديه القدرة على إصابة الدجاج والرومي حيث أنها أكثر الأنواع عرضه لهذا المرض كما أن كلا من الحمام والبط والإوز يصاب بالمرض ولكن بدرجه أقل والإنسان عندما يتعرض لفيروس النيوكاسل تظهر عليه أثار مرضيه في العين وهو ما يسمى ( العين الحمراء ) وتنتشر تلك الظاهرة بين العمال بالمزارع المصابة بهذا المرض . والفيروس له القدرة العالية على الحفاظ على حياته لمده ثلاثة شهور حيا في ذبائح الطيور المصابة والمحفوظة في الثلاجة على درجه صفر مئوي ولكن يحدث العكس عند رفع درجه الحرارة حيث لا يمكنه المعيشة لأكثر من دقائق معدودة إذا تعرض لدرجه حرارة 50م كما وجد أن بعض المطهرات كالفورمالين والفينول لهم القدرة على فقد الفيروس لحيويته وقتله. وتتراوح مده حضانة المرض ما بين 2 - 18 يوم حسب ضرورة الفيروس.',
                  ),
                  TitleArticle(title: 'الالتهاب الشعبي المعدي'),
                  TypeArticle(
                    type:
                        'مرض فيروسي وهو يصيب الدجاج فقط ولا يصيب آي من الطيور الداجنة الأخرى وتتراوح فتره الحضانة للمرض ما بين 18 - 36 ساعة ومده المرض تكون من 2-6 يوم وتظهر الأعراض على الطيور التي يقل عمرها عن ثلاثة شهور حيث ترتفع نسبه النفوق لحوالي 25% والطيور التي أصيبت بالمرض وشفيت منه تظل حامله للمناعة طوال عمرها وتنقلها لنسلها عن طريق البيض.',
                  ),
                  TitleArticle(title: 'الجامبورو'),
                  TypeArticle(
                    type:
                        'مرض فيروسي يصيب الدجاج في الأعمار المبكرة ويؤثر على الأنسجة الليمفاوية لحوصلة فابرشيوس والمرض يظهر غالبا في عمر 3-6 أسابيع وتمكن خطورة هذا المرض في أنه يحدث التهاب في غده فابرشيوس المسئولة عن تكوين المناعة في الأسابيع الأولى من العمر عندما تكون في قمه نموها ونشاطها وبذلك يختل نظام المناعة في الطائر ويضعف مقاومته ويجعله معرضا لكثير من الأمراض الفيروسية أو البكتيرية الأخرى مما جعل الكثير يطلق عليه (ايدز الدجاج ) وفترة حضانة المرض من 5 - 10 أيام ومدة المرض من 8 - 10 أيام تقريبا.',
                  ),
                  TitleArticle(title: 'الجدري'),
                  TypeArticle(
                    type:
                        'مرض الجدري يصيب الدجاج والرومي والطيور البرية وهو فيروس ينتقل بواسطة البعوض أو غيره من الحشرات ومن خلال الجروح والقروح الجلدية وبذلك تكون الجروح الناتجة عن ظاهره الافتراس من العوامل المساعدة على ذلك ويبقى الفيروس في البثور الجافة لمدة طويلة من الزمن قد تتعدى العشرة سنوات ويتحمل درجه حرارة 60 م لمده 80 دقيقة ولذلك يجب التنظيف والتطهير بصورة جيده وفعاله بعد الإصابة بمرض الجدري. فتره النفوق تكون منخفضة والطيور التي تشفي من المرض تظل حامله للمناعة طوال عمرها.',
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(adIndex: 2),
    );
  }
}
