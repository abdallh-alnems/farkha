import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataController extends GetxController {
  
RxBool isLoading = true.obs;

  //frakh
  List<DataModel> frakhAbid = <DataModel>[];
  List<DataModel> frakhBaladi = <DataModel>[];
  List<DataModel> frakhSasso = <DataModel>[];
  List<DataModel> frakhAmihatAbid = <DataModel>[];
  //bat
  List<DataModel> batMolar = <DataModel>[];
  List<DataModel> batFiransawi = <DataModel>[];
  List<DataModel> batMaskufi = <DataModel>[];
  //katakit
  List<DataModel> katakitAbid = <DataModel>[];
  List<DataModel> katakitBaladi = <DataModel>[];
  List<DataModel> katakitSasso = <DataModel>[];
  //byd
  List<DataModel> bydAbid = <DataModel>[];
  List<DataModel> bydAihmar = <DataModel>[];
  List<DataModel> bydBaladi = <DataModel>[];

  

// onInit
  @override
  void onInit() {

     isLoading.value = true;
   
    dataFrakhAbid();
    dataFrakhBaladi();
    dataFrakhSasso();
    dataFrakhAmihatAbid();
      dataBatMolar();
      dataBatFiransawi();
      dataBatMaskufi();
      dataKatakitAbid();
      dataKatakitBaladi();
      dataKatakitSasso();
      dataBydAbid();
      dataBydAihmar();
      dataBydBaladi();

       

  

   

    super.onInit();
  }

//frakh

  void dataFrakhAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'abid');
    frakhAbid = await firestoreDB.getAllData();
        isLoading.value = false;

    update();
  }

  void dataFrakhBaladi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'baladi');
    frakhBaladi = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }

  void dataFrakhSasso() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'sasso');
    frakhSasso = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }

  void dataFrakhAmihatAbid() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'frakh', doc: 'amihat abid');
    frakhAmihatAbid = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }

  //bat

  void dataBatMolar() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'bat', doc: 'Molar');
    batMolar = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }

  void dataBatFiransawi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'bat', doc: 'firansawi');
    batFiransawi = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
  }

  void dataBatMaskufi() async {
    final DataFirestore firestoreDB =
        DataFirestore(collection: 'bat', doc: 'maskufi');
    batMaskufi = await firestoreDB.getAllData();
    isLoading.value = false;
    update();
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

  //byd

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
