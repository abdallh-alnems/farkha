class QuestionDiseaseModel {
  final String name;
  final List<String> options;
  final List<String> symptoms;

  QuestionDiseaseModel({
    required this.name,
    required this.options,
    this.symptoms = const [],
  });
}
