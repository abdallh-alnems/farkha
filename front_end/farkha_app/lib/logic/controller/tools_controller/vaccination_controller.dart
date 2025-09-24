import 'package:get/get.dart';

import '../../../core/constant/tool_ids.dart';
import '../../../data/data_source/static/vaccination_data.dart';
import '../../../data/model/vaccination_model.dart';
import '../tool_usage_controller.dart';

class VaccinationController extends GetxController {
  static const int toolId =
      ToolIds.vaccinationSchedule; // Vaccination Schedule tool ID = 10

  RxInt currentAge = 0.obs; // Start with 0 to show no results initially
  Rx<VaccinationModel?> currentVaccination = Rx<VaccinationModel?>(null);
  Rx<VaccinationModel?> nextVaccination = Rx<VaccinationModel?>(null);

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void setCurrentAge(int age) {
    currentAge.value = age;
    updateVaccinations();
  }

  void updateVaccinations() {
    currentVaccination.value = VaccinationData.getTodayVaccination(
      currentAge.value,
    );
    nextVaccination.value = VaccinationData.getNextVaccination(
      currentAge.value,
    );
  }

  List<VaccinationModel> getAllVaccinations() {
    return VaccinationData.vaccinationSchedule;
  }
}
