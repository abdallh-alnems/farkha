import 'package:get/get.dart';
import '../view/screen/add_price.dart';
import '../view/screen/home_screen.dart';
import 'route.dart';

List<GetPage<dynamic>> pages = [
  // ============================== root =======================================

  GetPage(name: "/", page: () => HomeScreen()),
    GetPage(name:AppRoute.add, page: () => AddPrice()),


];
