// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// import 'core/constant/id/link_api.dart';
// import 'test2.dart';

// class ArticleModel {
//   final int id;
//   final String title;

//   ArticleModel({required this.id, required this.title});

//   factory ArticleModel.fromJson(Map<String, dynamic> json) {
//     return ArticleModel(id: json['id'] ?? 0, title: json['title'] ?? '');
//   }
// }

// // Controller للمقالات
// class ArticlesController extends GetxController {
//   final RxList<ArticleModel> articles = <ArticleModel>[].obs;
//   final RxBool isLoading = false.obs;
//   final RxString error = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchArticles();
//   }

//   Future<void> fetchArticles() async {
//     try {
//       isLoading.value = true;
//       error.value = '';

//       // استخدام الرابط من link_api.dart
//       final response = await http.get(
//         Uri.parse(ApiLinks.articlesTitle),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data['status'] == 'success' && data['data'] != null) {
//           final List<dynamic> articlesData = data['data'];
//           articles.assignAll(
//             articlesData.map((json) => ArticleModel.fromJson(json)).toList(),
//           );
//         } else {
//           error.value = 'فشل في تحميل البيانات';
//         }
//       } else {
//         error.value = 'خطأ في الاتصال: ${response.statusCode}';
//       }
//     } catch (e) {
//       error.value = 'خطأ: $e';
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void refreshArticles() {
//     fetchArticles();
//   }
// }

// // صفحة عرض المقالات
// class ArticlesTestPage extends StatelessWidget {
//   const ArticlesTestPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ArticlesController controller = Get.put(ArticlesController());

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('المقالات - تجربة'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             onPressed: controller.refreshArticles,
//             icon: const Icon(Icons.refresh),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (controller.error.value.isNotEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'خطأ: ${controller.error.value}',
//                   style: const TextStyle(fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: controller.refreshArticles,
//                   child: const Text('إعادة المحاولة'),
//                 ),
//               ],
//             ),
//           );
//         }

//         if (controller.articles.isEmpty) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.article_outlined, size: 64, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text('لا توجد مقالات متاحة', style: TextStyle(fontSize: 16)),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: controller.articles.length,
//           itemBuilder: (context, index) {
//             final article = controller.articles[index];
//             return Card(
//               margin: const EdgeInsets.only(bottom: 12),
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(16),
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.blue[100],
//                   child: Text(
//                     '${index + 1}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ),
//                 title: Text(
//                   article.title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 subtitle: Text(
//                   'ID: ${article.id}',
//                   style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                 ),
//                 trailing: const Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16,
//                   color: Colors.grey,
//                 ),
//                 onTap: () {
//                   // الانتقال إلى صفحة محتوى المقال مع تمرير ID
//                   Get.to(
//                     () => const ArticleContentTestPage(),
//                     arguments: {
//                       'articleId': article.id,
//                       'articleTitle': article.title,
//                     },
//                   );
//                 },
//               ),
//             );
//           },
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: controller.refreshArticles,
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }

// // دالة main للتجربة
// void main() {
//   runApp(
//     const GetMaterialApp(
//       title: 'تجربة المقالات',
//       home: ArticlesTestPage(),
//       debugShowCheckedModeBanner: false,
//     ),
//   );
// }
