import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../logic/controller/suggestion_controller.dart';

class Suggestion extends StatelessWidget {
  const Suggestion({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final RxString errorMessage = ''.obs;

    return Scaffold(
      body: GetBuilder<SuggestionController>(
        init: SuggestionController(),
        builder: (suggestionController) {
          return HandlingDataView(
            statusRequest: suggestionController.statusRequest,
            widget: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child:
                        suggestionController.isSuggestionSent
                            ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 100,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "✔ تم إرسال اقتراحك بنجاح",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "شكراً لك، تم استلام اقتراحك",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 35),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.offAllNamed('/');
                                  },
                                  child: const Text("الصفحة الرئيسية"),
                                ),
                              ],
                            )
                            : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(
                                  () => TextField(
                                    controller: textController,
                                    maxLength: 300,
                                    maxLines: 11,
                                    textAlign: TextAlign.right,
                                    onChanged: (value) {
                                      if (errorMessage.isNotEmpty) {
                                        errorMessage.value = '';
                                      }
                                      suggestionController.resetState();
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'اكتب اقتراحك هنا',
                                      border: const OutlineInputBorder(),
                                      errorText:
                                          errorMessage.isNotEmpty
                                              ? errorMessage.value
                                              : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 35),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (textController.text.trim().isEmpty) {
                                      errorMessage.value =
                                          "لا يمكن إرسال اقتراح فارغ";
                                      return;
                                    }
                                    errorMessage.value = '';
                                    await suggestionController.addSuggestion(
                                      textController.text,
                                    );
                                    if (suggestionController.isSuggestionSent) {
                                      textController.clear();
                                    }
                                  },
                                  child: const Text("ارسال الاقتراح"),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
