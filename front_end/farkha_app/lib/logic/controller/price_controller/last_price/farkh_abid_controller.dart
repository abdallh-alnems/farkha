import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../../../core/constant/headers.dart';
import '../../../../core/constant/id/link_api.dart';
import '../../../../data/model/farkh_abid_model.dart';

class LastPriceFarkhAbidController extends GetxController {
  Future<List<ModelLastPriceFarkhAbid>> allFetchProducts() async {
     Map<String, String> myheaders = getMyHeaders();
    try {
      final response =
          await http.get(Uri.parse(ApiLinks.linkFarkhAbid), headers: myheaders);

      if (response.statusCode == 200) {
        print("تم احضار البيانات بنجاح");
        final responseData = jsonDecode(response.body);

        // التحقق من أن الاستجابة تحتوي على البيانات المطلوبة
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final List<dynamic> jsonData = responseData['data'];

          // تحويل البيانات إلى نماذج
          return jsonData
              .map((json) => ModelLastPriceFarkhAbid.fromJson(json))
              .toList();
        } else {
          print("البيانات غير متاحة في الاستجابة");
          return [];
        }
      } else {
        print("لم يتم احضار البيانات: ${response.statusCode}");
        throw Exception('فشل في جلب البيانات');
      }
    } catch (error) {
      print("حدث خطأ أثناء جلب البيانات: $error");
      throw Exception('فشل في جلب البيانات');
    }
  }
}
