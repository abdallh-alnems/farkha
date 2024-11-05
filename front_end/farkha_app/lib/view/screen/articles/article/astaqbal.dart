import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widget/ad/banner/ad_second_banner.dart';
import 'package:farkha_app/view/widget/follow_up_tools/articles/text_article/title_article.dart';
import '../../../widget/ad/native/ad_third_native.dart';
import '../../../widget/app_bar/custom_app_bar.dart';
import '../../../widget/follow_up_tools/articles/text_article/type_article.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../widget/ad/banner/ad_third_banner.dart';

class Astaqbal extends StatelessWidget {
  const Astaqbal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "استقبال",
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15).r,
              child: SingleChildScrollView(
                child: Column(children: [
                  const TitleArticle(title: 'قبل استقبال الكتاكيت'),
                  TypeArticle(
                    type: 'ازاله الفرشه السابقه واستبدالها بفرشه جديده نظيفه.',
                  ),
                  TypeArticle(
                    type: 'تنظيف اللمبات وتغير اللمبات غير الصالحه',
                  ),
                  TypeArticle(
                    type:
                        ' تنظيف أجهزه التبريد والتدفئه ازاله جميع بقايا العلف السابق.',
                  ),
                  TypeArticle(
                    type:
                        ' اخراج المعالف والمساقى وتنظيفها وتطهيرها وتعريضها لاشاعه الشمس لقتل الامراض.',
                  ),
                  TypeArticle(
                    type:
                        ' تنظيف أجهزه التهويه ( المراوح , والقنوات الهوائيه , وفتحات التهويه , أجهزه التشغيل.',
                  ),
                  TypeArticle(
                    type:
                        '  تعقيم المزرعه وذالك بستخدام غاز الفورمالدهيد لقتل الحشرات والفطريات.',
                  ),
                  TypeArticle(
                    type:
                        ' وضع الحواجز الخاصه بالتحضين أسفل لمبات التدفئه وذالك لتدفئه الكتكوت فى حاله الحظائر الى لاتستخدم التدفئه بالهواء الساخن',
                  ),
                  AdThirdNative(),
                  const TitleArticle(title: 'كيفية استقبال الكتاكيت'),
                  TypeArticle(
                    type:
                        'فرش الارضيه بالنشاره فى الصيف بسمك 5 سم وفى الشتاء 10 سم.',
                  ),
                  TypeArticle(
                    type:
                        'يوضع العلف البادى بعد وصول الكتاكيت مباشرة واحرص على عدم تجويع الكتاكيت ولو لفتره قصيره .',
                  ),
                  TypeArticle(
                    type:
                        'يتم توسيع مكان التحضين بحظر بعد اليوم ال15 نظرا لكبر حجم الكتاكيت ومنع التزاحم لان التزاحم يؤدى الى مشاكل كثيره.',
                  ),
                  TypeArticle(
                    type:
                        'يتم وضع الماء فى السقيات ووضعها داخل مكان التحضين قبل استقبال الكتاكيت ب2 ساعه حتى تاخذ المياه درجه حراره المكان حتى تشرب الكتاكيت مياه دافأه.',
                  ),
                  TypeArticle(
                    type:
                        'تخصييص 20%من مساحه العنبر فقط لتحضين الكتاكيت ويتم غلق هذه المساحه بستائر سميكه لمنع خروج درجه الحراره خارج مكان التحضين.',
                  ),
                  TypeArticle(
                    type:
                        'يتم التحضين على درجه حراره 34_35 لمده 3 ايام ثم يتم تقليل درجه الحراره تدريجيا كل يومين درجه حتى نهايه الاسبوع الاول على درجه حراره 31 ثم الاسبوع الثانى تكون درجه الحراره من 31 _الى 29 ثم الاسبوع الثالث من درجه حراره 29 الى 28 ثم الاسبوع الثالث تكون من 28 الى 26 واحرص على عدم نزول درجه الحراره عن 26 حتى لايتم الاصابه بالبرد',
                  ),
                  const TitleArticle(title: 'استقبال الكتاكيت عمر يوم'),
                  TypeArticle(
                    type:
                        'يجب البدء بتربيه كتكوت سليم ذى صفات وراثيه عاليه , ومن قطيع أمهات خاليه من الامراض وخاصه الاسهال الابيض , والتيفود , والميكوبلازما , ولا تقل بيضه التفريخ عن 55جم حتى لانحصل على كتكوت قليل الوزن.',
                  ),
                  TypeArticle(
                    type:
                        'ولابد أن يكون الكتكوت نشطا ومتجانس الحجم , وكبير , والعيون لامعه , والافضل استبعاد الكتكوت غير ملائم التربيه فى بدايه الامر بل أن يموت أو يستبعد فى فتره أخرى ويخسر المربى العليقه التى أستهلاكها الطائر',
                  ),
                  TypeArticle(
                    type:
                        'يجب استقاب الكتاكيت عمر يوم على درجة حراره لا تقل عن 34 درجة , حيث يتم وضع الدفايات والمياه والعلف فى العبر أو المزرعة قبل أستقبال الكتاكيت ب 5 ساعات حتى تكون درجه حراره المياه منا سناسبه للكتاكيت فى .',
                  ),
                  TypeArticle(
                    type:
                        'درجة الحرارة المثلى عند استقبال الكتاكيت هي 33 درجة مئوية خلال الأيام الثلاثة الأولى ويتم تقليل درجة الحراره 2 درجة بعد ثلاثة ايام من الاستقبال لتقف على 32 درجه حتى اليوم العاشر.  ثم تنخفض درجة الحرارة الى 30 درجة مئوية فقط من اليوم العاشر الى اليوم العشرين ثم تخفض درجة الحراره 2 درجة مئوية كل اسبوع حتى تصل إلى 22 درجة مئوية.',
                  ),
                  TypeArticle(
                    type:
                        'التهوية: - حركة الهواء النقي مهمة للصحة الجيدة والنمو السليم للكتاكيت . حيث تؤدي التهوية السيئة إلى تراكم ثانى أكسيد الكربون والأمونيا وبخار الماء مما قد يؤدي إلى عدوى جرثومية ويؤدى الى مشاكل نحن فى غنا عنها.',
                  ),
                  TypeArticle(
                    type:
                        'مساحة أرضية المزرعه : - يجب توفير مساحة أرضية كافية للنمو السليم للدجاج. يجب توفير 1 متر مربع لكل 8 دواجن فى فصل الصيف و12 دواجن فى الشتاء. حيث يؤدي ازدحام الدجاج إلى ضعف النمو ويؤدي إلى أفتراس الدواجن واكل ريش بعضهم .',
                  ),
                  TypeArticle(
                    type:
                        'ارضيات المزرعه: - أرضية مكان التربيه يجب ان تكون مفروشه بطبقات من القش أو قش الأرز أو نشارة الخشب وهذا يسمى فرشه الدواجن . يجب أن يكون سمك الفرشه من 5 إلى 7.5 سم ويجب أن تظل جافه.',
                  ),
                  TypeArticle(
                    type:
                        ' الضوء: - للحفاظ على الحضنة خالية من الجراثيم المعدية ، يجب أن يكون بيت الحضنة جيد التهوية. تعزز أشعة الشمس الموزعة بالتساوي النمو السليم للطيور وتكوين فيتامين د.',
                  ),
                  TypeArticle(
                    type:
                        'إسكان الدواجن: - تحظى الدواجن ذات الجوانب المفتوحة بشعبية في بلدنا. الهدف الأساسي من توفير السكن للدواجن هو حمايتها من الشمس والمطر والحيوانات المفترسة وتوفير الراحة. يجب أن يكون بيت الدواجن جيد التهوية. يجب أن تبقى باردة في الصيف ودافئة في الشتاء. يجب أن تكون أرضية بيت الدواجن مقاومة للرطوبة والجرذان وخالية من الشقوق وسهلة التنظيف ومتينة.',
                  ),
                  TypeArticle(
                    type:
                        'غذية الدواجن: - تعتبر تغذية الطيور الداجنة جزء مهم من التربية. يجب أن يحتوي النظام الغذائي للدجاج على كمية كافية من الماء والكربوهيدرات والبروتينات والدهون والفيتامينات والمعادن. يجب تقديم المواد الغذائية مثل الذرة والشعير والذرة الرفيعة والقمح والفول الصويا وغيرها في المتطلبات القياسية. وهذا يؤدي الى زياده وزن الفراخ البيضاء وتسمينها.',
                  ),
                  TypeArticle(
                    type:
                        'شراء أفضل الكتاكيت جودة. لا يمكن لأي قدر من الإدارة الجيدة تحويل الكتاكيت ذات النوعية الرديئة إلى طبقات جيدة أو دجاج التسمين. يمكن تحقيق المزيد من الأرباح في الوحدة التجارية عن طريق شراء كتاكيت فارسية عمرها يوم واحد. في وحدات دجاج التسمين ، تعطي الكتاكيت ذات الركض المباشر أداءً جيدًا بنفس القدر',
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdThirdBanner(),
    );
  }
}
