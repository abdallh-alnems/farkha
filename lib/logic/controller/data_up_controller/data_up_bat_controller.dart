import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataUpBatController extends GetxController {
  RxBool upIsLoading = true.obs;

//bat
  List<DataModel> upBatMolar = <DataModel>[];
  List<DataModel> upBatFiransawi = <DataModel>[];
  List<DataModel> upBatMaskufi = <DataModel>[];

// onInit
  @override
  void onInit() {
    upIsLoading.value = true;

    dataUpBatMolar();
    dataUpBatFiransawi();
    dataUpBatMaskufi();

    super.onInit();
  }

//bat

  void dataUpBatMolar() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'bat', doc: 'UpMolar');
    upBatMolar = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }

  void dataUpBatFiransawi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'bat', doc: 'UpFiransawi');
    upBatFiransawi = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }

  void dataUpBatMaskufi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'bat', doc: 'UpMaskufi');
    upBatMaskufi = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }
}
