class VaccinationModel {
  final int age;
  final String vaccineName;
  final String notes;
  final bool isCompleted;

  const VaccinationModel({
    required this.age,
    required this.vaccineName,
    required this.notes,
    this.isCompleted = false,
  });

  factory VaccinationModel.fromJson(Map<String, dynamic> json) {
    return VaccinationModel(
      age: json['age'] as int,
      vaccineName: json['vaccine_name'] as String,
      notes: json['notes'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'vaccine_name': vaccineName,
      'notes': notes,
      'is_completed': isCompleted,
    };
  }
}
