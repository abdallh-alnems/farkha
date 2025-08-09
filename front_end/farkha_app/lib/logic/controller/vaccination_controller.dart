import 'package:get/get.dart';
import '../../data/data_source/static/vaccination_data.dart';
import '../../data/model/vaccination_model.dart';

class VaccinationController extends GetxController {
  RxInt currentAge = 0.obs; // Start with 0 to show no results initially
  Rx<VaccinationModel?> currentVaccination = Rx<VaccinationModel?>(null);
  Rx<VaccinationModel?> nextVaccination = Rx<VaccinationModel?>(null);

  @override
  void onInit() {
    super.onInit();
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
