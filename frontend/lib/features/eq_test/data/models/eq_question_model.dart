class EQQuestionModel {
  final String id;
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
    return EQQuestionModel(
      id: json['id'],
      questionKey: json['questionKey'] ?? json['question_key'],
      category: json['category'],
      questionText: json['questionText'] ?? json['question_text'],
      answerType: json['answerType'] ?? json['answer_type'],
      options: json['options'],
      scoring: json['scoring'],
      displayOrder: json['displayOrder'] ?? json['display_order'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  String getQuestionText(String locale) {
    return questionText[locale] ?? questionText['en'] ?? '';
  }
}
