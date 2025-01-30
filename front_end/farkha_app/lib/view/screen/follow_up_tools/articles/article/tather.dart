import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../widget/app/ad/native/ad_third_native.dart';
import '../../../../widget/app/app_bar/custom_app_bar.dart';
import '../../../../widget/app/follow_up_tools/articles/title_article.dart';
import '../../../../widget/app/follow_up_tools/articles/type_article.dart';
import 'package:flutter/material.dart';
import '../../../../widget/app/ad/banner/banner.dart';

class Tather extends StatelessWidget {
  const Tather({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "تطهير"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: const Column(children: [
                  TypeArticle(
                    type:
                        'برنامج تطهير مقترح لتنظيف وتطهير عنبر 500م2 إن تنظيف وتطهير المزرعة جيدا يعتبر أهم العوامل للحصول على نتائج   لذا يجب السماح بفترة كافية(أسبوعين على الأقل) بين انتهاء قطيع واستقبال قطيع جديد.يجب إتباع الإجراءات التالية للحصول على تنظيف وتطهير جيد للعنب',
                  ),
                  AdThirdNative(),
                  TypeArticle(
                    type:
                        ' رش ملاثيون على الفرشة (2لتر/40 جيدة 0لتر ماء)  وذلك للقضاء على الحشرات والسوس المتواجد بالعنبر فور الإنتهاء من البيع',
                  ),
                  TypeArticle(
                    type:
                        ' إزالة الفرشة والتخلص منها بعيدا عن المزرعة ويجب عدم نثرها أو تخزينها قريبا من المزرعة',
                  ),
                  TypeArticle(
                    type:
                        'كنس العنبر وإزالة بقايا السبلة من العنبر وازاله اى بقايا فرشه بالارضيات',
                  ),
                  TypeArticle(
                    type:
                        'إجراء أعمال الإصلاح والصيانة بالعنبر حيث يتم تفكيك كل الأدوات (المساقى- المعالف - الأطباق البلاستيكية) ونقلها خارج العنبر أو في أحد العنابر وغسلها ثم تطهيرها بمطهر اليود 3%تركيز ثم بالفيروسيد 0.25% ثم تخزينها لحين الاستخدام',
                  ),
                  TypeArticle(
                    type:
                        'الخزانات وخطوط الماءغسيلها وتطهيرها باستخدام سيد 2000 بمعدل 2% (4لتر/ 200لتر ماء)لإزالة الترسيبات العضوية والغير عضوية ومنع ترسيب الاملاح والشوائب بخطوط العلف ويترك لمده 6 ساعات تم غسلها بالماء',
                  ),
                  TitleArticle(
                    title: 'غسيل وتطهير العنبر',
                  ),
                  TypeArticle(
                    type:
                        'ش العنبر ببادئي النظافه(لإذابة وإزالة البقايا الموجودة بالعنبر مثل زرق الطيور ،الريش، الزغب) بموتور رش رش شمسية لعمل رغاوى على الجدران ويترك لمدة ساعة أو نصف ساعة على الأقل بمادة)بمعدل 10لتر/600لتر ماءMD cid-S(ثم يغسيل العنبر غسيلا جيدا بالماء العادي المندفع تحت ضغط باستخدام ماكينة غسيل أو موتور رش على جميع الأسطح لإزالة بقايا بادئ النظافة ملحوظة هامة:في حالة إصابة القطيع السابق بمرض فيروسي (نيوكاسيل- جمبورو) أو وجود إصابات سابقة بالكلوستريديا أو الكوكسيديا . يتم استخدام صودا كاوية بمعدل 8 كجم/200لتر ماء ساخن ثم رشها على أرضية العنبر.',
                  ),
                  TypeArticle(
                    type:
                        'طهير العنبر بمطهر قوى مثل فيرو سيد 0.5% (2لتر/400 لتر ماء) رزاز خفيف لتغطية المسطح بالكامل',
                  ),
                  TypeArticle(
                    type: 'رش العنبر بالكلور 2%',
                  ),
                  TypeArticle(
                    type: 'التطهير بالفنيك 10% للارضيات والجزء السفلى للجدران',
                  ),
                  TypeArticle(
                    type:
                        'رش العنبر بالفورمالين بمعدل 10% حيث ان الفورمالين بتركيز40%مع تشغيل الهياتر او الدفايات لمده 24ساعة مع غلق العنبر ثم تهويه العنبر لخروج غاز الفورمالدهيد.',
                  ),
                  TitleArticle(
                    title: 'بعد جفاف العنبر كليا يتم الأتي',
                  ),
                  TypeArticle(
                    type:
                        ' إدخال النشارة وفردها بالكامل إن أمكن أو في مكان التحضين مبدئيا يفضل إدخال كل فرشة العنبر مرة واحدة ليتثنى تطهيرها كاملة قبل وصول الكتاكيتمن مساقى وعلاقات وخلافه إدخال جميع الأدوات الخاصة بالعنبر. رش العنبر فيروسيد 0.25% (500سم/200لتر ماء)او باليود1%. رزاز خفيف طبقة كاملة فوق النشارة والستائر والأدوات والمعدات. غلق العنبر ومنع دخول أي فرد لحين وصول الكتاكيت',
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
