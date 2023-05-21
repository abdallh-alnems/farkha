import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/model/ll.dart';
import 'package:farkha_app/service/ll.dart';
import 'package:get/get.dart';

class DataController2 extends GetxController {
  final data = <DataModel2>[].obs;

  @override
  void onInit() {
    data.bindStream(FirestoreDB2().getAllData2()  );
   
    super.onInit();
  }
}
