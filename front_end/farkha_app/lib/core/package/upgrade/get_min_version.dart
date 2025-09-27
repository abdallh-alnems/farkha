import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetMinVersionController extends GetxController {
  String minAppVersion = '';

  Future<void> fetchMinAppVersion() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('app_settings')
            .doc('min_version')
            .get();

    minAppVersion = snapshot.get('version_info');
    print(minAppVersion);
  }
}
