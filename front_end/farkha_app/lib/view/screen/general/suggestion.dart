import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/class/handling_data.dart';
import '../../../logic/controller/suggestion_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class Suggestion extends StatelessWidget {
  const Suggestion({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final RxString errorMessage = ''.obs;

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "اقتراح",
            arrowDirection: false,
          ),
          GetBuilder<SuggestionController>(
              init: SuggestionController(),
              builder: (suggestionController) {
                return HandlingDataView(
                  statusRequest: suggestionController.statusRequest,
                  widget: Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 19).r,
                        child: Column(
                          children: [
                            AdNativeWidget(adIndex: 2),
                            SizedBox(height: 25.h),
                            Obx(() => TextField(
                                  controller: textController,
                                  maxLength: 300,
                                  maxLines: 11,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: 'اكتب اقتراحك هنا',
                                    border: OutlineInputBorder(),
                                    errorText: errorMessage.isNotEmpty
                                        ? errorMessage.value
                                        : null,
                                  ),
                                )),
                            SizedBox(height: 35.h),
                            ElevatedButton(
                              onPressed: () {
                                if (textController.text.trim().isEmpty) {
                                  errorMessage.value =
                                      "لا يمكن إرسال اقتراح فارغ";
                                } else {
                                  errorMessage.value = '';
                                  suggestionController
                                      .addSuggestion(textController.text);
                                }
                              },
                              child: Text("ارسال الاقتراح"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(adIndex: 2),
    );
  }
}
