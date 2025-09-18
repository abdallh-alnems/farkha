import 'package:get/get.dart';

import '../../../view/screen/tools/adg.dart';
import '../../../view/screen/tools/all_tools.dart';
import '../../../view/screen/tools/bird_net_profit.dart';
import '../../../view/screen/tools/bird_production_cost.dart';
import '../../../view/screen/tools/chicken_density.dart';
import '../../../view/screen/tools/daily_feed_consumption.dart';
import '../../../view/screen/tools/darkness_levels.dart';
import '../../../view/screen/tools/fan_operation.dart';
import '../../../view/screen/tools/fcr.dart';
import '../../../view/screen/tools/feasibility_study.dart';
import '../../../view/screen/tools/feed_cost_per_bird.dart';
import '../../../view/screen/tools/feed_cost_per_kilo.dart';
import '../../../view/screen/tools/mortality_rate.dart';
import '../../../view/screen/tools/roi.dart';
import '../../../view/screen/tools/temperature_by_age.dart';
import '../../../view/screen/tools/total_farm_weight.dart';
import '../../../view/screen/tools/total_feed_consumption.dart';
import '../../../view/screen/tools/total_revenue.dart';
import '../../../view/screen/tools/vaccination_schedule.dart';
import '../../../view/screen/tools/weight_by_age.dart';
import '../../../view/screen/cycle/add_cycle.dart';
import '../../../view/screen/cycle/cycle.dart';
import '../../../view/screen/cycle/cycle_stats_bar_explanation.dart';
import '../../../view/screen/tools/articles/article/a3rad.dart';
import '../../../view/screen/tools/articles/article/akhtaq.dart';
import '../../../view/screen/tools/articles/article/al3lag.dart';
import '../../../view/screen/tools/articles/article/alardya.dart';
import '../../../view/screen/tools/articles/article/alzlam.dart';
import '../../../view/screen/tools/articles/article/alrtoba.dart';
import '../../../view/screen/tools/articles/article/alsaf.dart';
import '../../../view/screen/tools/articles/article/alshata.dart';
import '../../../view/screen/tools/articles/article/altaganous.dart';
import '../../../view/screen/tools/articles/article/amrad.dart';
import '../../../view/screen/tools/articles/article/astaqbal.dart';
import '../../../view/screen/tools/articles/article/asthlak_al3laf.dart';
import '../../../view/screen/tools/articles/article/awzan.dart';
import '../../../view/screen/tools/articles/article/dargt_al7rara.dart';
import '../../../view/screen/tools/articles/article/nasa7a.dart';
import '../../../view/screen/tools/articles/article/solalat.dart';
import '../../../view/screen/tools/articles/article/ta7sen.dart';
import '../../../view/screen/tools/articles/article/tather.dart';
import '../../../view/screen/tools/articles/articles_type.dart';
import '../../../view/screen/tools/broiler_chicken_requirements.dart';
import '../../../view/screen/tools/disease/diagnosis_diseases.dart';
import '../../../view/screen/tools/disease/disease_details.dart';
import '../../../view/screen/tools/disease/diseases.dart';
import '../../../view/screen/general/general.dart';
import '../../../view/screen/general/suggestion.dart';
import '../../../view/screen/home.dart';
import '../../../view/screen/prices/customize_prices_screen.dart';
import '../../../view/screen/prices/last_prices.dart';
import '../../../view/screen/prices/main_types.dart';
import 'route.dart';

