import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farkha_app/model/data_model_a3alf_.dart';
import 'package:farkha_app/model/data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class A3lafController extends GetxController {
  DataModelA3laf? badi;
  DataModelA3laf? nami;

  DataModelA3laf? nahi;
  DataModelA3laf? byad14;
  DataModelA3laf? byad16;
  DataModelA3laf? byad17;
  DataModelA3laf? byad18;
  DataModelA3laf? byad19;

  @override
  void onInit() {
    super.onInit();
    fbadi();
    fnami();
    fnahi();
    fbyad14();
    fbyad16();
    fbyad17();
    fbyad18();
    fbyad19();
  }

  void fbadi() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('a3laf').doc('1').get();
    if (documentSnapshot.exists) {
      badi = DataModelA3laf.fromSnapshot(documentSnapshot);
      update();
    }
  }

  void fnami() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('a3laf').doc('2').get();
    if (documentSnapshot.exists) {
      nami = DataModelA3laf.fromSnapshot(documentSnapshot);
      update();
    }
  }

  void fnahi() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('a3laf').doc('3').get();
    if (documentSnapshot.exists) {
      nahi = DataModelA3laf.fromSnapshot(documentSnapshot);
      update();
    }
  }

  void fbyad14() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('a3laf').doc('14').get();
    if (documentSnapshot.exists) {
      byad14 = DataModelA3laf.fromSnapshot(documentSnapshot);
      update();
    }
  }

  void fbyad16() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('a3laf').doc('16').get();
    if (documentSnapshot.exists) {
      byad16 = DataModelA3laf.fromSnapshot(documentSnapshot);
      update();
    }
  }

  void fbyad17() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('a3laf').doc('17').get();
    if (documentSnapshot.exists) {
      byad17 = DataModelA3laf.fromSnapshot(documentSnapshot);
      update();
    }
  }

  void fbyad18() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('a3laf').doc('18').get();
    if (documentSnapshot.exists) {
      byad18 = DataModelA3laf.fromSnapshot(documentSnapshot);
      update();
    }
  }

  void fbyad19() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('a3laf').doc('19').get();
    if (documentSnapshot.exists) {
      byad19 = DataModelA3laf.fromSnapshot(documentSnapshot);
      update();
    }
  }
}
