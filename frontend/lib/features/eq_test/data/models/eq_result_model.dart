class EQResultModel {
  final String id;
  final String userId;
  final int totalScore;
  final int empathyScore;
  final int selfAwarenessScore;
  final int socialSkillsScore;
  final int motivationScore;
  final int emotionRegulationScore;
  final String personalityType;
  final Map<String, dynamic> insights;
  final DateTime completedAt;

  EQResultModel({
    required this.id,
    required this.userId,
    required this.totalScore,
    required this.empathyScore,
    required this.selfAwarenessScore,
    required this.socialSkillsScore,
    required this.motivationScore,
    required this.emotionRegulationScore,
    required this.personalityType,
    required this.insights,
    required this.completedAt,
  });

  factory EQResultModel.fromJson(Map<String, dynamic> json) {
    return EQResultModel(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'],
      totalScore: json['totalScore'] ?? json['total_score'],
      empathyScore: json['empathyScore'] ?? json['empathy_score'],
      selfAwarenessScore: json['selfAwarenessScore'] ?? json['self_awareness_score'],
      socialSkillsScore: json['socialSkillsScore'] ?? json['social_skills_score'],
      motivationScore: json['motivationScore'] ?? json['motivation_score'],
      emotionRegulationScore: json['emotionRegulationScore'] ?? json['emotion_regulation_score'],
      personalityType: json['personalityType'] ?? json['personality_type'],
      insights: json['insights'],
      completedAt: DateTime.parse(json['completedAt'] ?? json['completed_at']),
    );
  }

  List<dynamic> getStrengths(String locale) {
    final strengths = insights['strengths'] as List<dynamic>?;
    if (strengths == null) return [];
    return strengths.map((s) => s[locale] ?? s['en'] ?? '').toList();
  }

  List<dynamic> getImprovements(String locale) {
    final improvements = insights['improvements'] as List<dynamic>?;
    if (improvements == null) return [];
    return improvements.map((i) => i[locale] ?? i['en'] ?? '').toList();
  }

  List<dynamic> getMatchingTips(String locale) {
    final tips = insights['matchingTips'] as List<dynamic>?;
    if (tips == null) return [];
    return tips.map((t) => t[locale] ?? t['en'] ?? '').toList();
  }

  String getPersonalityTypeLabel(String locale) {
    final labels = {
      'empathetic': {
        'ko': '공감형',
        'ja': '共感型',
        'en': 'Empathetic',
      },
      'introspective': {
        'ko': '성찰형',
        'ja': '省察型',
        'en': 'Introspective',
      },
      'social': {
        'ko': '사교형',
        'ja': '社交型',
        'en': 'Social',
      },
      'achiever': {
        'ko': '성취형',
        'ja': '達成型',
        'en': 'Achiever',
      },
      'rational': {
        'ko': '이성형',
        'ja': '理性型',
        'en': 'Rational',
      },
      'balanced': {
        'ko': '균형형',
        'ja': 'バランス型',
        'en': 'Balanced',
      },
    };

    return labels[personalityType]?[locale] ?? personalityType;
  }
}
