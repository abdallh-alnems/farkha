

import 'package:cloud_firestore/cloud_firestore.dart';

class DataModelA3laf {
  final String one;
 

  DataModelA3laf({
    required this.one,
  
  });

  static DataModelA3laf fromSnapshot(DocumentSnapshot snap) {
    return DataModelA3laf(
      one: snap.get('1'),
      
    );
  }
}
