import 'package:farkha_app/logic/controller/a3alf/a3laf_controller.dart';
import 'package:farkha_app/view/widget/app_bar/my_app_bar.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/a3laf_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class A3laf extends StatelessWidget {
  const A3laf({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upController = Get.find<A3lafController>();

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(
              text: 'اعلاف',
            ),
            body: GetBuilder<A3lafController>(
              builder: (_) {
                if (upController.badi != null &&
                    upController.nami != null &&
                    upController.nahi != null &&
                    upController.byad14 != null &&
                    upController.byad16 != null &&
                    upController.byad17 != null &&
                    upController.byad18 != null &&
                    upController.byad19 != null
                    ) {
                  return A3lafTableData(
                    upPrice1 : upController.badi!.one ,
                   upPrice2 :upController.nami!.one ,
                   upPrice3 :upController.nahi!.one ,
                   upPrice4 :upController.byad14!.one ,
                   upPrice5 :upController.byad16!.one ,
                   upPrice6 :upController.byad17!.one ,
                   upPrice7 :upController.byad18!.one ,
                   upPrice8 :upController.byad19!.one ,

                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }
              },
            )));
  }
}
