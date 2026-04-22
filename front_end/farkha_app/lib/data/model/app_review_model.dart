class AppReviewModel {
  final int? id;
  final int? userId;
  final int rating;
  final String? issue;
  final String? suggestion;
  final String? appVersion;
  final String? platform;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppReviewModel({
    this.id,
    this.userId,
    required this.rating,
    this.issue,
    this.suggestion,
    this.appVersion,
    this.platform,
    this.createdAt,
    this.updatedAt,
  });

  static int _parseIntSafe(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory AppReviewModel.fromJson(Map<String, dynamic> json) {
    final rawRating = _parseIntSafe(json['rating']).clamp(1, 5);
    return AppReviewModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      rating: rawRating,
      issue: json['issue'] as String?,
      suggestion: json['suggestion'] as String?,
      appVersion: json['app_version'] as String?,
      platform: json['platform'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJsonForUpsert() {
    return {
      'rating': rating,
      'issue': (issue != null && issue!.trim().isNotEmpty) ? issue!.trim() : null,
      'suggestion': (suggestion != null && suggestion!.trim().isNotEmpty)
          ? suggestion!.trim()
          : null,
      'app_version': appVersion,
      'platform': platform,
    };
  }
}
