import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/eq_test_provider.dart';

class EQTestPage extends ConsumerStatefulWidget {
  const EQTestPage({super.key});

  @override
  ConsumerState<EQTestPage> createState() => _EQTestPageState();
}

class _EQTestPageState extends ConsumerState<EQTestPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(eqTestProvider.notifier).reset());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final questionsAsync = ref.watch(eqQuestionsProvider);
    final testState = ref.watch(eqTestProvider);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eqTestTitle),
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (testState.currentQuestionIndex > 0) {
              ref.read(eqTestProvider.notifier).previousQuestion();
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('${l10n.error}: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(eqQuestionsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (questions) {
          if (questions.isEmpty) {
            return Center(
              child: Text(l10n.eqTestNoQuestions),
            );
          }

          if (testState.currentQuestionIndex >= questions.length) {
            // 모든 질문에 답변 완료
            return _buildCompletionView(context, ref);
          }

          final currentQuestion = questions[testState.currentQuestionIndex];
          final progress =
              (testState.currentQuestionIndex + 1) / questions.length;
          final categoryMeta = _categoryMeta(currentQuestion.category, l10n);

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.white, AppColors.background],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    // Progress
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryMeta.color
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      categoryMeta.icon,
                                      size: 16,
                                      color: categoryMeta.color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      categoryMeta.label,
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: categoryMeta.color,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${testState.currentQuestionIndex + 1} / ${questions.length}',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                categoryMeta.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: Container(
                          key: ValueKey(currentQuestion.id),
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                currentQuestion.getQuestionText(localeCode),
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.35,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.eqTestAutoAdvanceHint,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),
                              Expanded(
                                child: AbsorbPointer(
                                  absorbing: testState.isAnswerSubmitting,
                                  child: Stack(
                                    children: [
                                      _buildAnswerOptions(
                                        context,
                                        ref,
                                        currentQuestion.id,
                                        testState.answers[currentQuestion.id],
                                        isEnabled:
                                            !testState.isAnswerSubmitting,
                                        accentColor: categoryMeta.color,
                                      ),
                                      if (testState.isAnswerSubmitting)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.white
                                                  .withValues(alpha: 0.55),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _EQCategoryMeta _categoryMeta(String category, AppLocalizations l10n) {
    switch (category) {
      case 'empathy':
        return _EQCategoryMeta(
          label: l10n.eqTestCategoryEmpathy,
          icon: Icons.favorite_rounded,
          color: AppColors.primary,
        );
      case 'self_awareness':
        return _EQCategoryMeta(
          label: l10n.eqTestCategorySelfAwareness,
          icon: Icons.self_improvement_rounded,
          color: AppColors.accent,
        );
      case 'social_skills':
        return _EQCategoryMeta(
          label: l10n.eqTestCategorySocialSkills,
          icon: Icons.people_alt_rounded,
          color: AppColors.secondary,
        );
      case 'motivation':
        return _EQCategoryMeta(
          label: l10n.eqTestCategoryMotivation,
          icon: Icons.emoji_events_rounded,
          color: AppColors.warning,
        );
      case 'emotion_regulation':
        return _EQCategoryMeta(
          label: l10n.eqTestCategoryEmotionRegulation,
          icon: Icons.spa_rounded,
          color: AppColors.info,
        );
      default:
        return _EQCategoryMeta(
          label: l10n.eqTestCategoryEQ,
          icon: Icons.psychology_rounded,
          color: AppColors.primary,
        );
    }
  }

  Widget _buildAnswerOptions(BuildContext context, WidgetRef ref,
      int questionId, int? selectedAnswer,
      {required bool isEnabled, required Color accentColor}) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.eqTestLikert1,
      l10n.eqTestLikert2,
      l10n.eqTestLikert3,
      l10n.eqTestLikert4,
      l10n.eqTestLikert5,
    ];

    return Column(
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = selectedAnswer == value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: InkWell(
            onTap: !isEnabled
                ? null
                : () async {
                    try {
                      await ref
                          .read(eqTestProvider.notifier)
                          .submitAnswerAndAdvance(questionId, value);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${l10n.error}: $e')),
                      );
                    }
                  },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.10)
                    : AppColors.white,
                border: Border.all(
                  color: isSelected ? accentColor : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : const [],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? accentColor : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: isSelected ? accentColor : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$value',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      labels[index],
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isSelected ? accentColor : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    color: isSelected ? accentColor : AppColors.textHint,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCompletionView(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(eqTestProvider);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.success,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.eqTestAllAnsweredTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.eqTestCalculatingResult,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (testState.isSubmitting)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await ref
                        .read(eqTestProvider.notifier)
                        .calculateResults();

                    if (!context.mounted) return;

                    context.pushReplacement('/eq-test/result', extra: result);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${l10n.eqTestResultCalculationError}: $e'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  l10n.eqTestViewResult,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EQCategoryMeta {
  final String label;
  final IconData icon;
  final Color color;

  const _EQCategoryMeta({
    required this.label,
    required this.icon,
    required this.color,
  });
}
