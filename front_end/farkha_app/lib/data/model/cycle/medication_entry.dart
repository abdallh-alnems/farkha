class MedicationEntry {
  final String id;
  final String text;
  final DateTime date;

  MedicationEntry({required this.id, required this.text, required this.date});

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'date': date.toIso8601String()};
  }

  factory MedicationEntry.fromJson(Map<String, dynamic> json) {
    return MedicationEntry(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
