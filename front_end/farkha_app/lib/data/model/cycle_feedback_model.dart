class CycleFeedbackModel {
  final int? id;
  final int rating;
  final String? issue;
  final String? suggestion;
  final String? appVersion;
  final String? platform;
  final DateTime? createdAt;

  CycleFeedbackModel({
    this.id,
    required this.rating,
    this.issue,
    this.suggestion,
    this.appVersion,
    this.platform,
    this.createdAt,
  });

  factory CycleFeedbackModel.fromJson(Map<String, dynamic> json) {
    return CycleFeedbackModel(
      id: json['id'] as int?,
      rating: json['rating'] as int,
      issue: json['issue'] as String?,
      suggestion: json['suggestion'] as String?,
      appVersion: json['app_version'] as String?,
      platform: json['platform'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
