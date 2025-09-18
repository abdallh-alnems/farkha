// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// import 'core/constant/id/link_api.dart';

// // Model لمحتوى المقال
// class ArticleContentModel {
//   final String content;

//   ArticleContentModel({required this.content});

//   factory ArticleContentModel.fromJson(Map<String, dynamic> json) {
//     return ArticleContentModel(content: json['content'] ?? '');
//   }
// }

// // Controller لمحتوى المقال
// class ArticleContentController extends GetxController {
//   final RxString articleContent = ''.obs;
//   final RxBool isLoading = false.obs;
//   final RxString error = ''.obs;
//   final TextEditingController idController = TextEditingController();

//   @override
//   void onClose() {
//     idController.dispose();
//     super.onClose();
//   }

//   Future<void> fetchArticleContent(int articleId) async {
//     try {
//       isLoading.value = true;
//       error.value = '';

//       // استخدام الرابط من link_api.dart مع id
//       final response = await http.get(
//         Uri.parse('${ApiLinks.articlesContent}?id=$articleId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data['status'] == 'success' && data['data'] != null) {
//           final List<dynamic> contentData = data['data'];
//           if (contentData.isNotEmpty) {
//             final content = ArticleContentModel.fromJson(contentData[0]);
//             articleContent.value = content.content;
//           } else {
//             error.value = 'لا يوجد محتوى للمقال';
//           }
//         } else {
//           error.value = 'فشل في تحميل المحتوى';
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

//   void clearContent() {
//     articleContent.value = '';
//     error.value = '';
//   }
// }

// // صفحة تجربة محتوى المقال
// class ArticleContentTestPage extends StatelessWidget {
//   const ArticleContentTestPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ArticleContentController controller = Get.put(
//       ArticleContentController(),
//     );

//     // استقبال البيانات المرسلة من test.dart
//     final arguments = Get.arguments as Map<String, dynamic>?;
//     final int? articleId = arguments?['articleId'];
//     final String? articleTitle = arguments?['articleTitle'];

