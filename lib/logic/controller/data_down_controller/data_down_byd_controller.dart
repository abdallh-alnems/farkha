import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataDownBydController extends GetxController {
  RxBool downIsLoading = true.obs;

  //byd
  List<DataModel> downBydAbid = <DataModel>[];
  List<DataModel> downBydAihmar = <DataModel>[];
  List<DataModel> downBydBaladi = <DataModel>[];

// onInit
  @override
  void onInit() {
    downIsLoading.value = true;

    dataDownBydAbid();
    dataDownBydAihmar();
    dataDownBydBaladi();

    super.onInit();
  }

//bat

  void dataDownBydAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'byd', doc: 'DownAbid');
    downBydAbid = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }

  void dataDownBydAihmar() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'byd', doc: 'DownAihmar');

    downBydAihmar = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }

  void dataDownBydBaladi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'byd', doc: 'DownBaladi');
    downBydBaladi = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }
}
