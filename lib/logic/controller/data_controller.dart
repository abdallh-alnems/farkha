import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataController extends GetxController {
  RxBool  isLoading = true.obs;
  //frakh
  RxList<DataModel> frakhAbid = <DataModel>[].obs;
  RxList<DataModel> frakhBaladi = <DataModel>[].obs;
  RxList<DataModel> frakhSasso = <DataModel>[].obs;
  RxList<DataModel> frakhAmihatAbid = <DataModel>[].obs;
  //bat
  RxList<DataModel> batMolar = <DataModel>[].obs;
  RxList<DataModel> batFiransawi = <DataModel>[].obs;
  RxList<DataModel> batMaskufi = <DataModel>[].obs;
  //katakit
  RxList<DataModel> katakitAbid = <DataModel>[].obs;
  RxList<DataModel> katakitBaladi = <DataModel>[].obs;
  RxList<DataModel> katakitSasso = <DataModel>[].obs;
  //byd
  RxList<DataModel> bydAbid = <DataModel>[].obs;
  RxList<DataModel> bydAihmar = <DataModel>[].obs;
  RxList<DataModel> bydBaladi = <DataModel>[].obs;

  List<RxList<DataModel>> totalItems   = [];

// onInit
  @override
  void onInit() {
    //frakh
    frakhAbid
        .bindStream(FirestoreDB(collection: 'frakh', doc: 'abid').getAllData());
    frakhBaladi.bindStream(
        FirestoreDB(collection: 'frakh', doc: 'baladi').getAllData());
    frakhSasso.bindStream(
        FirestoreDB(collection: 'frakh', doc: 'sasso').getAllData());

    frakhAmihatAbid.bindStream(
        FirestoreDB(collection: 'frakh', doc: 'amihat abid').getAllData());

    //bat
    batMolar
        .bindStream(FirestoreDB(collection: 'bat', doc: 'Molar').getAllData());
    batFiransawi.bindStream(
        FirestoreDB(collection: 'bat', doc: 'firansawi').getAllData());
    batMaskufi.bindStream(
        FirestoreDB(collection: 'bat', doc: 'maskufi').getAllData());

    //katakit
    katakitAbid.bindStream(
        FirestoreDB(collection: 'katakit', doc: 'abid').getAllData());
    katakitBaladi.bindStream(
        FirestoreDB(collection: 'katakit', doc: 'baladi').getAllData());
    katakitSasso.bindStream(
        FirestoreDB(collection: 'katakit', doc: 'sasso').getAllData());

    //byd
    bydAbid
        .bindStream(FirestoreDB(collection: 'byd', doc: 'abid').getAllData());
    bydAihmar
        .bindStream(FirestoreDB(collection: 'byd', doc: 'aihmar').getAllData());
    bydBaladi
        .bindStream(FirestoreDB(collection: 'byd', doc: 'baladi').getAllData());


        totalItems.addAll([
  frakhSasso,
  frakhBaladi,
  frakhAmihatAbid,
  katakitAbid,
  katakitSasso,
  katakitBaladi,
  bydAbid,
  bydAihmar,
  bydBaladi,
  batMaskufi,
  batMolar,
  batFiransawi,
]);

    isLoading = false.obs;

    super.onInit();
  }
}
