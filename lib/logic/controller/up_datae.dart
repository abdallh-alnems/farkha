import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpDate extends StatefulWidget {
  const UpDate({super.key});

  @override
  State<UpDate> createState() => _UpDateState();
}

class _UpDateState extends State<UpDate> {
   upDate() async {
    CollectionReference user = FirebaseFirestore.instance.collection('byd');

     user.doc('abid').update({'first yesterday': '61'});  
  }

  @override
void didChangeDependencies() {
  upDate();    
  super.didChangeDependencies();
}

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
