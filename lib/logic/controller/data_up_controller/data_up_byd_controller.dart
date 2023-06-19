import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataUpBydController extends GetxController {
  RxBool upIsLoading = true.obs;

  //byd
  List<DataModel> upBydAbid = <DataModel>[];
  List<DataModel> upBydAihmar = <DataModel>[];
  List<DataModel> upBydBaladi = <DataModel>[];

// onInit
  @override
  void onInit() {
    upIsLoading.value = true;

    dataUpBydAbid();
    dataUpBydAihmar();
    dataUpBydBaladi();

    super.onInit();
  }

//bat

  void dataUpBydAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'byd', doc: 'UPAbid');
    upBydAbid = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }

  void dataUpBydAihmar() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'byd', doc: 'UpAihmar');
    upBydAihmar = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }

  void dataUpBydBaladi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'byd', doc: 'UpBaladi');
    upBydBaladi = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }
}
