import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../data/data_source/static/disease/symptoms_data.dart';
import '../../../../../logic/controller/tools_controller/disease_controller.dart';

class SymptomSelection extends StatelessWidget {
  final DiagnosisDiseasesController controller;

  const SymptomSelection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "اختر الأعراض",
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        Expanded(
          child: ListView(
            children: symptoms.map((symptom) {
              return Obx(() => CheckboxListTile(
                    title: Align(
                      alignment: Alignment.centerRight,
                      child: Text(symptom),
                    ),
                    value: controller.selectedSymptoms.contains(symptom),
                    onChanged: (value) {
                      if (value == true) {
                        controller.selectedSymptoms.add(symptom);
                      } else {
                        controller.selectedSymptoms.remove(symptom);
                      }
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ));
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 45),
          child: ElevatedButton(
            onPressed: controller.canContinue ? controller.nextStep : null,
            child: const Text("التالي"),
          ),
        ),
      ],
    );
  }
}
