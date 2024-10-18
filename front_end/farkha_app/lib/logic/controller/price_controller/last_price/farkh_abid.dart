import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../../../core/constant/id/link_api.dart';
import '../../../../data/model/last_priec/farkh_abid.dart';

class LastPriceFarkhAbidController extends GetxController {
  Future<List<ModelLastPriceFarkhAbid>> allFetchProducts() async {
     String securityKey = dotenv.get("SECURITY_KEY");
    String securityUser = dotenv.get("SECURITY_USER");
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$securityUser:$securityKey'))}';
    Map<String, String> myheaders = {'authorization': basicAuth};
    try {
      final response =
          await http.get(Uri.parse(ApiLinks.linkViewLastPriceFarkhAbid), headers: myheaders);

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
