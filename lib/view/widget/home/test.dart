import 'package:farkha_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Get.toNamed(Routes.HomeScreen);
        },
        child:
            // Table(
            //   border: TableBorder.all(),
            //   children: [
            //     TableRow(
            //       children: [
            //         TableCell(
            //           child: Text(
            //             'Cell 1',
            //             style: TextStyle(fontSize: 20),
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //         TableCell(
            //           child: Text(
            //             'Cell 1',
            //             style: TextStyle(fontSize: 20),
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //         TableCell(
            //           child: Text('Cell 2'),
            //         ),
            //         TableCell(
            //           child: Text('Cell 3'),
            //         ),
            //       ],
            //     ),
            //     TableRow(
            //       children: [
            //         TableCell(
            //           child: Text('Cell 4'),
            //         ),
            //         TableCell(
            //           child: Text('Cell 5'),
            //         ),
            //         TableCell(
            //           child: Text('Cell 6'),
            //         ),
            //         TableCell(
            //           child: Text(
            //             'Cell 1',
            //             style: TextStyle(fontSize: 20),
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),

            Text('Home'));
  }
}
