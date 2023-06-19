import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataKatakitController extends GetxController {
  RxBool upIsLoading = true.obs;

  //katakit
  List<DataModel> upKatakitAbid = <DataModel>[];
  List<DataModel> upKatakitBaladi = <DataModel>[];
  List<DataModel> upKatakitSasso = <DataModel>[];

// onInit
  @override
  void onInit() {
    upIsLoading.value = true;

    dataUpKatakitAbid();
    dataUpKatakitBaladi();
    dataUpKatakitSasso();

    super.onInit();
  }

  //katakit

  void dataUpKatakitAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'katakit', doc: 'UpAbid');
    upKatakitAbid = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }

  void dataUpKatakitBaladi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'katakit', doc: 'UpBaladi');
    upKatakitBaladi = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }

  void dataUpKatakitSasso() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'katakit', doc: 'UpSasso');
    upKatakitSasso = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }
}
