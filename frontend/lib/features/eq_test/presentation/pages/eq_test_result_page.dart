import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/eq_result_model.dart';

class EQTestResultPage extends StatelessWidget {
  final EQResultModel result;

  const EQTestResultPage({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EQ 테스트 결과'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 성격 유형 카드
            _buildPersonalityTypeCard(context),
            const SizedBox(height: 24),
            // 총점 카드
            _buildTotalScoreCard(context),
            const SizedBox(height: 24),
            // 카테고리별 점수
            _buildCategoryScores(context),
            const SizedBox(height: 24),
            // 강점
            _buildInsightSection(
              context,
              '당신의 강점',
              Icons.star,
              Colors.amber,
              result.getStrengths('ko'),
            ),
            const SizedBox(height: 16),
            // 개선점
            _buildInsightSection(
              context,
              '개선할 점',
              Icons.trending_up,
              Colors.blue,
              result.getImprovements('ko'),
            ),
            const SizedBox(height: 16),
            // 매칭 팁
            _buildInsightSection(
              context,
              '매칭 팁',
              Icons.auto_awesome_rounded,
              AppColors.secondary,
              result.getMatchingTips('ko'),
            ),
            const SizedBox(height: 32),
            // 완료 버튼
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
              child: const Text(
                '확인',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityTypeCard(BuildContext context) {
    final typeEmojis = {
      'empathetic': '✨',
      'introspective': '🤔',
      'social': '🎉',
      'achiever': '🏆',
      'rational': '🧠',
      'balanced': '⚖️',
    };

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              typeEmojis[result.personalityType] ?? '✨',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              '당신의 성격 유형은',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.getPersonalityTypeLabel('ko'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalScoreCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '종합 점수',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${result.totalScore}',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    '/ 5',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryScores(BuildContext context) {
    final categories = [
      {
        'label': '공감 능력',
        'score': result.empathyScore,
        'color': AppColors.primary,
        'icon': Icons.sentiment_satisfied_rounded,
      },
      {
        'label': '자기 인식',
        'score': result.selfAwarenessScore,
        'color': AppColors.accent,
        'icon': Icons.self_improvement,
      },
      {
        'label': '사회적 기술',
        'score': result.socialSkillsScore,
        'color': AppColors.secondary,
        'icon': Icons.people,
      },
      {
        'label': '동기부여',
        'score': result.motivationScore,
        'color': AppColors.warning,
        'icon': Icons.emoji_events,
      },
      {
        'label': '감정 조절',
        'score': result.emotionRegulationScore,
        'color': AppColors.info,
        'icon': Icons.spa,
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '세부 점수',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 20,
                          color: category['color'] as Color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category['label'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${category['score']} / 5',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: category['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (category['score'] as int) / 5,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        category['color'] as Color,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<dynamic> items,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
