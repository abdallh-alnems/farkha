// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'data/datasource/static/data_list/articles_list.dart';
// import 'package:flutter/material.dart';

// import 'view/widget/follow_up_tools/articles/articles/text_article/type_article.dart';


// class Asthlak extends StatelessWidget {
//   const Asthlak({super.key});

//   @override
//   Widget build(BuildContext context) {
//     List<TableRow> rows = [];

//     TableRow _tpye = TableRow(children: <Widget>[
//       Padding(
//         padding: EdgeInsets.symmetric(vertical: 7).r,
//         child: Text(
//           ' الاستهلاك بالجرام',
//           style: Theme.of(context).textTheme.headlineMedium,
//           textAlign: TextAlign.center,
//         ),
//       ),
//       Text(
//         'العمر باليوم',
//         style: Theme.of(context).textTheme.headlineMedium,
//         textAlign: TextAlign.center,
//       )
//     ]);

//     for (int i = 1; i <= 45; i++,) {
//       String consumption = consumptions[i];

//       TableRow row = TableRow(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: 7).r,
//             child: Text(
//               consumption,
//               style: TextStyle(fontSize: 19.sp),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           Text(
//             '$i',
//             style: TextStyle(fontSize: 19.sp),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       );
//       rows.add(row);
//     }
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               const ArrowBack(),
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   children: [
//                     TypeArticle(
//                       type:
//                           ' هناك بعض النقاط المتعلقة بإستهلاك الفراخ البيضاء للعلف',
//                     ),
//                     TypeArticle(
//                       type:
//                           '1 - العلف المتوازن: يجب توفير علف متوازن تغذيتيًا يحتوي على النسب المناسبة من البروتين والدهون والكربوهيدرات، ويجب تغذية الفراخ بكميات مناسبة وفقًا للعمر والوزن.',
//                     ),
//                     TypeArticle(
//                       type:
//                           '2 - النوعية: يجب استخدام علف عالي الجودة والمصمم خصيصًا لتلبية احتياجات الفراخ البيضاء، ويجب تجنب استخدام العلف الفاسد أو الفاسد.',
//                     ),
//                     TypeArticle(
//                       type:
//                           '3 - الماء: يجب توفير الماء النظيف والعذب بشكل دائم للفراخ، ويجب تغيير الماء بانتظام للحفاظ على نظافته، ويزيد استهلاك الفرخ للعلف بزيادة استخدامه للماء.',
//                     ),
//                     TypeArticle(
//                       type:
//                           '4 - البيئة: يجب توفير بيئة مناسبة للفراخ تحتوي على درجة حرارة ورطوبة مناسبة، ويجب تجنب التعرض للإجهاد والضوضاء والاضطرابات في البيئة المحيطة بالفراخ.',
//                     ),
//                     TypeArticle(
//                       type:
//                           '5 - المراقبة: يجب مراقبة استهلاك الفراخ للعلف وزيادة وزنها بشكل منتظم، وتعديل كمية العلف وفقًا للحاجة، ومراقبة الفراخ لأي أعراض للمرض أو الوفاة المفاجئة.',
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                   ],
//                 ),
//               ),
//               const Text(
//                   'الجدول التالي يمثل  استهلاك الفراخ البيضاء للعلف بالجرام عند عمر كل يوم'),
//               const Text(
//                 'ملحوظه : الفرخ الابيض  ياكل متوسط 3.5 كيلو علف طول الدورة',
//                 style: TextStyle(color: Colors.red),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(
//                 width: double.infinity,
//                 child: Table(
//                     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//                     border: TableBorder.all(),
//                     children: <TableRow>[_tpye, ...rows]),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
