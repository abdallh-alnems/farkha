import 'package:farkha_app/logic/controller/data_controller.dart';
import 'package:farkha_app/logic/controller/ll.dart';
import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardList extends StatelessWidget {
  const CardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataController = Get.put(DataController());
    final dataController2 = Get.put(DataController2());

    return Obx(() => ListView.builder(
          itemCount: dataController.data.length,
          itemBuilder: (BuildContext context, int index) {
            return ViewListCard(
              index: index,
            );
          },
        ));
  }
}

class ViewListCard extends StatelessWidget {
  final int index;
  final dataController = Get.find<DataController>();
  final dataController2 = Get.find<DataController2>();

  ViewListCard({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

       
       Card()
      ],
    );
  }
}
