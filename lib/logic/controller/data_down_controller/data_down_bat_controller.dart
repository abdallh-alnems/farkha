import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataDownBatController extends GetxController {
  RxBool downIsLoading = true.obs;

//bat
  List<DataModel> downBatMolar = <DataModel>[];
  List<DataModel> downBatFiransawi = <DataModel>[];
  List<DataModel> downBatMaskufi = <DataModel>[];

// onInit
  @override
  void onInit() {
    downIsLoading.value = true;

    dataDownBatMolar();
    dataDownBatFiransawi();
    dataDownBatMaskufi();

    super.onInit();
  }

//bat

  void dataDownBatMolar() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'bat', doc: 'DownMolar');
    downBatMolar = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }

  void dataDownBatFiransawi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'bat', doc: 'DownFiransawi');
    downBatFiransawi = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }

  void dataDownBatMaskufi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'bat', doc: 'DownMaskufi');
    downBatMaskufi = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }
}
