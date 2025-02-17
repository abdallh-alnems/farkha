class DiseaseModel {
  final String name;
  final Map<String, List<String>> criteria;
  final List<String> treatment;
  final List<String> prevention;

  DiseaseModel({
    required this.name,
    required this.criteria,
    required this.treatment,
    required this.prevention,
  });
}
