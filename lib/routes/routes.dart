import 'package:farkha_app/logic/binding/master_circle_bindings/a3alf_Bindings/a3laf_binding.dart';

import 'package:farkha_app/view/screen/drawer_page/3lag.dart';
import 'package:farkha_app/view/screen/drawer_page/a3rad.dart';
import 'package:farkha_app/view/screen/drawer_page/akhtaq.dart';
import 'package:farkha_app/view/screen/drawer_page/amrad.dart';
import 'package:farkha_app/view/screen/drawer_page/astaqbal.dart';
import 'package:farkha_app/view/screen/drawer_page/nasa7a.dart';
import 'package:farkha_app/view/screen/drawer_page/ta7sen.dart';
import 'package:farkha_app/view/screen/drawer_page/tather.dart';
import 'package:farkha_app/view/screen/home/choose_type/a3alf/a3laf.dart';
import 'package:farkha_app/view/screen/home/choose_type/bat/bat_firansawi.dart';
import 'package:farkha_app/view/screen/home/choose_type/bat/bat_maskufi.dart';
import 'package:farkha_app/view/screen/home/choose_type/bat/bat_molar.dart';
import 'package:farkha_app/view/screen/home/choose_type/byd/byd_abid.dart';
import 'package:farkha_app/view/screen/home/choose_type/byd/byd_aihmar.dart';
import 'package:farkha_app/view/screen/home/choose_type/byd/byd_baladi.dart';
import 'package:farkha_app/view/screen/home/choose_type/frakh/frakh_abid.dart';
import 'package:farkha_app/view/screen/home/choose_type/frakh/frakh_amhit_abid.dart';
import 'package:farkha_app/view/screen/home/choose_type/frakh/frakh_baladi.dart';
import 'package:farkha_app/view/screen/home/choose_type/frakh/frakh_sasso.dart';
import 'package:farkha_app/view/screen/home/choose_type/katkit/katkit_abid.dart';
import 'package:farkha_app/view/screen/home/choose_type/katkit/katkit_baladi.dart';
import 'package:farkha_app/view/screen/home/choose_type/katkit/katkit_sasso.dart';
import 'package:farkha_app/view/screen/drawer_page/alardya.dart';
import 'package:farkha_app/view/screen/drawer_page/alida.dart';
import 'package:farkha_app/view/screen/drawer_page/alrtoba.dart';
import 'package:farkha_app/view/screen/drawer_page/alsaf.dart';
import 'package:farkha_app/view/screen/drawer_page/alshata.dart';
import 'package:farkha_app/view/screen/drawer_page/altaganous.dart';
import 'package:farkha_app/view/screen/drawer_page/asthlak.dart';
import 'package:farkha_app/view/screen/drawer_page/awzan.dart';
import 'package:farkha_app/view/screen/drawer_page/dargt_al7rara.dart';
import 'package:farkha_app/view/screen/drawer_page/solalat.dart';

import 'package:farkha_app/view/screen/home/home_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  //initialRoutes
  static const homeScreen = Routes.HomeScreen;

  //GetPage
  static final routes = [
    GetPage(
      name: Routes.HomeScreen,
      page: () => HomeScreen(),
    ),
    //bat
    GetPage(
      name: Routes.BatMolar,
      page: () => BatMolar(),
     
    ),
    GetPage(
      name: Routes.BatFiransawi,
      page: () => BatFiransawi(),
      
    ),
    GetPage(
      name: Routes.BatMaskufi,
      page: () => BatMaskufi(),
      
    ),

//byd
    GetPage(
      name: Routes.BydAbid,
      page: () => BydAbid(),
     
    ),
    GetPage(
      name: Routes.BydAihmar,
      page: () => BydAihmar(),
     
    ),
    GetPage(
      name: Routes.BydBaladi,
      page: () => BydBaladi(),
      
    ),

//frakh
    GetPage(
      name: Routes.FrakhAbid,
      page: () => FrakhAbid(),
      
    ),
    GetPage(
      name: Routes.FrakhAmhitAbid,
      page: () => FrakhAmhitAbid(),
      
    ),
    GetPage(
      name: Routes.FrakhBaladi,
      page: () => FrakhBaladi(),
      
    ),
    GetPage(
      name: Routes.FrakhSasso,
      page: () => FrakhSasso(),
   
    ),

    //katkit
    GetPage(
      name: Routes.KatKitAbid,
      page: () => KatkitAbid(),
      
    ),
    GetPage(
      name: Routes.KatkitBaladi,
      page: () => KatkitBaladi(),
      
    ),
    GetPage(
      name: Routes.KatkitSasso,
      page: () => KatkitSasso(),
    
    ),
//a3laf
    GetPage(
      name: Routes.A3laf,
      page: () => A3laf(),
      binding: A3lafBinding(),
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
  static const HomeScreen = "/homeScreen";
  // ignore: constant_identifier_names

//bat
  static const BatMolar = "/batmolar";
  static const BatFiransawi = "/batfiransawi";
  static const BatMaskufi = "/batmaskufi";

//byd
  static const BydAbid = "/bydAbid";
  static const BydAihmar = "/bydAihmar";
  static const BydBaladi = "/bydBaladi";

  //frakh
  static const FrakhAbid = "/frakhAbid";
  static const FrakhSasso = "/frakhSasso";
  static const FrakhBaladi = "/frakhBaladi";
  static const FrakhAmhitAbid = "/frakhAmhitAbid";

  //katkit
  static const KatKitAbid = "/katKitAbid";
  static const KatkitBaladi = "/katkitBaladi";
  static const KatkitSasso = "/katkitSasso";

//a3laf
  static const A3laf = "/a3laf";

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
