import 'package:get/get.dart';
import '../../../test.dart';
import '../../../view/screen/home_screen.dart';
import 'route.dart';

List<GetPage<dynamic>> pages = [
  // ============================== root =======================================

  GetPage(name: "/", page: () => HomeScreen()),
  GetPage(name: AppRoute.test, page: () => Test()),
    GetPage(name: AppRoute.adad, page: () => ADAD()),

];
