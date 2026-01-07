class EQQuestionModel {
  final int id;
  final String questionKey;
  final String category;
  final Map<String, dynamic> questionText;
  final String answerType;
  final Map<String, dynamic>? options;
  final Map<String, dynamic> scoring;
  final int displayOrder;
  final bool isActive;

  EQQuestionModel({
    required this.id,
    required this.questionKey,
    required this.category,
    required this.questionText,
    required this.answerType,
    this.options,
    required this.scoring,
    required this.displayOrder,
    required this.isActive,
  });

  factory EQQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawCategory = (json['category'] ?? '').toString();
    final rawAnswerType = (json['answerType'] ?? json['answer_type'] ?? '').toString();
    return EQQuestionModel(
      id: _parseId(json['id']),
      questionKey: (json['questionKey'] ?? json['question_key'] ?? '').toString(),
      category: rawCategory.toLowerCase(),
      questionText: json['questionText'] ?? json['question_text'],
      answerType: rawAnswerType.toLowerCase(),
      options: json['options'],
      scoring: json['scoring'],
      displayOrder: _parseId(json['displayOrder'] ?? json['display_order']),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  String getQuestionText(String locale) {
    return questionText[locale] ?? questionText['en'] ?? '';
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}
