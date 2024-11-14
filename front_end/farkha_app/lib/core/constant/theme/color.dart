import 'package:flutter/material.dart';

class AppColor {
  static const Color primaryColor = Color(0xff2A4D69);
  static const Color secondaryColor = Color(0xffDAE2E3);
  static Color appBackGroundColor = Color(0xffF1F1F1);
}

// class AppColor extends ChangeNotifier {
//   late Color primaryColor;
//   late Color secondaryColor;
//   late Color appBackGroundColor;

//   AppColor(Brightness brightness) {
//     _updateColors(brightness);
//   }

//   void updateBrightness(Brightness brightness) {
//     _updateColors(brightness);
//     notifyListeners();
//   }

//   void _updateColors(Brightness brightness) {
//     if (brightness == Brightness.dark) {
//       primaryColor = const Color(0xff4C708E);
//       secondaryColor = const Color(0xffB8C2C3);
//       appBackGroundColor = const Color(0xFF202124);
//     } else {
//       primaryColor = const Color(0xff2A4D69);
//       secondaryColor = const Color(0xffDAE2E3);
//       appBackGroundColor = const Color(0xffF1F1F1);
//     }
//   }
// }

