import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/service/firebase_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataController extends GetxController {
  final data = <DataModel>[].obs;

  @override
  void onInit() {
    data.bindStream(FirestoreDB().getAllData() );
   
    super.onInit();
  }
}
