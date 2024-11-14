// mport 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:upgrader/upgrader.dart';
// import '../check_min_version.dart';
// import 'messages.dart';

// class Upgrade extends StatelessWidget {
//   final Widget child;
//   const Upgrade({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     final versionController = Get.find<VersionController>();

//     return Obx(() {
      
//       if (versionController.minAppVersion.isNotEmpty) {
//         return UpgradeAlert(
//           upgrader: Upgrader(
//             minAppVersion: versionController.minAppVersion.value,
//             messages: UpgradeMessages(),
//           ),
//           showIgnore: false,
//           child: child,
//         );
//       }

      
//       return child; 
//     });

//   }
// }

  // static const Color primaryColor = Color(0xff4C708E); 
  // static const Color secondaryColor = Color(0xffB8C2C3); 
  // static Color appBackGroundColor = Color(0xFF202124); 