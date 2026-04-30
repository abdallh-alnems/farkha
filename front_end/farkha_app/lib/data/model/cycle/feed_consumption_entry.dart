class FeedConsumptionEntry {
  final String id;
  final double amount;
  final DateTime date;

  FeedConsumptionEntry({
    required this.id,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'amount': amount, 'date': date.toIso8601String()};
  }

  factory FeedConsumptionEntry.fromJson(Map<String, dynamic> json) {
    return FeedConsumptionEntry(
      id: (json['id'] ?? '').toString(),
      amount: ((json['amount'] ?? 0.0) as num).toDouble(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
