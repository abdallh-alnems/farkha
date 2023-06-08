import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataBatController extends GetxController {
  
RxBool isLoading = true.obs;

//bat
  List<DataModel> batMolar = <DataModel>[];
  List<DataModel> batFiransawi = <DataModel>[];
  List<DataModel> batMaskufi = <DataModel>[];


  

// onInit
 @override
  void onInit() {
    isLoading.value = true;

    dataBatMolar();
    dataBatFiransawi();
    dataBatMaskufi();

    super.onInit();
  }  

//bat

 void dataBatMolar() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'baladi');
    batMolar = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }

   void dataBatFiransawi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'baladi');
    batFiransawi = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }


  void dataBatMaskufi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'sasso');
    batMaskufi = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }

  


  


}
