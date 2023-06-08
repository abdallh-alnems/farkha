import 'package:farkha_app/logic/binding/data_binding/bat_binding.dart';
import 'package:farkha_app/logic/binding/data_binding/byd_binding.dart';
import 'package:farkha_app/logic/binding/data_binding/frakh_binding.dart';
import 'package:farkha_app/logic/binding/data_binding/katkit_binding.dart';
import 'package:farkha_app/view/screen/choose_type/a3laf_type.dart';
import 'package:farkha_app/view/screen/choose_type/bat_type.dart';
import 'package:farkha_app/view/screen/choose_type/byd_type.dart';
import 'package:farkha_app/view/screen/choose_type/frakh_type.dart';
import 'package:farkha_app/view/screen/choose_type/katkit_type.dart';
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
    )
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

}
