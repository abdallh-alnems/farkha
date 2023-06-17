import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataBydController extends GetxController {
  RxBool isLoading = true.obs;

  //byd
  List<DataModel> bydAbid = <DataModel>[];
  List<DataModel> bydAihmar = <DataModel>[];
  List<DataModel> bydBaladi = <DataModel>[];

// onInit
  @override
  void onInit() {
    isLoading.value = true;

    dataBydAbid();
    dataBydAihmar();
    dataBydBaladi();

    super.onInit();
  }

//bat

  void dataBydAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'byd', doc: 'abid');
    bydAbid = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }

  void dataBydAihmar() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'byd', doc: 'aihmar');
    bydAihmar = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }

  void dataBydBaladi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'byd', doc: 'baladi');
    bydBaladi = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }
}
