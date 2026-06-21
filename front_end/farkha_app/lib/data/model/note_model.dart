/// نموذج ملاحظة محلية مستقلة (أداة الملاحظات في قسم الأدوات).
///
/// منفصل تماماً عن ملاحظات الدورة [CycleNotesController] — لا يرتبط بدورة
/// ولا بمستخدم على السيرفر، ويُخزَّن محلياً على الجهاز فقط عبر GetStorage.
class NoteModel {
  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.edited = false,
  });

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// علم صريح يشير إلى أن الملاحظة عُدّلت بعد إنشائها (لا يعتمد على مقارنة الوقت).
  final bool edited;

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      edited: (json['edited'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'edited': edited,
      };

  /// [markEdited] علم صريح يُضبط true عند التعديل الفعلي. اتركه false للنسخ
  /// الذي لا يغيّر المحتوى (مثل تحديث الوقت فقط).
  NoteModel copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    bool markEdited = true,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      edited: markEdited ? true : edited,
    );
  }

  /// هل عُدّلت الملاحظة بعد إنشائها.
  bool get isEdited => edited;
}
