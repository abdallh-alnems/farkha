// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class TextForm extends StatelessWidget {
  TextEditingController? price;

  String hint;

  TextForm({super.key, required this.price, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 9.0),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: price,
                decoration: InputDecoration(
                  labelText: hint,
                  border: OutlineInputBorder(),
                ),
               
              ),
            ),
          ],
        ),
      ],
    );
  }
}
