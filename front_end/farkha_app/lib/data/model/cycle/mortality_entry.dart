class MortalityEntry {
  final String id;
  final int count;
  final DateTime date;

  MortalityEntry({required this.id, required this.count, required this.date});

  Map<String, dynamic> toJson() {
    return {'id': id, 'count': count, 'date': date.toIso8601String()};
  }

  factory MortalityEntry.fromJson(Map<String, dynamic> json) {
    return MortalityEntry(
      id: (json['id'] ?? '').toString(),
      count: ((json['count'] ?? 0) as num).toInt(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
