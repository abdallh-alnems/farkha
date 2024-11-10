import 'package:farkha_app/core/class/handling_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../logic/controller/suggestion_controller.dart';
import '../../widget/ad/banner/ad_third_banner.dart';
import '../../widget/ad/native/ad_third_native.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class Suggestion extends StatelessWidget {
  const Suggestion({super.key});

  @override
  Widget build(BuildContext context) {
  Get.put(SuggestionController());
    final TextEditingController textController = TextEditingController();
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "اقتراح",
            arrowDirection: false,
          ),
          GetBuilder<SuggestionController>(
            builder: (suggestionController) {
              return HandlingDataView(
                statusRequest: suggestionController.statusRequest ,
                widget: Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 19).r,
                      child: Column(
                        children: [
                          AdThirdNative(),
                          SizedBox(height: 25.h),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12)
                                .r,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: TextField(
                              controller: textController,
                              maxLength: 300,
                              maxLines: 11,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: 'اكتب اقتراحك هنا',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 35.h),
                          ElevatedButton(
                            onPressed: () {
                              suggestionController.addSuggestion(textController.text);
                            },
                            child: Text("ارسال الاقتراح"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
        ],
      ),
      bottomNavigationBar: const AdThirdBanner(),
    );
  }
}
