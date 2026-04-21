import 'package:get/get.dart';

import '../../../logic/bindings/home_binding.dart';
import '../../../logic/bindings/phone_verification_binding.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import '../../../logic/controller/cycle_sales_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../../logic/controller/tools_controller/darkness_schedule_controller.dart';
import '../../../logic/controller/weather_controller.dart';
import '../../../view/screen/auth/login_screen.dart';
import '../../../view/screen/auth/verify_phone_number_screen.dart';
import '../../../view/screen/auth/enter_otp_screen.dart';
import '../../../view/screen/cycle/add_cycle.dart';
import '../../../view/screen/cycle/cycle_closeout_report.dart';
import '../../../view/screen/cycle/cycle.dart';
import '../../../view/screen/cycle/cycle_data.dart';
import '../../../view/screen/cycle/cycle_expenses.dart';
import '../../../view/screen/cycle/cycle_sales.dart';
import '../../../view/screen/cycle/cycle_notes.dart';
import '../../../view/screen/cycle/cycle_history_screen.dart';
import '../../../view/screen/cycle/cycle_history_details_screen.dart';
import '../../../view/screen/cycle/cycle_comparison_screen.dart';
import '../../../view/screen/cycle/darkness_alarm_screen.dart';
import '../../../view/screen/home.dart';
import '../../../view/screen/onboarding.dart';
import '../../../view/screen/prices/customize_prices_screen.dart';
import '../../../view/screen/prices/main_types.dart';
import '../../../view/screen/prices/price_history_screen.dart';
import '../../../view/screen/prices/prices_by_type.dart';
import '../../../view/screen/tools/all_tools.dart';
import '../../../view/screen/tools/articles/article_detail.dart';
import '../../../view/screen/tools/articles/articles_list.dart';
import '../../../view/screen/tools/average_daily_gain.dart';
import '../../../view/screen/tools/bird_net_profit.dart';
import '../../../view/screen/tools/bird_production_cost.dart';
import '../../../view/screen/tools/broiler_chicken_requirements.dart';
import '../../../view/screen/tools/chicken_density.dart';
import '../../../view/screen/tools/daily_feed_consumption.dart';
import '../../../view/screen/tools/darkness_levels.dart';
import '../../../view/screen/tools/disease/diagnosis_diseases.dart';
import '../../../view/screen/tools/disease/disease_details.dart';
import '../../../view/screen/tools/disease/diseases.dart';
import '../../../view/screen/tools/fan_operation.dart';
import '../../../view/screen/tools/feasibility_study.dart';
import '../../../view/screen/tools/feed_conversion_ratio.dart';
import '../../../view/screen/tools/feed_cost_per_bird.dart';
import '../../../view/screen/tools/feed_cost_per_kilo.dart';
import '../../../view/screen/tools/mortality_rate.dart';
import '../../../view/screen/tools/return_on_investment.dart';
import '../../../view/screen/tools/temperature_by_age.dart';
import '../../../view/screen/tools/total_farm_weight.dart';
import '../../../view/screen/tools/total_feed_consumption.dart';
import '../../../view/screen/tools/total_revenue.dart';
import '../../../view/screen/tools/vaccination_schedule.dart';
import '../../../view/screen/tools/water_consumption.dart';
import '../../../view/screen/tools/weather_screen.dart';
import '../../../view/screen/tools/weight_by_age.dart';
import '../../../view/widget/drawer/suggestion.dart';
import '../../middleware/auth_middleware.dart';
import '../../middleware/onboarding_middleware.dart';

import 'route.dart';

