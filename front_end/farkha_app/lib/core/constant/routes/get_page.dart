import 'package:get/get.dart';
import '../../../view/screen/home_screen.dart';

List<GetPage<dynamic>> pages = [
  // ============================== root =======================================

  GetPage(name: "/", page: () => const HomeScreen()),
];
