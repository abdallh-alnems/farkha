import 'package:get/get.dart';
import '../../../view/screen/calculate/chicken_density.dart';
import '../../../view/screen/calculate/feed_consumption.dart';
import '../../../view/screen/calculate/feasibility_study.dart';
import '../../../view/screen/general/suggestion.dart';
import '../../../view/screen/prices/last_prices.dart';
import 'route.dart';
import '../../../view/screen/follow_up_tools/articles/articles_type.dart';
import '../../../view/screen/general/general.dart';
import '../../../view/screen/home_screen.dart';
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
import '../../../view/screen/follow_up_tools/articles/article/asthlak.dart';
import '../../../view/screen/follow_up_tools/articles/article/awzan.dart';
import '../../../view/screen/follow_up_tools/articles/article/dargt_al7rara.dart';
import '../../../view/screen/follow_up_tools/articles/article/nasa7a.dart';
import '../../../view/screen/follow_up_tools/articles/article/solalat.dart';
import '../../../view/screen/follow_up_tools/articles/article/ta7sen.dart';
import '../../../view/screen/follow_up_tools/articles/article/tather.dart';
import '../../../view/screen/follow_up_tools/articles/article/al3lag.dart';

List<GetPage<dynamic>> pages = [
  // ============================== root =======================================

  GetPage(name: "/", page: () => HomeScreen()),

  // ============================== Test =======================================

  // GetPage(name: AppRoute.test, page: () => Test()),

    // ================================ prices ===================================
 GetPage(
    name: AppRoute.lastPrices,
    page: () => LastPrices(),
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

  // =============================== calculate =================================

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
    name: AppRoute.feasibilityStudy,
    page: () => FeasibilityStudy(),
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
    name: AppRoute.asthlak,
    page: () => const Asthlak(),
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
