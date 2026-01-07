import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/eq_result_model.dart';

class EQTestResultPage extends StatelessWidget {
  final EQResultModel result;

  const EQTestResultPage({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eqTestResultTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroCard(context, localeCode),
            const SizedBox(height: 16),
            _buildCategoryScores(context),
            const SizedBox(height: 16),
            _buildInsightSection(
              context,
              title: l10n.eqTestStrengthsTitle,
              icon: Icons.star_rounded,
              color: Colors.amber,
              items: result.getStrengths(localeCode),
            ),
            const SizedBox(height: 12),
            _buildInsightSection(
              context,
              title: l10n.eqTestImprovementsTitle,
              icon: Icons.trending_up_rounded,
              color: AppColors.accent,
              items: result.getImprovements(localeCode),
            ),
            const SizedBox(height: 12),
            _buildInsightSection(
              context,
              title: l10n.eqTestMatchingTipsTitle,
              icon: Icons.auto_awesome_rounded,
              color: AppColors.secondary,
              items: result.getMatchingTips(localeCode),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/main'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                l10n.confirm,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, String localeCode) {
    final l10n = AppLocalizations.of(context)!;
    final personalityIcon = _personalityIcon(result.personalityType);
    final score = result.totalScore.clamp(0, 5);
    final progress = score / 5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score
          SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Center(
                  child: Text(
                    '$score',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(personalityIcon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.eqTestPersonalityType,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  result.getPersonalityTypeLabel(localeCode),
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.eqTestOverallScore}: $score / 5',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryScores(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      {
        'label': l10n.eqTestScoreEmpathy,
        'score': result.empathyScore,
        'color': AppColors.primary,
        'icon': Icons.sentiment_satisfied_rounded,
      },
      {
        'label': l10n.eqTestScoreSelfAwareness,
        'score': result.selfAwarenessScore,
        'color': AppColors.accent,
        'icon': Icons.self_improvement,
      },
      {
        'label': l10n.eqTestScoreSocialSkills,
        'score': result.socialSkillsScore,
        'color': AppColors.secondary,
        'icon': Icons.people,
      },
      {
        'label': l10n.eqTestScoreMotivation,
        'score': result.motivationScore,
        'color': AppColors.warning,
        'icon': Icons.emoji_events,
      },
      {
        'label': l10n.eqTestScoreEmotionRegulation,
        'score': result.emotionRegulationScore,
        'color': AppColors.info,
        'icon': Icons.spa,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.eqTestDetailedScores,
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...categories.map((category) {
            final score = (category['score'] as int).clamp(0, 5);
            final color = category['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          size: 18,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          category['label'] as String,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '$score / 5',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: score / 5,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInsightSection(
    BuildContext context,
    {required String title,
    required IconData icon,
    required Color color,
    required List<dynamic> items}
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.55),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _personalityIcon(String type) {
    switch (type) {
      case 'empathetic':
        return Icons.favorite_rounded;
      case 'introspective':
        return Icons.self_improvement_rounded;
      case 'social':
        return Icons.people_alt_rounded;
      case 'achiever':
        return Icons.emoji_events_rounded;
      case 'rational':
        return Icons.psychology_rounded;
      case 'balanced':
      default:
        return Icons.balance_rounded;
    }
  }
}
