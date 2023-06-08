import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataFrakhController extends GetxController {
  
RxBool isLoading = true.obs;

  //frakh
  List<DataModel> frakhAbid = <DataModel>[];
  List<DataModel> frakhBaladi = <DataModel>[];
  List<DataModel> frakhSasso = <DataModel>[];
  List<DataModel> frakhAmihatAbid = <DataModel>[];


  

// onInit
 @override
  void onInit() {
    isLoading.value = true;

    dataFrakhAbid();
    dataFrakhBaladi();
    dataFrakhSasso();
    dataFrakhAmihatAbid();

    super.onInit();
  }  

//frakh

  void dataFrakhAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'abid');
    frakhAbid = await firestoreDB.getAllData();
        isLoading.value = false;

    update();
  }

  void dataFrakhBaladi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'baladi');
    frakhBaladi = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }

  void dataFrakhSasso() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'sasso');
    frakhSasso = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }

  void dataFrakhAmihatAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'amihat abid');
    frakhAmihatAbid = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }


  


}
