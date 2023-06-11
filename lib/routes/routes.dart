import 'package:farkha_app/logic/binding/data_binding/bat_binding.dart';
import 'package:farkha_app/logic/binding/data_binding/byd_binding.dart';
import 'package:farkha_app/logic/binding/data_binding/frakh_binding.dart';
import 'package:farkha_app/logic/binding/data_binding/katkit_binding.dart';
import 'package:farkha_app/view/screen/choose_type/a3laf_type.dart';
import 'package:farkha_app/view/screen/choose_type/bat_type.dart';
import 'package:farkha_app/view/screen/choose_type/byd_type.dart';
import 'package:farkha_app/view/screen/choose_type/frakh_type.dart';
import 'package:farkha_app/view/screen/choose_type/katkit_type.dart';
import 'package:farkha_app/view/screen/drawer/alardya.dart';
import 'package:farkha_app/view/screen/drawer/alferosat.dart';
import 'package:farkha_app/view/screen/drawer/alida.dart';
import 'package:farkha_app/view/screen/drawer/alrtoba.dart';
import 'package:farkha_app/view/screen/drawer/alsaf.dart';
import 'package:farkha_app/view/screen/drawer/alshata.dart';
import 'package:farkha_app/view/screen/drawer/altaganous.dart';
import 'package:farkha_app/view/screen/drawer/asthlak.dart';
import 'package:farkha_app/view/screen/drawer/awzan.dart';
import 'package:farkha_app/view/screen/drawer/dargt_al7rara.dart';
import 'package:farkha_app/view/screen/drawer/solalat.dart';

import 'package:farkha_app/view/screen/home_screen.dart';
import 'package:farkha_app/view/screen/onboarding.dart';
import 'package:get/get.dart';

class AppRoutes {
  //initialRoutes
  static const onboarding = Routes.Onboarding;

  //GetPage
  static final routes = [
    GetPage(
      name: Routes.Onboarding,
      page: () => const OnBoarding(),
    ),
    GetPage(
      name: Routes.HomeScreen,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: Routes.FrakhType,
      page: () => FrakhType(),
      binding: FrakhBinding(),
    ),
    GetPage(
      name: Routes.KatkitType,
      page: () => KatkitType(),
      binding: KatakitBinding(),
    ),
    GetPage(
      name: Routes.A3lafType,
      page: () => A3lafType(),
      binding: FrakhBinding(),
    ),
    GetPage(
      name: Routes.BydType,
      page: () => BydType(),
      binding: BydBinding(),
    ),
    GetPage(
      name: Routes.BatType,
      page: () => BatType(),
      binding: BatBinding(),
    ),
    GetPage(
      name: Routes.DartgetAl7rara,
      page: () => DartgetAl7rara(),
    ),
    GetPage(
      name: Routes.Alida,
      page: () => Alida(),
    ),
    GetPage(
      name: Routes.Alrotoba,
      page: () => Alrotoba(),
    ),
    GetPage(
      name: Routes.Alsaf,
      page: () => Alsaf(),
    ),
    GetPage(
      name: Routes.Alshata,
      page: () => Alshata(),
    ),
    GetPage(
      name: Routes.Altaganous,
      page: () => Altaganous(),
    ),
    GetPage(
      name: Routes.Awzan,
      page: () => Awzan(),
    ),
    GetPage(
      name: Routes.Asthlak,
      page: () => Asthlak(),
    ),
    GetPage(
      name: Routes.Solalat,
      page: () => Solalat()
    ),
    GetPage(
      name: Routes.Alardya,
      page: () => Alardya(),
    ),
    GetPage(
      name: Routes.Alferosat,
      page: () => Alferosat(),
    ),
  ];
}

class Routes {
  // ignore: constant_identifier_names
  static const Onboarding = "/onboarding";
  // ignore: constant_identifier_names
  static const HomeScreen = "/homeScreen";
  // ignore: constant_identifier_names
  static const FrakhType = "/frakhType";
  static const KatkitType = "/katkitType";

  static const A3lafType = "/a3lafType";

  static const BydType = "/bydType";

  static const BatType = "/batType";
  static const DartgetAl7rara = "/dartgetAl7rara";
  static const Alida = "/alida";
  static const Alrotoba = "/alrotoba";
  static const Alsaf = "/alsaf";
  static const Alshata = "/alshata";
  static const Altaganous = "/altaganous";
  static const Awzan = "/awzan";
  static const Asthlak = "/asthlak";
  static const Solalat = "/solalat";
  static const Alardya = "/alardya";
  static const Alferosat = "/alferosat";
}
