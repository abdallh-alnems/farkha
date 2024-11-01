import 'package:get/get.dart';
import '../../../test.dart';
import '../../../view/screen/articles/articles.dart';
import '../../../view/screen/general.dart';
import '../../../view/screen/home_screen.dart';
import 'route.dart';

import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/a3rad.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/akhtaq.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/alardya.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/alida.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/alrtoba.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/alsaf.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/alshata.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/altaganous.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/amrad.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/astaqbal.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/asthlak.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/awzan.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/dargt_al7rara.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/nasa7a.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/solalat.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/ta7sen.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/tather.dart';
import 'package:farkha_app/view/screen/advice_drawer_and_advice_scroll/3lag.dart';

List<GetPage<dynamic>> pages = [
  // ============================== root =======================================

  GetPage(name: "/", page: () => HomeScreen()),

  // ============================== Test =======================================

  GetPage(name: AppRoute.test, page: () => Test()),
  GetPage(name: AppRoute.adad, page: () => ADAD()),

  // ================================ general ==================================

  GetPage(
    name: AppRoute.general,
    page: () => General(),
    transition: Transition.leftToRight,
  ),
  // ========================== view follow up tools ===========================
   GetPage(
    name: AppRoute.articles,
    page: () => Articles(),
    transition: Transition.downToUp,
  ),
  // ================================= drawer ==================================

  GetPage(
    name: AppRoute.dartgetAl7rara,
    page: () => const DartgetAl7rara(),
  ),
  GetPage(
    name: AppRoute.alida,
    page: () => const Alida(),
  ),
  GetPage(
    name: AppRoute.alrotoba,
    page: () => const Alrotoba(),
  ),
  GetPage(
    name: AppRoute.alsaf,
    page: () => const Alsaf(),
  ),
  GetPage(
    name: AppRoute.alshata,
    page: () => const Alshata(),
  ),
  GetPage(
    name: AppRoute.altaganous,
    page: () => const Altaganous(),
  ),
  GetPage(
    name: AppRoute.awzan,
    page: () => const Awzan(),
  ),
  GetPage(
    name: AppRoute.asthlak,
    page: () => const Asthlak(),
  ),
  GetPage(
    name: AppRoute.solalat,
    page: () => const Solalat(),
  ),
  GetPage(
    name: AppRoute.alardya,
    page: () => const Alardya(),
  ),
  GetPage(
    name: AppRoute.amard,
    page: () => const Amard(),
  ),
  GetPage(
    name: AppRoute.a3ard,
    page: () => const A3ard(),
  ),
  GetPage(
    name: AppRoute.aL3lag,
    page: () => const AL3lag(),
  ),
  GetPage(
    name: AppRoute.nasa7a,
    page: () => const Nasa7a(),
  ),
  GetPage(
    name: AppRoute.astaqbal,
    page: () => const Astaqbal(),
  ),
  GetPage(
    name: AppRoute.akhtaq,
    page: () => const Akhtaq(),
  ),
  GetPage(
    name: AppRoute.tather,
    page: () => const Tather(),
  ),
  GetPage(
    name: AppRoute.ta7sen,
    page: () => const Ta7sen(),
  ),
];
