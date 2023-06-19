import 'package:farkha_app/logic/binding/data_binding/bat_binding.dart';
import 'package:farkha_app/logic/binding/data_binding/byd_binding.dart';
import 'package:farkha_app/logic/binding/data_binding/frakh_binding.dart';
import 'package:farkha_app/logic/binding/data_binding/katkit_binding.dart';
import 'package:farkha_app/view/screen/drawer/3lag.dart';
import 'package:farkha_app/view/screen/drawer/a3rad.dart';
import 'package:farkha_app/view/screen/drawer/akhtaq.dart';
import 'package:farkha_app/view/screen/drawer/amrad.dart';
import 'package:farkha_app/view/screen/drawer/astaqbal.dart';
import 'package:farkha_app/view/screen/drawer/nasa7a.dart';
import 'package:farkha_app/view/screen/drawer/ta7sen.dart';
import 'package:farkha_app/view/screen/drawer/tather.dart';
import 'package:farkha_app/view/screen/home/choose_type/bat_molar.dart';
import 'package:farkha_app/view/screen/home/choose_type/byd_type.dart';
import 'package:farkha_app/view/screen/home/choose_type/frakh_type.dart';
import 'package:farkha_app/view/screen/home/choose_type/katkit_type.dart';
import 'package:farkha_app/view/screen/drawer/alardya.dart';
import 'package:farkha_app/view/screen/drawer/alida.dart';
import 'package:farkha_app/view/screen/drawer/alrtoba.dart';
import 'package:farkha_app/view/screen/drawer/alsaf.dart';
import 'package:farkha_app/view/screen/drawer/alshata.dart';
import 'package:farkha_app/view/screen/drawer/altaganous.dart';
import 'package:farkha_app/view/screen/drawer/asthlak.dart';
import 'package:farkha_app/view/screen/drawer/awzan.dart';
import 'package:farkha_app/view/screen/drawer/dargt_al7rara.dart';
import 'package:farkha_app/view/screen/drawer/solalat.dart';

import 'package:farkha_app/view/screen/home/home_screen.dart';
import 'package:farkha_app/view/screen/onboarding/onboarding.dart';
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
      name: Routes.BatMolar,
      page: () => BatMolar(),
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
    GetPage(name: Routes.Solalat, page: () => Solalat()),
    GetPage(
      name: Routes.Alardya,
      page: () => Alardya(),
    ),
    GetPage(
      name: Routes.Amard,
      page: () => Amard(),
    ),
    GetPage(
      name: Routes.A3ard,
      page: () => A3ard(),
    ),
    GetPage(
      name: Routes.AL3lag,
      page: () => AL3lag(),
    ),
    GetPage(
      name: Routes.Nasa7a,
      page: () => Nasa7a(),
    ),
    GetPage(
      name: Routes.Astaqbal,
      page: () => Astaqbal(),
    ),
    GetPage(
      name: Routes.Akhtaq,
      page: () => Akhtaq(),
    ),
    GetPage(
      name: Routes.Tather,
      page: () => Tather(),
    ),
    GetPage(
      name: Routes.Ta7sen,
      page: () => Ta7sen(),
    ),
  ];
}

class Routes {
  // ignore: constant_identifier_names
  static const Onboarding = "/onboarding";
  // ignore: constant_identifier_names
  static const HomeScreen = "/homeScreen";
  // ignore: constant_identifier_names


  static const BatMolar = "/batMolar";
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
  static const Amard = "/amard";
  static const A3ard = "/a3ard";
  static const AL3lag = "/aL3lag";
  static const Nasa7a = "/nasa7a";
  static const Astaqbal = "/astaqbal";
  static const Akhtaq = "/akhtaq";
  static const Tather = "/tather";
  static const Ta7sen = "/ta7sen";
}
