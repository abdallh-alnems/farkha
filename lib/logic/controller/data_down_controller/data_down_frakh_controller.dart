import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataFrakhController extends GetxController {
  RxBool downIsLoading = true.obs;

  //frakh
  List<DataModel> downFrakhAbid = <DataModel>[];
  List<DataModel> downFrakhBaladi = <DataModel>[];
  List<DataModel> downFrakhSasso = <DataModel>[];
  List<DataModel> downFrakhAmihatAbid = <DataModel>[];

// onInit
  @override
  void onInit() {
    downIsLoading.value = true;

    dataDownFrakhAbid();
    dataDownFrakhBaladi();
    dataDownFrakhSasso();
    dataDownFrakhAmihatAbid();

    super.onInit();
  }

//frakh

  void dataDownFrakhAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'UpAbid');
    downFrakhAbid = await firestoreDB.getAllData();
    downIsLoading.value = false;

    update();
  }

  void dataDownFrakhBaladi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'UpBaladi');
    downFrakhBaladi = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }

  void dataDownFrakhSasso() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'UpSasso');
    downFrakhSasso = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }

  void dataDownFrakhAmihatAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'UpAmihatAbid');
    downFrakhAmihatAbid = await firestoreDB.getAllData();
    downIsLoading.value = false;
    update();
  }
}
