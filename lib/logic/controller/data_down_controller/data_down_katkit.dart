import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataDownKatakitController extends GetxController {
  RxBool downIsLoading = true.obs;

  //katakit
  List<DataModel> downKatakitAbid = <DataModel>[];
  List<DataModel> downKatakitBaladi = <DataModel>[];
  List<DataModel> downKatakitSasso = <DataModel>[];

// onInit
  @override
  void onInit() {
    downIsLoading.value = true;

    dataDownKatakitAbid();
    dataDownKatakitBaladi();
    dataDownKatakitSasso();

    super.onInit();
  }

  //katakit

  void dataDownKatakitAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'katakit', doc: 'DownAbid');
    downKatakitAbid = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }

  void dataDownKatakitBaladi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'katakit', doc: 'DownBaladi');
    downKatakitBaladi = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }

  void dataDownKatakitSasso() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'katakit', doc: 'DownSasso');
    downKatakitSasso = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }
}
