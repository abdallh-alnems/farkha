import '../../model/vaccination_model.dart';

class VaccinationData {
  static List<VaccinationModel> vaccinationSchedule = [
    const VaccinationModel(
      age: 1,
      vaccineName: "تحصين JB بريمر",
      notes: "الاستقبال - تحصين داخل المزرعة عند الوصول",
    ),
    const VaccinationModel(
      age: 7,
      vaccineName: "لقاح B1",
      notes: "التحصين بلقاح B1 تحصين يفضل جرعة شرب + جرعة رش",
    ),
    const VaccinationModel(
      age: 11,
      vaccineName: "حقن انفلونزا الطيور H5N1",
      notes: "0.5 سم تحت الجلد",
    ),
    const VaccinationModel(
      age: 13,
      vaccineName: "تحصين جمبورو عترة خفيفة",
      notes: "في ماء الشرب (ممكن جرعة أخرى تقطير بالعين)",
    ),
    const VaccinationModel(
      age: 19,
      vaccineName: "تحصين ضد نيوكاسل",
      notes: "جرعة مزدوجة شراب أو جرعة شراب + جرعة رش",
    ),
    const VaccinationModel(
      age: 24,
      vaccineName: "تحصين جمبورو عترة متوسطة",
      notes: "في ماء الشرب",
    ),
    const VaccinationModel(
      age: 30,
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
