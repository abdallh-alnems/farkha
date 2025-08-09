// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ViewCalculateController extends GetxController {
//   late ScrollController scrollController;
//   AnimationController? animationController;
//   bool isUserScrolling = false;
//   TickerProvider? tickerProvider;

//   void initializeTicker(TickerProvider provider) {
//     try {
//       tickerProvider = provider;
//       scrollController = ScrollController();

//       // تأكد من أن tickerProvider متاح قبل إنشاء AnimationController
//       if (tickerProvider != null) {
//         animationController = AnimationController(
//           duration: const Duration(seconds: 15),
//           vsync: tickerProvider!,
//         );

//         // Listen to scroll events to detect user interaction
//         scrollController.addListener(() {
//           try {
//             if (scrollController.hasClients &&
//                 scrollController.position.isScrollingNotifier.value) {
//               isUserScrolling = true;
//               animationController?.stop();
//             }
//           } catch (e) {
//             print('Scroll listener error: $e');
//           }
//         });

//         // Start automatic scrolling after a short delay to ensure ScrollView is ready
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _startAutoScroll();
//         });
//       }
//     } catch (e) {
//       print('Error initializing ViewCalculateController: $e');
//     }
//   }

//   void _startAutoScroll() {
//     try {
//       if (animationController == null || !scrollController.hasClients) {
//         // إذا لم يكن ScrollController جاهزاً، حاول مرة أخرى بعد فترة
//         Future.delayed(const Duration(milliseconds: 100), () {
//           _startAutoScroll();
//         });
//         return;
//       }

//       animationController!.addStatusListener((status) {
//         try {
//           if (status == AnimationStatus.completed) {
//             // Reverse direction when reaching the end
//             animationController!.reverse();
//           } else if (status == AnimationStatus.dismissed) {
//             // Forward direction when reaching the beginning
//             animationController!.forward();
//           }
//         } catch (e) {
//           print('Animation status listener error: $e');
//         }
//       });

//       animationController!.addListener(() {
//         try {
//           if (!isUserScrolling &&
//               scrollController.hasClients &&
//               scrollController.position.hasPixels &&
//               scrollController.position.hasViewportDimension) {
//             final maxScroll = scrollController.position.maxScrollExtent;
//             if (maxScroll > 0) {
//               final currentScroll = animationController!.value * maxScroll;
//               scrollController.jumpTo(currentScroll);
//             }
//           }
//         } catch (e) {
//           print('Animation listener error: $e');
//         }
//       });

//       animationController!.forward();
//     } catch (e) {
//       print('Error starting auto scroll: $e');
//     }
//   }

//   @override
//   void onClose() {
//     try {
//       scrollController.dispose();
//       animationController?.dispose();
//     } catch (e) {
//       print('Error closing ViewCalculateController: $e');
//     }
//     super.onClose();
//   }
// }
