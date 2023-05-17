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
      page: () => const HomeScreen(),
    )
  ];
}

class Routes {
  // ignore: constant_identifier_names
  static const Onboarding = "/onboarding";
  // ignore: constant_identifier_names
  static const HomeScreen = "/homeScreen";
}
