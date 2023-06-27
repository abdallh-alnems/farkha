import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farkha_app/model/data_model.dart';
import 'package:get/get.dart';

class KatKitBaladiController extends GetxController {
  
  DataModel? upmyData;
   DataModel? downmyData;
  

  @override
  void onInit() {
    super.onInit();
    upData();
    downData();
  }

  void upData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('katakit')
        .doc('UpBaladi')
        .get();
    if (documentSnapshot.exists) {
      upmyData = DataModel.fromSnapshot(documentSnapshot);     
      update();
    }
  }

  void downData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('katakit')
        .doc('DownBaladi')
        .get();
    if (documentSnapshot.exists) {
      downmyData = DataModel.fromSnapshot(documentSnapshot);
      update();
    }
  }
}
