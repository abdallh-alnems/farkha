import '../../../view/screen/calculate/fcr.dart';
import '../../../view/screen/cycle/cycle.dart';
import '../../../view/screen/cycle/cycle_stats_bar_explanation.dart';
import '../../../view/screen/follow_up_tools/disease/disease_details.dart';
import '../../../view/screen/follow_up_tools/disease/diseases.dart';
import '../../../view/screen/follow_up_tools/disease/diagnosis_diseases.dart';
import '../../../view/screen/cycle/add_cycle.dart';
import '../../../view/screen/home.dart';
import 'route.dart';
import 'package:get/get.dart';
import '../../../view/screen/calculate/feasibility_study/how_to_do_a_feasibility_study.dart';
import '../../../view/screen/prices/main_types.dart';
import '../../../view/screen/calculate/chicken_density.dart';
import '../../../view/screen/calculate/feed_consumption.dart';
import '../../../view/screen/calculate/feasibility_study/feasibility_study.dart';
import '../../../view/screen/follow_up_tools/broiler_chicken_requirements.dart';
import '../../../view/screen/general/suggestion.dart';
import '../../../view/screen/prices/last_prices.dart';
import '../../../view/screen/follow_up_tools/articles/articles_type.dart';
import '../../../view/screen/general/general.dart';
import '../../../view/screen/follow_up_tools/articles/article/a3rad.dart';
import '../../../view/screen/follow_up_tools/articles/article/akhtaq.dart';
import '../../../view/screen/follow_up_tools/articles/article/alardya.dart';
import '../../../view/screen/follow_up_tools/articles/article/alida.dart';
import '../../../view/screen/follow_up_tools/articles/article/alrtoba.dart';
import '../../../view/screen/follow_up_tools/articles/article/alsaf.dart';
import '../../../view/screen/follow_up_tools/articles/article/alshata.dart';
import '../../../view/screen/follow_up_tools/articles/article/altaganous.dart';
import '../../../view/screen/follow_up_tools/articles/article/amrad.dart';
import '../../../view/screen/follow_up_tools/articles/article/astaqbal.dart';
import '../../../view/screen/follow_up_tools/articles/article/asthlak_al3laf.dart';
import '../../../view/screen/follow_up_tools/articles/article/awzan.dart';
import '../../../view/screen/follow_up_tools/articles/article/dargt_al7rara.dart';
import '../../../view/screen/follow_up_tools/articles/article/nasa7a.dart';
import '../../../view/screen/follow_up_tools/articles/article/solalat.dart';
import '../../../view/screen/follow_up_tools/articles/article/ta7sen.dart';
import '../../../view/screen/follow_up_tools/articles/article/tather.dart';
import '../../../view/screen/follow_up_tools/articles/article/al3lag.dart';
import '../../../view/screen/calculate/adg.dart';
import '../../../view/screen/calculate/roi.dart';
import '../../../view/screen/calculate/mortality_rate.dart';
import '../../../view/screen/calculate/bird_production_cost.dart';
import '../../../view/screen/calculate/bird_net_profit.dart';
import '../../../view/screen/calculate/weight_by_age.dart';
import '../../../view/screen/calculate/temperature_by_age.dart';
import '../../../view/screen/calculate/darkness_levels.dart';
import '../../../view/screen/calculate/total_farm_weight.dart';
import '../../../view/screen/calculate/total_revenue.dart';
import '../../../view/screen/calculate/feed_cost_per_bird.dart';
import '../../../view/screen/calculate/feed_cost_per_kilo.dart';
import '../../../view/screen/calculate/vaccination_schedule.dart';
import '../../../view/screen/calculate/all_calculations.dart';

List<GetPage<dynamic>> pages = [
  // ============================== root =======================================
  GetPage(name: "/", page: () => Home()),

  // ============================== Test =======================================

  // GetPage(name: AppRoute.test, page: () => Test()),

  // ================================ prices ===================================
  GetPage(
    name: AppRoute.lastPrices,
    page: () => LastPrices(),
    transition: Transition.rightToLeft,
  ),

  GetPage(
    name: AppRoute.mainTypes,
    page: () => MainTypes(),
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
    page: () => Cycle(),
    transition: Transition.rightToLeft,
  ),

  GetPage(
    name: AppRoute.cycleStatsBarExplanation,
    page: () => CycleStatsBarExplanation(),
    transition: Transition.rightToLeft,
  ),

  // ================================ general ==================================
  GetPage(
    name: AppRoute.general,
    page: () => General(),
    transition: Transition.leftToRight,
  ),

  GetPage(
    name: AppRoute.suggestion,
    page: () => Suggestion(),
    transition: Transition.leftToRight,
  ),

  // ========================== view follow up tools ===========================
  GetPage(
    name: AppRoute.articlesType,
    page: () => ArticlesType(),
    transition: Transition.downToUp,
  ),

  GetPage(
    name: AppRoute.broilerChickenRequirements,
    page: () => BroilerChickenRequirements(),
    transition: Transition.downToUp,
  ),

  // ! disease
  GetPage(
    name: AppRoute.diseases,
    page: () => Disease(),
    transition: Transition.downToUp,
  ),

  GetPage(
    name: AppRoute.diseaseDetails,
    page: () => DiseaseDetails(),
    transition: Transition.rightToLeft,
  ),

  // ! diagnosis diseases
  GetPage(
    name: AppRoute.questionDisease,
    page: () => DiagnosisDiseases(),
    transition: Transition.rightToLeft,
  ),

  // =============================== calculate =================================

  // ! feasibility study
  GetPage(
    name: AppRoute.feasibilityStudy,
    page: () => FeasibilityStudy(),
    transition: Transition.downToUp,
  ),

  GetPage(
    name: AppRoute.howToDoAFeasibilityStudy,
    page: () => HowToDoAFeasibilityStudy(),
    transition: Transition.downToUp,
  ),

  GetPage(
    name: AppRoute.chickenDensity,
    page: () => ChickenDensity(),
    transition: Transition.downToUp,
  ),

  GetPage(
    name: AppRoute.feedConsumption,
    page: () => FeedConsumption(),
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
    page: () => BirdNetProfitScreen(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.weightByAge,
    page: () => WeightByAgeScreen(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.temperatureByAge,
    page: () => TemperatureByAgeScreen(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.darknessLevels,
    page: () => const DarknessLevelsView(),
  ),
  GetPage(
    name: AppRoute.totalFarmWeight,
    page: () => const TotalFarmWeightScreen(),
  ),
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
    name: AppRoute.allCalculations,
    page: () => const AllCalculations(),
    transition: Transition.downToUp,
  ),

  // ================================ articles =================================
  GetPage(
    name: AppRoute.dartgetAl7rara,
    page: () => const DartgetAl7rara(),
    transition: Transition.downToUp,
  ),
  GetPage(
    name: AppRoute.alida,
    page: () => const Alida(),
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
    page: () => AsthlakAl3laf(),
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
    page: () => Akhtaq(),
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
