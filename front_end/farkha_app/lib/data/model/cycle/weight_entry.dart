class WeightEntry {
  final String id;
  final double weight;
  final DateTime date;

  WeightEntry({required this.id, required this.weight, required this.date});

  Map<String, dynamic> toJson() {
    return {'id': id, 'weight': weight, 'date': date.toIso8601String()};
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: (json['id'] ?? '').toString(),
      weight: ((json['weight'] ?? 0.0) as num).toDouble(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
