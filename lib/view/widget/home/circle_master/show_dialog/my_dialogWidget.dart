import 'package:flutter/material.dart';

class MyDialogWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final String text3;
  final Function() onPressed1;
  final Function() onPressed2;
  final Function() onPressed3;

  const MyDialogWidget(
      {Key? key, required this.text1, required this.text2, required this.text3, required this.onPressed1, required this.onPressed2, required this.onPressed3})
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
          ],
        ),
      ),
    );
  }
}
