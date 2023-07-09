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

import 'package:farkha_app/view/screen/home/home_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  
  //GetPage
  static final routes = [
    GetPage(
      name: Routes.homeScreen,
      page: () => const  HomeScreen(),
    ),
    //bat
    GetPage(
      name: Routes.batMolar,
      page: () => const  BatMolar(),
     
    ),
    GetPage(
      name: Routes.bydAihmar,
      page: () => const  BatFiransawi(),
      
    ),
    GetPage(
      name: Routes.batMaskufi,
      page: () => const BatMaskufi(),
      
    ),

//byd
    GetPage(
      name: Routes.bydAbid,
      page: () => const  BydAbid(),
     
    ),
    GetPage(
      name: Routes.bydAihmar,
      page: () => const  BydAihmar(),
     
    ),
    GetPage(
      name: Routes.bydBaladi,
      page: () => const BydBaladi(),
      
    ),

//frakh
    GetPage(
      name: Routes.frakhAbid,
      page: () => const FrakhAbid(),
      
    ),
    GetPage(
      name: Routes.frakhAmhitAbid,
      page: () => const FrakhAmhitAbid(),
      
    ),
    GetPage(
      name: Routes.frakhBaladi,
      page: () => const FrakhBaladi(),
      
    ),
    GetPage(
      name: Routes.frakhSasso,
      page: () => const FrakhSasso(),
   
    ),

    //katkit
    GetPage(
      name: Routes.katKitAbid,
      page: () => const KatkitAbid(),
      
    ),
    GetPage(
      name: Routes.katkitBaladi,
      page: () => const KatkitBaladi(),
      
    ),
    GetPage(
      name: Routes.katkitSasso,
      page: () => const KatkitSasso(),
    
    ),
//a3laf
    GetPage(
      name: Routes.a3laf,
      page: () => const A3laf(),
    ),

    GetPage(
      name: Routes.dartgetAl7rara,
      page: () => const DartgetAl7rara(),
    ),
    GetPage(
      name: Routes.alida,
      page: () => const Alida(),
    ),
    GetPage(
      name: Routes.alrotoba,
      page: () => const Alrotoba(),
    ),
    GetPage(
      name: Routes.alsaf,
      page: () => const Alsaf(),
    ),
    GetPage(
      name: Routes.alshata,
      page: () => const Alshata(),
    ),
    GetPage(
      name: Routes.altaganous,
      page: () => const Altaganous(),
    ),
    GetPage(
      name: Routes.awzan,
      page: () => const Awzan(),
    ),
    GetPage(
      name: Routes.asthlak,
      page: () => const Asthlak(),
    ),
    GetPage(name: Routes.solalat,
     page: () => const Solalat(),
     ),
    GetPage(
      name: Routes.alardya,
      page: () => const Alardya(),
    ),
    GetPage(
      name: Routes.amard,
      page: () => const Amard(),
    ),
    GetPage(
      name: Routes.a3ard,
      page: () => const A3ard(),
    ),
    GetPage(
      name: Routes.aL3lag,
      page: () => const AL3lag(),
    ),
    GetPage(
      name: Routes.nasa7a,
      page: () => const Nasa7a(),
    ),
    GetPage(
      name: Routes.astaqbal,
      page: () => const Astaqbal(),
    ),
    GetPage(
      name: Routes.akhtaq,
      page: () => const Akhtaq(),
    ),
    GetPage(
      name: Routes.tather,
      page: () => const Tather(),
    ),
    GetPage(
      name: Routes.ta7sen,
      page: () => const Ta7sen(),
    ),
  ];
}

class Routes {
  static const homeScreen = "/homeScreen";

//bat
  static const batMolar = "/batmolar";
  static const batFiransawi = "/batfiransawi";
  static const batMaskufi = "/batmaskufi";

//byd
  static const bydAbid = "/bydAbid";
  static const bydAihmar = "/bydAihmar";
  static const bydBaladi = "/bydBaladi";

  //frakh
  static const frakhAbid = "/frakhAbid";
  static const frakhSasso = "/frakhSasso";
  static const frakhBaladi = "/frakhBaladi";
  static const frakhAmhitAbid = "/frakhAmhitAbid";

  //katkit
  static const katKitAbid = "/katKitAbid";
  static const katkitBaladi = "/katkitBaladi";
  static const katkitSasso = "/katkitSasso";

//a3laf
  static const a3laf = "/a3laf";

  static const dartgetAl7rara = "/dartgetAl7rara";
  static const alida = "/alida";
  static const alrotoba = "/alrotoba";
  static const alsaf = "/alsaf";
  static const alshata = "/alshata";
  static const altaganous = "/altaganous";
  static const awzan = "/awzan";
  static const asthlak = "/asthlak";
  static const solalat = "/solalat";
  static const alardya = "/alardya";
  static const amard = "/amard";
  static const a3ard = "/a3ard";
  static const aL3lag = "/aL3lag";
  static const nasa7a = "/nasa7a";
  static const astaqbal = "/astaqbal";
  static const akhtaq = "/akhtaq";
  static const tather = "/tather";
  static const ta7sen = "/ta7sen";
}
