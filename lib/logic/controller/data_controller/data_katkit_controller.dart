import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataKatakitController extends GetxController {
  RxBool isLoading = true.obs;

  //katakit
  List<DataModel> katakitAbid = <DataModel>[];
  List<DataModel> katakitBaladi = <DataModel>[];
  List<DataModel> katakitSasso = <DataModel>[];

// onInit
  @override
  void onInit() {
    isLoading.value = true;

    dataKatakitAbid();
    dataKatakitBaladi();
    dataKatakitSasso();

    super.onInit();
  }

    //katakit

    void dataKatakitAbid() async {
      final DataFirestore firestoreDB =
          DataFirestore(collection: 'katakit', doc: 'abid');
      katakitAbid = await firestoreDB.getAllData();
      isLoading.value = false;
      update();
    }

    void dataKatakitBaladi() async {
      final DataFirestore firestoreDB =
          DataFirestore(collection: 'katakit', doc: 'baladi');
      katakitBaladi = await firestoreDB.getAllData();
      isLoading.value = false;
      update();
    }

    void dataKatakitSasso() async {
      final DataFirestore firestoreDB =
          DataFirestore(collection: 'katakit', doc: 'sasso');
      katakitSasso = await firestoreDB.getAllData();
      isLoading.value = false;
      update();
    }
  }