//     // إذا تم تمرير ID، قم بجلب المحتوى تلقائياً
//     if (articleId != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         controller.idController.text = articleId.toString();
//         controller.fetchArticleContent(articleId);
//       });
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(articleTitle ?? 'محتوى المقال - تجربة'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             onPressed: controller.clearContent,
//             icon: const Icon(Icons.clear),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // حقل إدخال ID
//             Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'أدخل ID المقال:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: controller.idController,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         hintText: 'مثال: 1',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.numbers),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           final id = int.tryParse(controller.idController.text);
//                           if (id != null && id > 0) {
//                             controller.fetchArticleContent(id);
//                           } else {
//                             Get.snackbar(
//                               'خطأ',
//                               'يرجى إدخال ID صحيح',
//                               backgroundColor: Colors.red,
//                               colorText: Colors.white,
//                             );
//                           }
//                         },
//                         icon: const Icon(Icons.search),
//                         label: const Text('جلب المحتوى'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // عرض المحتوى
//             Expanded(
//               child: Obx(() {
//                 if (controller.isLoading.value) {
//                   return const Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(),
//                         SizedBox(height: 16),
//                         Text('جاري تحميل المحتوى...'),
//                       ],
//                     ),
//                   );
//                 }

//                 if (controller.error.value.isNotEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.error_outline,
//                           size: 64,
//                           color: Colors.red[300],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'خطأ: ${controller.error.value}',
//                           style: const TextStyle(fontSize: 16),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () {
//                             final id = int.tryParse(
//                               controller.idController.text,
//                             );
//                             if (id != null && id > 0) {
//                               controller.fetchArticleContent(id);
//                             }
//                           },
//                           child: const Text('إعادة المحاولة'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 if (controller.articleContent.value.isEmpty) {
//                   return const Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.article_outlined,
//                           size: 64,
//                           color: Colors.grey,
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'أدخل ID المقال لعرض المحتوى',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Row(
//                             children: [
//                               Icon(Icons.article, color: Colors.green),
//                               SizedBox(width: 8),
//                               Text(
//                                 'محتوى المقال:',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           const Divider(),
//                           const SizedBox(height: 12),
//                           Container(
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey.shade300),
//                               borderRadius: BorderRadius.circular(8),
//                               color: Colors.white,
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Html(
//                                 data: controller.articleContent.value,
//                                 // تفعيل دعم الجداول
//                                 onLinkTap: (url, attributes, element) {
//                                   // معالجة الروابط إذا لزم الأمر
//                                 },
//                                 // إعدادات إضافية للجداول
//                                 shrinkWrap: true,
//                                 style: {
//                                   "body": Style(
//                                     fontSize: FontSize(16), // حجم افتراضي
//                                     lineHeight: const LineHeight(1.7),
//                                     textAlign: TextAlign.right,
//                                     fontFamily: 'Cairo',
//                                     color: Colors.black87,
//                                   ),
//                                   "p": Style(
//                                     fontSize: FontSize(16),
//                                     margin: Margins.only(bottom: 12),
//                                     textAlign: TextAlign.right,
//                                   ),
//                                   // إعدادات الجدول
//                                   "table": Style(
//                                     width: Width(100, Unit.percent),
//                                     margin: Margins.only(bottom: 16),
//                                     backgroundColor: Colors.white,
//                                     border: Border.all(
//                                       color: Colors.grey.shade400,
//                                       width: 1,
//                                     ),
//                                     display: Display.table,
//                                   ),
//                                   "thead": Style(
//                                     backgroundColor: Colors.grey.shade100,
//                                     display: Display.tableHeaderGroup,
//                                   ),
//                                   "tbody": Style(
//                                     backgroundColor: Colors.white,
//                                     display: Display.tableRowGroup,
//                                   ),
//                                   "tr": Style(
//                                     backgroundColor: Colors.white,
//                                     border: Border.all(
//                                       color: Colors.grey.shade300,
//                                       width: 1,
//                                     ),
//                                     display: Display.tableRow,
//                                   ),
//                                   "th": Style(
//                                     padding: HtmlPaddings.all(12),
//                                     backgroundColor: Colors.green.shade50,
//                                     fontSize: FontSize(14),
//                                     fontWeight: FontWeight.bold,
//                                     textAlign: TextAlign.center,
//                                     fontFamily: 'Cairo',
//                                     color: Colors.green.shade800,
//                                     border: Border.all(
//                                       color: Colors.grey.shade400,
//                                       width: 1,
//                                     ),
//                                     display: Display.tableCell,
//                                   ),
//                                   "td": Style(
//                                     padding: HtmlPaddings.all(10),
//                                     fontSize: FontSize(14),
//                                     textAlign: TextAlign.center,
//                                     fontFamily: 'Cairo',
//                                     backgroundColor: Colors.white,
//                                     color: Colors.black87,
//                                     border: Border.all(
//                                       color: Colors.grey.shade300,
//                                       width: 1,
//                                     ),
//                                     display: Display.tableCell,
//                                   ),
//                                   "h1": Style(
//                                     fontSize: FontSize(24),
//                                     fontWeight: FontWeight.bold,
//                                     textAlign: TextAlign.center,
//                                     margin: Margins.only(bottom: 16),
//                                     fontFamily: 'Cairo',
//                                     color: Colors.green.shade700,
//                                   ),
//                                   "h2": Style(
//                                     fontSize: FontSize(20),
//                                     fontWeight: FontWeight.bold,
//                                     textAlign: TextAlign.center,
//                                     margin: Margins.only(bottom: 12),
//                                     fontFamily: 'Cairo',
//                                     color: Colors.green.shade700,
//                                   ),
//                                   "h3": Style(
//                                     fontSize: FontSize(18),
//                                     fontWeight: FontWeight.bold,
//                                     textAlign: TextAlign.right,
//                                     margin: Margins.only(bottom: 10),
//                                     fontFamily: 'Cairo',
//                                     color: Colors.green.shade600,
//                                   ),
//                                   // ⚠️ مهم: احذف أو ما تكتبش style للـ "span"
//                                   // علشان ما يطغاش على inline style من قاعدة البيانات
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           final id = int.tryParse(controller.idController.text);
//           if (id != null && id > 0) {
//             controller.fetchArticleContent(id);
//           } else {
//             Get.snackbar(
//               'خطأ',
//               'يرجى إدخال ID صحيح',
//               backgroundColor: Colors.red,
//               colorText: Colors.white,
//             );
//           }
//         },
//         backgroundColor: Colors.green,
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }

// // دالة main للتجربة
// void main() {
//   runApp(
//     const GetMaterialApp(
//       title: 'تجربة محتوى المقال',
//       home: ArticleContentTestPage(),
//       debugShowCheckedModeBanner: false,
//     ),
//   );
// }
