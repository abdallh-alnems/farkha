import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/model/disease_model/disease_model.dart';
import '../../../widget/app/ad/banner.dart';
import '../../../widget/app/ad/native.dart';
import '../../../widget/app/app_bar/custom_app_bar.dart';
import '../../../widget/app/follow_up_tools/disease/disease_details.dart';

class DiseaseDetails extends StatelessWidget {
  const DiseaseDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final DiseaseModel disease = Get.arguments;

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(text: disease.name),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AdNativeWidget(adIndex: 2),
                    SizedBox(height: 11),
                    buildSection(
                        "الاعراض", buildCriteriaList(disease.criteria)),
                    buildSection("العلاج", buildList(disease.treatment)),
                    buildSection("الوقاية", buildList(disease.prevention)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(adIndex: 2),
    );
  }
}
