import 'package:farkha_app/core/constant/routes/route.dart';
import 'package:farkha_app/core/constant/theme/images.dart';

/// Single source of truth for all app tools (home section + all-tools page).
class ToolEntry {
  const ToolEntry({
    required this.toolId,
    required this.text,
    required this.image,
    required this.route,
    this.relatedArticleIds,
    this.showBeforeAd = false,
  });

  final int toolId;
  final String text;
  final String image;
  final String route;
  final List<int>? relatedArticleIds;
  final bool showBeforeAd;
}

/// All tools in home display order. Splitting for all-tools page uses [ToolEntry.showBeforeAd].
final List<ToolEntry> allToolsList = [
  const ToolEntry(
    toolId: 1,
    text: 'معامل التحويل الغذائي',
    image: AppImages.feedConversionRatio,
    route: AppRoute.fcr,
    relatedArticleIds: [19, 12],
    showBeforeAd: true,
  ),
  const ToolEntry(
    toolId: 2,
    text: 'متوسط النمو اليومي',
    image: AppImages.averageDailyGain,
    route: AppRoute.adg,
    relatedArticleIds: [13],
    showBeforeAd: true,
  ),
  const ToolEntry(
    toolId: 3,
    text: 'كثافة الفراخ',
    image: AppImages.birdDensity,
    route: AppRoute.chickenDensity,
    relatedArticleIds: [4],
  ),
  const ToolEntry(
    toolId: 4,
    text: 'استهلاك العلف اليومي',
    image: AppImages.dailyFeedConsumption,
    route: AppRoute.dailyFeedConsumption,
    relatedArticleIds: [12],
  ),
  const ToolEntry(
    toolId: 5,
    text: 'استهلاك العلف الكلي',
    image: AppImages.totalFeedConsumption,
    route: AppRoute.totalFeedConsumption,
    relatedArticleIds: [12],
  ),
  const ToolEntry(
    toolId: 23,
    text: 'استهلاك الماء',
    image: AppImages.water,
    route: AppRoute.waterConsumption,
  ),
  const ToolEntry(
    toolId: 6,
    text: 'الوزن حسب العمر',
    image: AppImages.weight,
    route: AppRoute.weightByAge,
    relatedArticleIds: [13],
    showBeforeAd: true,
  ),
  const ToolEntry(
    toolId: 7,
    text: 'درجة الحرارة حسب العمر',
    image: AppImages.thermometer,
    route: AppRoute.temperatureByAge,
    relatedArticleIds: [14, 11],
  ),
  const ToolEntry(
    toolId: 8,
    text: 'ساعات الاظلام',
    image: AppImages.darkness,
    route: AppRoute.darknessLevels,
    relatedArticleIds: [9],
  ),
  const ToolEntry(
    toolId: 9,
    text: 'تشغيل الشفاطات',
    image: AppImages.fan,
    route: AppRoute.fanOperation,
    relatedArticleIds: [5, 6],
  ),
  const ToolEntry(
    toolId: 24,
    text: 'الطقس',
    image: AppImages.weather,
    route: AppRoute.weather,
  ),
  const ToolEntry(
    toolId: 10,
    text: 'جدول التحصينات',
    image: AppImages.vaccination,
    route: AppRoute.vaccinationSchedule,
    relatedArticleIds: [17],
  ),
  const ToolEntry(
    toolId: 11,
    text: 'مقالات',
    image: AppImages.article,
    route: AppRoute.articlesList,
  ),
  const ToolEntry(
    toolId: 12,
    text: 'الامراض',
    image: AppImages.diseases,
    route: AppRoute.diseases,
    relatedArticleIds: [1, 3, 10],
  ),
  const ToolEntry(
    toolId: 13,
    text: 'متطلبات فراخ التسمين',
    image: AppImages.chickenRequirements,
    route: AppRoute.broilerChickenRequirements,
    relatedArticleIds: [15, 11],
  ),
  const ToolEntry(
    toolId: 14,
    text: 'دراسة جدوي',
    image: AppImages.feasibilityStudy,
    route: AppRoute.feasibilityStudy,
    relatedArticleIds: [20],
    showBeforeAd: true,
  ),
  const ToolEntry(
    toolId: 15,
    text: 'تكلفة انتاج الفرخ',
    image: AppImages.budget,
    route: AppRoute.birdProductionCost,
    relatedArticleIds: [12, 20],
  ),
  const ToolEntry(
    toolId: 16,
    text: 'تكلفة العلف لكل طائر',
    image: AppImages.feedCostPerBird,
    route: AppRoute.feedCostPerBird,
    relatedArticleIds: [12],
  ),
  const ToolEntry(
    toolId: 17,
    text: 'تكلفة العلف لكل كيلو وزن',
    image: AppImages.feedCostPerKilo,
    route: AppRoute.feedCostPerKilo,
    relatedArticleIds: [12],
  ),
  const ToolEntry(
    toolId: 18,
    text: 'الربح الصافي للطائر',
    image: AppImages.profits,
    route: AppRoute.birdNetProfit,
    relatedArticleIds: [20],
  ),
  const ToolEntry(
    toolId: 19,
    text: 'العائد على الاستثمار',
    image: AppImages.returnOnInvestment,
    route: AppRoute.roi,
    relatedArticleIds: [20],
  ),
  const ToolEntry(
    toolId: 20,
    text: 'نسبة النفوق',
    image: AppImages.deadChickens,
    route: AppRoute.mortalityRate,
    relatedArticleIds: [2, 18],
  ),
  const ToolEntry(
    toolId: 21,
    text: 'الوزن الاجمالي',
    image: AppImages.totalWeight,
    route: AppRoute.totalFarmWeight,
    relatedArticleIds: [13, 8],
  ),
  const ToolEntry(
    toolId: 22,
    text: 'اجمالي الايرادات',
    image: AppImages.totalRevenue,
    route: AppRoute.totalRevenue,
    relatedArticleIds: [20],
  ),
];
