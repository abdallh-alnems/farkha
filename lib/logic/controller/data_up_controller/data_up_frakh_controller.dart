import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataFrakhController extends GetxController {
  RxBool upIsLoading = true.obs;

  //frakh
  List<DataModel> upFrakhAbid = <DataModel>[];
  List<DataModel> upFrakhBaladi = <DataModel>[];
  List<DataModel> upFrakhSasso = <DataModel>[];
  List<DataModel> upFrakhAmihatAbid = <DataModel>[];

// onInit
  @override
  void onInit() {
    upIsLoading.value = true;

    dataUpFrakhAbid();
    dataUpFrakhBaladi();
    dataUpFrakhSasso();
    dataUpFrakhAmihatAbid();

    super.onInit();
  }

//frakh

  void dataUpFrakhAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'UpAbid');
    upFrakhAbid = await firestoreDB.getAllData();
    upIsLoading.value = false;

    update();
  }

  void dataUpFrakhBaladi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'UpBaladi');
    upFrakhBaladi = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }

  void dataUpFrakhSasso() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'UpSasso');
    upFrakhSasso = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }

  void dataUpFrakhAmihatAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'UpAmihatAbid');
    upFrakhAmihatAbid = await firestoreDB.getAllData();
    upIsLoading.value = false;
    update();
  }
}
