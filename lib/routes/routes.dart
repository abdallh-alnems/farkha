import 'package:farkha_app/logic/binding/bat_bindings/bat_firansawi_binding.dart';
import 'package:farkha_app/logic/binding/bat_bindings/bat_maskufi_binding.dart';
import 'package:farkha_app/logic/binding/bat_bindings/bat_molar_binding.dart';
import 'package:farkha_app/logic/binding/byd_bindings/byd_abid_binding.dart';
import 'package:farkha_app/logic/binding/byd_bindings/byd_aihmar_binding.dart';
import 'package:farkha_app/logic/binding/byd_bindings/byd_baladi_binding.dart';
import 'package:farkha_app/logic/binding/frakh_bindings/frakh_abid_binding.dart';
import 'package:farkha_app/logic/binding/frakh_bindings/frakh_amihat_abid_binding.dart';
import 'package:farkha_app/logic/binding/frakh_bindings/frakh_baladi_binding.dart';
import 'package:farkha_app/logic/binding/frakh_bindings/frakh_sasso_binding.dart';
import 'package:farkha_app/logic/binding/katkitBindings/kakit_baladi_binding.dart';
import 'package:farkha_app/logic/binding/katkitBindings/katkit_abid_binding.dart';
import 'package:farkha_app/logic/binding/katkitBindings/katkit_sasso_binding.dart';
import 'package:farkha_app/view/screen/drawer/3lag.dart';
import 'package:farkha_app/view/screen/drawer/a3rad.dart';
import 'package:farkha_app/view/screen/drawer/akhtaq.dart';
import 'package:farkha_app/view/screen/drawer/amrad.dart';
import 'package:farkha_app/view/screen/drawer/astaqbal.dart';
import 'package:farkha_app/view/screen/drawer/nasa7a.dart';
import 'package:farkha_app/view/screen/drawer/ta7sen.dart';
import 'package:farkha_app/view/screen/drawer/tather.dart';
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
      binding: BatMolarBinding(),
    ),
    GetPage(
      name: Routes.BatFiransawi,
      page: () => BatFiransawi(),
      binding: BatFiransawiBinding(),
    ),
    GetPage(
      name: Routes.BatMaskufi,
      page: () => BatMaskufi(),
      binding: BatMaskufiBinding(),
    ),

//byd
    GetPage(
      name: Routes.BydAbid,
      page: () => BydAbid(),
      binding: BydAbidBinding(),
    ),
    GetPage(
      name: Routes.BydAihmar,
      page: () => BydAihmar(),
      binding: BydAihmarBinding(),
    ),
    GetPage(
      name: Routes.BydBaladi,
      page: () => BydBaladi(),
      binding: BydBaladiBinding(),
    ),


//frakh
    GetPage(
      name: Routes.FrakhAbid,
      page: () => FrakhAbid(),
      binding: FrakhAbidBinding(),
    ),
    GetPage(
      name: Routes.FrakhAmhitAbid,
      page: () => FrakhAmhitAbid(),
      binding: FrakhAmhitAbidBinding(),
    ),
    GetPage(
      name: Routes.FrakhBaladi,
      page: () => FrakhBaladi(),
      binding: FrakhBaladiBinding(),
    ),
     GetPage(
      name: Routes.FrakhSasso,
      page: () => FrakhSasso(),
      binding: FrakhSassoBinding(),
    ),


    //katkit
    GetPage(
      name: Routes.KatKitAbid,
      page: () => KatkitAbid(),
      binding: KatakitAbidBinding(),
    ),
    GetPage(
      name: Routes.KatkitBaladi,
      page: () => KatkitBaladi(),
      binding: KatakitBaladiBinding(),
    ),
    GetPage(
      name: Routes.KatkitSasso,
      page: () => KatkitSasso(),
      binding: KatakitSassoBinding(),
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