List<GetPage<dynamic>> pages = [
  // ============================== root =======================================
  GetPage(name: "/", page: () => const Home()),

  // ============================== Test =======================================

  // GetPage(name: AppRoute.test, page: () => Test()),

  // ================================ prices ===================================
  GetPage(
    name: AppRoute.lastPrices,
    page: () => const LastPrices(),
    transition: Transition.rightToLeft,
  ),

  GetPage(
    name: AppRoute.mainTypes,
    page: () => const MainTypes(),
    transition: Transition.rightToLeft,
  ),

  GetPage(
    name: AppRoute.customizePrices,
    page: () => const CustomizePricesScreen(),
    transition: Transition.rightToLeft,
  ),

  // ================================ cycle ====================================
  GetPage(
    name: AppRoute.addCycle,
    page: () => AddCycle(),
    transition: Transition.rightToLeft,
  ),

  GetPage(
    name: AppRoute.cycle,
    page: () => const Cycle(),
    transition: Transition.rightToLeft,
  ),

  GetPage(
    name: AppRoute.cycleStatsBarExplanation,
    page: () => const CycleStatsBarExplanation(),
    transition: Transition.rightToLeft,
  ),

  // ================================ general ==================================
  GetPage(
    name: AppRoute.general,
    page: () => const General(),
    transition: Transition.leftToRight,
  ),

  GetPage(
    name: AppRoute.suggestion,
    page: () => const Suggestion(),
    transition: Transition.leftToRight,
  ),

  // ========================== view follow up tools ===========================
  GetPage(
    name: AppRoute.articlesType,
    page: () => const ArticlesType(),
    transition: Transition.downToUp,
  ),

  GetPage(
    name: AppRoute.broilerChickenRequirements,
    page: () =>  BroilerChickenRequirements(),
    transition: Transition.downToUp,
  ),

  // ! disease
  GetPage(
    name: AppRoute.diseases,
    page: () => const Disease(),
    transition: Transition.downToUp,
  ),

  GetPage(
    name: AppRoute.diseaseDetails,
    page: () => const DiseaseDetails(),
    transition: Transition.rightToLeft,
  ),

  // ! diagnosis diseases
  GetPage(
    name: AppRoute.questionDisease,
    page: () => DiagnosisDiseases(),
    transition: Transition.rightToLeft,
  ),

  // ================================= tools ===================================

  // ! feasibility study
  GetPage(
    name: AppRoute.feasibilityStudy,
    page: () => FeasibilityStudy(),
    transition: Transition.downToUp,
  ),

  GetPage(
    name: AppRoute.chickenDensity,
    page: () => const ChickenDensity(),
    transition: Transition.downToUp,
  ),

  GetPage(
    name: AppRoute.dailyFeedConsumption,
    page: () => const DailyFeedConsumption(),
    transition: Transition.downToUp,
  ),

  GetPage(
    name: AppRoute.totalFeedConsumption,
    page: () => const TotalFeedConsumption(),
    transition: Transition.downToUp,
  ),

  GetPage(
    name: AppRoute.fcr,
    page: () => Fcr(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.adg,
    page: () => Adg(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.roi,
    page: () => RoiScreen(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.mortalityRate,
    page: () => MortalityRateScreen(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.birdProductionCost,
    page: () => BirdProductionCostScreen(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.birdNetProfit,
    page: () => const BirdNetProfitScreen(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.weightByAge,
    page: () => const WeightByAgeScreen(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.temperatureByAge,
    page: () => const TemperatureByAgeScreen(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.darknessLevels,
    page: () => const DarknessLevelsView(),
  ),
  GetPage(name: AppRoute.totalFarmWeight, page: () => TotalFarmWeightScreen()),
  GetPage(
    name: AppRoute.totalRevenue,
    page: () => TotalRevenueScreen(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.feedCostPerBird,
    page: () => FeedCostPerBirdScreen(),
    transition: Transition.rightToLeft,
  ),
  GetPage(
    name: AppRoute.feedCostPerKilo,
    page: () => FeedCostPerKiloScreen(),
    transition: Transition.rightToLeft,
  ),
  GetPage(
    name: AppRoute.vaccinationSchedule,
    page: () => const VaccinationSchedule(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.allTools,
    page: () => const AllTools(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.fanOperation,
    page: () => const FanOperationScreen(),
    transition: Transition.downToUp,
  ),

  // ================================ articles =================================
  GetPage(
    name: AppRoute.dartgetAl7rara,
    page: () => const DartgetAl7rara(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.alzlam,
    page: () => const Alzlam(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.alrotoba,
    page: () => const Alrotoba(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.alsaf,
    page: () => const Alsaf(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.alshata,
    page: () => const Alshata(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.altaganous,
    page: () => const Altaganous(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.awzan,
    page: () => const Awzan(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.asthlakAl3laf,
    page: () => const AsthlakAl3laf(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.solalat,
    page: () => const Solalat(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.alardya,
    page: () => const Alardya(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.amard,
    page: () => const Amard(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.a3ard,
    page: () => const A3ard(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.aL3lag,
    page: () => const AL3lag(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.nasa7a,
    page: () => const Nasa7a(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.astaqbal,
    page: () => const Astaqbal(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.akhtaq,
    page: () => const Akhtaq(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.tather,
    page: () => const Tather(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.ta7sen,
    page: () => const Ta7sen(),
    transition: Transition.downToUp,
  ),
];
