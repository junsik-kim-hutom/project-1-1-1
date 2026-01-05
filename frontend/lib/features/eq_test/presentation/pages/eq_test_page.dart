import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/eq_test_provider.dart';
import 'eq_test_result_page.dart';

class EQTestPage extends ConsumerWidget {
  const EQTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(eqQuestionsProvider);
    final testState = ref.watch(eqTestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EQ 감성 지능 테스트'),
        backgroundColor: AppColors.primary,
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(eqQuestionsProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(
              child: Text('질문이 없습니다.'),
            );
          }

          if (testState.currentQuestionIndex >= questions.length) {
            // 모든 질문에 답변 완료
            return _buildCompletionView(context, ref);
          }

          final currentQuestion = questions[testState.currentQuestionIndex];
          final progress =
              (testState.currentQuestionIndex + 1) / questions.length;

          return Column(
            children: [
              // 진행 상황 표시
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${testState.currentQuestionIndex + 1} / ${questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 카테고리 표시
                      _buildCategoryChip(currentQuestion.category),
                      const SizedBox(height: 24),
                      // 질문 텍스트
                      Text(
                        currentQuestion.getQuestionText('ko'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // 답변 옵션 (5점 척도)
                      _buildAnswerOptions(
                        context,
                        ref,
                        currentQuestion.id,
                        testState.answers[currentQuestion.id],
                      ),
                      const SizedBox(height: 40),
                      // 네비게이션 버튼
                      Row(
                        children: [
                          if (testState.currentQuestionIndex > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(eqTestProvider.notifier)
                                      .previousQuestion();
                                },
                                child: const Text('이전'),
                              ),
                            ),
                          if (testState.currentQuestionIndex > 0)
                            const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: testState
                                          .answers[currentQuestion.id] !=
                                      null
                                  ? () async {
                                      try {
                                        await ref
                                            .read(eqTestProvider.notifier)
                                            .submitAnswer(
                                              currentQuestion.id,
                                              testState
                                                  .answers[currentQuestion.id]!,
                                            );
                                        ref
                                            .read(eqTestProvider.notifier)
                                            .nextQuestion();
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('오류: $e')),
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                testState.currentQuestionIndex ==
                                        questions.length - 1
                                    ? '완료'
                                    : '다음',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final categoryLabels = {
      'empathy': '공감 능력',
      'self_awareness': '자기 인식',
      'social_skills': '사회적 기술',
      'motivation': '동기부여',
      'emotion_regulation': '감정 조절',
    };

    final categoryColors = {
      'empathy': AppColors.primary,
      'self_awareness': AppColors.accent,
      'social_skills': AppColors.secondary,
      'motivation': AppColors.warning,
      'emotion_regulation': AppColors.info,
    };

    return Center(
      child: Chip(
        label: Text(
          categoryLabels[category] ?? category,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: categoryColors[category] ?? AppColors.primary,
      ),
    );
  }

  Widget _buildAnswerOptions(
    BuildContext context,
    WidgetRef ref,
    String questionId,
    int? selectedAnswer,
  ) {
    final labels = [
      '전혀 아니다',
      '아니다',
      '보통이다',
      '그렇다',
      '매우 그렇다',
    ];

    return Column(
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = selectedAnswer == value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () {
              ref.read(eqTestProvider.notifier).setAnswer(questionId, value);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
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
            const Text(
              '모든 질문에 답변하셨습니다!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '결과를 계산하고 있습니다...',
              style: TextStyle(fontSize: 16),
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

                    // 결과 페이지로 이동
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => EQTestResultPage(result: result),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('결과 계산 오류: $e')),
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
                child: const Text(
                  '결과 보기',
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
