import '../../../core/constant/image_asset.dart';
import '../../model/onboarding_model.dart';

List<OnBoardingModel> onBoardingList = [
  OnBoardingModel(
    title: "متابعة الاسعار",
    body:
        "احصل على أحدث أسعار الدواجن والأعلاف في السوق المحلي مع تحديثات يومية دقيقة",
    image: ImageAsset.onboardingPrices,
  ),
  OnBoardingModel(
    title: "ادوات مساعدة",
    body:
        "مجموعة شاملة من الأدوات والحاسبات المتخصصة لإدارة مزرعتك بكفاءة عالية",
    image: ImageAsset.onboardingTools,
  ),
];