List<GetPage<dynamic>> pages = [
  // ============================== root =======================================
  GetPage(
    name: '/',
    page: () => const Home(),
    middlewares: [OnboardingMiddleWare()],
    binding: HomeBindings(),
  ),

  // ============================== Test =======================================
  // GetPage(name: AppRoute.test, page: () => const Test()),
  // GetPage(name: AppRoute.test2, page: () => const Test2()),
  GetPage(name: AppRoute.onBoarding, page: () => const OnBoarding()),

  // ================================= auth ====================================
  GetPage(name: AppRoute.login, page: () => const LoginScreen()),
  GetPage(
    name: AppRoute.verifyPhoneNumber,
    page: () => const VerifyPhoneNumberScreen(),
    binding: PhoneVerificationBinding(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoute.enterOtp,
    page: () => const EnterOtpScreen(),
    binding: PhoneVerificationBinding(),
    middlewares: [AuthMiddleware()],
  ),

  // ================================ prices ===================================
  GetPage(name: AppRoute.pricesByType, page: () => const PricesByType()),
  GetPage(name: AppRoute.priceHistory, page: () => const PriceHistoryScreen()),
  GetPage(name: AppRoute.mainTypes, page: () => const MainTypes()),
  GetPage(
    name: AppRoute.customizePrices,
    page: () => const CustomizePricesScreen(),
  ),

  // ================================ cycle ====================================
  GetPage(
    name: AppRoute.addCycle,
    page: () => AddCycle(),
    middlewares: [AuthMiddleware()],
  ),

  GetPage(
    name: AppRoute.cycle,
    page: () => const Cycle(),
    binding: BindingsBuilder<void>(() {
      if (!Get.isRegistered<CycleController>()) {
        Get.put(CycleController(), permanent: true);
      }
      if (!Get.isRegistered<BroilerController>()) {
        Get.put(BroilerController());
      }
      if (!Get.isRegistered<DarknessScheduleController>()) {
        Get.put(DarknessScheduleController());
      }
      if (!Get.isRegistered<CycleExpensesController>()) {
        Get.put(CycleExpensesController());
      }
      if (!Get.isRegistered<CycleSalesController>()) {
        Get.put(CycleSalesController());
      }
      if (!Get.isRegistered<WeatherController>()) {
        Get.put(WeatherController(), permanent: true);
      }
    }),
  ),
  GetPage(
    name: AppRoute.cycleExpenses,
    page: () => const CycleExpensesScreen(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoute.cycleSales,
    page: () => const CycleSalesScreen(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoute.cycleData,
    page: () => const CycleDataScreen(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoute.cycleNotes,
    page: () => const CycleNotesScreen(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoute.history,
    page: () => const CycleHistoryScreen(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoute.cycleHistoryDetails,
    page: () => const CycleHistoryDetailsScreen(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoute.cycleCloseoutReport,
    page: () {
      final args = Get.arguments as Map<String, dynamic>?;
      return CloseoutReportScreen(
        cycleData: args?['cycleData'] as Map<String, dynamic>? ?? {},
      );
    },
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoute.cycleComparison,
    page: () => const CycleComparisonScreen(),
    middlewares: [AuthMiddleware()],
  ),

  // ================================ drawer ==================================
  GetPage(name: AppRoute.suggestion, page: () => const Suggestion()),

  // ========================== view follow up tools ===========================
  GetPage(
    name: AppRoute.broilerChickenRequirements,
    page: () => BroilerChickenRequirements(),
  ),

  // ! disease
  GetPage(name: AppRoute.diseases, page: () => const Disease()),

  GetPage(name: AppRoute.diseaseDetails, page: () => const DiseaseDetails()),

  // ! diagnosis diseases
  GetPage(name: AppRoute.questionDisease, page: () => DiagnosisDiseases()),

  // ================================= tools ===================================

  // ! articles
  GetPage(name: AppRoute.articlesList, page: () => const ArticlesList()),
  GetPage(name: AppRoute.articleDetail, page: () => const ArticleDetail()),

  // ! feasibility study
  GetPage(
    name: AppRoute.feasibilityStudy,
    page: () => const FeasibilityStudy(),
  ),

  GetPage(name: AppRoute.chickenDensity, page: () => const ChickenDensity()),

  GetPage(
    name: AppRoute.dailyFeedConsumption,
    page: () => const DailyFeedConsumption(),
  ),

  GetPage(
    name: AppRoute.waterConsumption,
    page: () => const WaterConsumption(),
  ),

  GetPage(
    name: AppRoute.totalFeedConsumption,
    page: () => const TotalFeedConsumption(),
  ),

  GetPage(name: AppRoute.fcr, page: () => FeedConversionRatio()),
  GetPage(name: AppRoute.adg, page: () => AverageDailyGain()),
  GetPage(name: AppRoute.roi, page: () => ReturnOnInvestment()),
  GetPage(name: AppRoute.mortalityRate, page: () => MortalityRateScreen()),
  GetPage(
    name: AppRoute.birdProductionCost,
    page: () => BirdProductionCostScreen(),
  ),
  GetPage(
    name: AppRoute.birdNetProfit,
    page: () => const BirdNetProfitScreen(),
  ),
  GetPage(name: AppRoute.weightByAge, page: () => const WeightByAgeScreen()),
  GetPage(
    name: AppRoute.temperatureByAge,
    page: () => const TemperatureByAgeScreen(),
  ),
  GetPage(
    name: AppRoute.darknessLevels,
    page: () => const DarknessLevelsView(),
  ),
  GetPage(name: AppRoute.totalFarmWeight, page: () => TotalFarmWeightScreen()),
  GetPage(name: AppRoute.totalRevenue, page: () => TotalRevenueScreen()),
  GetPage(name: AppRoute.feedCostPerBird, page: () => FeedCostPerBirdScreen()),
  GetPage(name: AppRoute.feedCostPerKilo, page: () => FeedCostPerKiloScreen()),
  GetPage(
    name: AppRoute.vaccinationSchedule,
    page: () => const VaccinationSchedule(),
  ),
  GetPage(name: AppRoute.allTools, page: () => const AllTools()),
  GetPage(name: AppRoute.fanOperation, page: () => const FanOperationScreen()),
  GetPage(name: AppRoute.weather, page: () => const WeatherScreen()),

  GetPage(
    name: AppRoute.darknessAlarm,
    page: () {
      final args = Get.arguments as Map<String, dynamic>?;
      return DarknessAlarmScreen(
        title: args?['title'] as String?,
        body: args?['body'] as String?,
        phase: args?['phase'] as int?,
        cycleName: args?['cycleName'] as String?,
        duration: args?['duration'] as String?,
        startTime: args?['startTime'] as String?,
        endTime: args?['endTime'] as String?,
        totalPhases: args?['totalPhases'] as int?,
        age: args?['age'] as int?,
        totalDarknessHours: args?['totalDarknessHours'] as int?,
        fromBackground: args?['fromBackground'] as bool? ?? false,
      );
    },
  ),

  // ================================ articles =================================
];
