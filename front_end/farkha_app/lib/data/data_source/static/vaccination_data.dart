import '../../model/vaccination_model.dart';

class VaccinationData {
  static List<VaccinationModel> vaccinationSchedule = [
    const VaccinationModel(
      age: 7,

      vaccineName: "لقاح B1",

      notes: "التحصين بلقاح B1  يفضل جرعة شرب + جرعة رش",
    ),

    const VaccinationModel(
      age: 13,

      vaccineName: "تحصين جمبورو عترة خفيفة",

      notes: "في ماء الشرب (ممكن جرعة أخرى تقطير بالعين)",
    ),

    const VaccinationModel(
      age: 18,

      vaccineName: "تحصين ضد نيوكاسل",

      notes: "جرعة مزدوجة شراب أو جرعة شراب + جرعة رش",
    ),

    const VaccinationModel(
      age: 22,

      vaccineName: "تحصين كوكسيديا وكولسترديا ",

      notes: "في ماء الشرب",
    ),

    const VaccinationModel(
      age: 28,

      vaccineName: "لقاح لاسوتا",

      notes: "في ماء الشرب (أو بلقاح أفينيو) يفضل جرعة مزدوجة",
    ),
  ];

  static List<VaccinationModel> getNextVaccinations(int currentAge) {
    return vaccinationSchedule
        .where((vaccination) => vaccination.age > currentAge)
        .take(5)
        .toList();
  }

  static VaccinationModel? getTodayVaccination(int currentAge) {
    try {
      return vaccinationSchedule.firstWhere(
        (vaccination) => vaccination.age == currentAge,
      );
    } catch (e) {
      return null;
    }
  }

  static VaccinationModel? getNextVaccination(int currentAge) {
    try {
      return vaccinationSchedule.firstWhere(
        (vaccination) => vaccination.age > currentAge,
      );
    } catch (e) {
      return null;
    }
  }
}
