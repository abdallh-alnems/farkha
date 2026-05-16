export interface ToolEntry {
  toolId: number;
  text: string;
  icon: string;
  route: string;
  relatedArticleIds?: number[];
  showBeforeAd?: boolean;
}

export const allToolsList: ToolEntry[] = [
  { toolId: 1, text: "معامل التحويل الغذائي", icon: "/icons/tools/feed_conversion_ratio.svg", route: "/tools/fcr", relatedArticleIds: [19, 12], showBeforeAd: true },
  { toolId: 2, text: "متوسط النمو اليومي", icon: "/icons/tools/adg.svg", route: "/tools/adg", relatedArticleIds: [13], showBeforeAd: true },
  { toolId: 3, text: "كثافة الفراخ", icon: "/icons/tools/chicken_density.svg", route: "/tools/chicken-density", relatedArticleIds: [4] },
  { toolId: 4, text: "استهلاك العلف اليومي", icon: "/icons/tools/daily_feed_consumption.svg", route: "/tools/daily-feed-consumption", relatedArticleIds: [12] },
  { toolId: 5, text: "استهلاك العلف الكلي", icon: "/icons/tools/total_feed_consumption.svg", route: "/tools/total-feed-consumption", relatedArticleIds: [12] },
  { toolId: 23, text: "استهلاك الماء", icon: "/icons/tools/water.svg", route: "/tools/water-consumption" },
  { toolId: 6, text: "الوزن حسب العمر", icon: "/icons/tools/weight.svg", route: "/tools/weight-by-age", relatedArticleIds: [13], showBeforeAd: true },
  { toolId: 7, text: "درجة الحرارة حسب العمر", icon: "/icons/tools/thermometer.svg", route: "/tools/temperature-by-age", relatedArticleIds: [14, 11] },
  { toolId: 8, text: "ساعات الإظلام", icon: "/icons/tools/darkness.svg", route: "/tools/darkness-levels", relatedArticleIds: [9] },
  { toolId: 9, text: "تشغيل الشفاطات", icon: "/icons/tools/fan.svg", route: "/tools/fan-operation", relatedArticleIds: [5, 6] },
  { toolId: 24, text: "الطقس", icon: "/icons/tools/weather.svg", route: "/tools/weather" },
  { toolId: 10, text: "جدول التحصينات", icon: "/icons/tools/vaccination.svg", route: "/tools/vaccination-schedule", relatedArticleIds: [17] },
  { toolId: 11, text: "مقالات", icon: "/icons/tools/article.svg", route: "/articles" },
  { toolId: 12, text: "الأمراض", icon: "/icons/tools/diseases.svg", route: "/tools/diseases", relatedArticleIds: [1, 3, 10] },
  { toolId: 13, text: "متطلبات فراخ التسمين", icon: "/icons/tools/chicken_requirements.svg", route: "/tools/broiler-requirements", relatedArticleIds: [15, 11] },
  { toolId: 14, text: "دراسة جدوى", icon: "/icons/tools/feasibility_study.svg", route: "/tools/feasibility-study", relatedArticleIds: [20], showBeforeAd: true },
  { toolId: 15, text: "تكلفة إنتاج الفرخ", icon: "/icons/tools/budget.svg", route: "/tools/bird-production-cost", relatedArticleIds: [12, 20] },
  { toolId: 16, text: "تكلفة العلف لكل طائر", icon: "/icons/tools/feed_cost_per_bird.svg", route: "/tools/feed-cost-per-bird", relatedArticleIds: [12] },
  { toolId: 17, text: "تكلفة العلف لكل كيلو", icon: "/icons/tools/feed_cost_per_kilo.svg", route: "/tools/feed-cost-per-kilo", relatedArticleIds: [12] },
  { toolId: 18, text: "الربح الصافي للطائر", icon: "/icons/tools/profits.svg", route: "/tools/bird-net-profit", relatedArticleIds: [20] },
  { toolId: 19, text: "العائد على الاستثمار", icon: "/icons/tools/return_on_investment.svg", route: "/tools/roi", relatedArticleIds: [20] },
  { toolId: 20, text: "نسبة النفوق", icon: "/icons/tools/dead_chickens.svg", route: "/tools/mortality-rate", relatedArticleIds: [2, 18] },
  { toolId: 21, text: "الوزن الإجمالي", icon: "/icons/tools/total_weight.svg", route: "/tools/total-farm-weight", relatedArticleIds: [13, 8] },
  { toolId: 22, text: "إجمالي الإيرادات", icon: "/icons/tools/total_revenue.svg", route: "/tools/total-revenue", relatedArticleIds: [20] },
];
