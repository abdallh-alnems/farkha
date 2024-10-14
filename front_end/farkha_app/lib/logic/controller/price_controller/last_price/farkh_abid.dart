import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../../core/constant/id/link_api.dart';
import '../../../../data/model/last_priec/farkh_abid.dart';

class LastPriceFarkhAbidController extends GetxController {
  Future<List<ModelLastPriceFarkhAbid>> allFetchProducts() async {
    try {
      final response = await http.get(Uri.parse(ApiLinks.linkViewLastPriceFarkhAbid));

      if (response.statusCode == 200) {
        print(
            "===================================================================================");
        print("تم احضار البيانات");
        print(response.body); // طباعة محتوى الاستجابة
        print(
            "===================================================================================");

        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // تحقق من وجود المفتاح 'data' في الاستجابة
        if (responseData.containsKey('data')) {
          final List<dynamic> jsonData = responseData['data'];
          return jsonData
              .map((json) => ModelLastPriceFarkhAbid.fromJson(json))
              .toList();
        } else {
          print("البيانات غير متاحة في الاستجابة");
          return [];
        }
      } else {
        print(
            "===================================================================================");
        print("لم يتم احضار البيانات: ${response.statusCode}");
        print(
            "===================================================================================");
        throw Exception('فشل في جلب البيانات');
      }
    } catch (error) {
         print(
            "===================================================================================");
        print("لم يتم احضار البيانات:");
        print(
            "===================================================================================");
      print("حدث خطأ أثناء جلب البيانات: $error");
      throw Exception('فشل في جلب البيانات');
    }
  }
}
