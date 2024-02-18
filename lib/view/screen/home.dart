import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../logic/controller/home_controller.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeControllerImp());

    return Scaffold(body: GetBuilder<HomeControllerImp>(builder: (controller) {
      return Table(
        children: [
          TableRow(children: [
            Text("Item",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            Text("QTY",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            Text("Price",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ]),
          ...List.generate(
              controller.data.length,
              (index) => TableRow(children: [
                    Text("${controller.data[index].productName}",
                        textAlign: TextAlign.center),
                    Text("${controller.data[index].lowestPrice}",
                        textAlign: TextAlign.center),
                    Text("${controller.data[index].highestPrice}",
                        textAlign: TextAlign.center),
                  ]))
        ],
      );
    }));
  }
}
