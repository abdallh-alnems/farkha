import 'package:flutter/material.dart';

class FrakhDialogWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final Function() onPressed1;
  final Function() onPressed2;
  final Function() onPressed3;
  final Function() onPressed4;

  const FrakhDialogWidget(
      {Key? key, required this.text1, required this.text2, required this.text3, required this.onPressed1, required this.onPressed2, required this.onPressed3, required this.text4, required this.onPressed4})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'اختر النوع',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                minimumSize: Size(double.infinity, 40),
              ),
              onPressed: onPressed1,
              child: Text(
                text1,
                style: TextStyle(fontSize: 23),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  minimumSize: Size(double.infinity, 40),
                ),
                onPressed: onPressed2,
                child: Text(
                  text2,
                  style: TextStyle(fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                minimumSize: Size(double.infinity, 40),
              ),
              onPressed: onPressed3,
              child: Text(
                text3,
                style: TextStyle(fontSize: 23),
                textAlign: TextAlign.center,
              ),
            ),
             Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  minimumSize: Size(double.infinity, 40),
                ),
                onPressed: onPressed4,
                child: Text(
                  text4,
                  style: TextStyle(fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
