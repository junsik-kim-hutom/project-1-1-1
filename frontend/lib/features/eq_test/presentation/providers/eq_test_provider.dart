import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/models/eq_question_model.dart';
import '../../data/models/eq_result_model.dart';
import '../../data/repositories/eq_test_repository.dart';

final eqTestRepositoryProvider = Provider<EQTestRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return EQTestRepository(dio);
});

final eqQuestionsProvider = FutureProvider<List<EQQuestionModel>>((ref) async {
  final repository = ref.watch(eqTestRepositoryProvider);
  return await repository.getQuestions();
});

final eqResultsProvider = FutureProvider<EQResultModel?>((ref) async {
  final repository = ref.watch(eqTestRepositoryProvider);
  try {
    return await repository.getResults();
  } catch (e) {
    return null; // 아직 테스트를 완료하지 않은 경우
  }
});

class EQTestState {
  final Map<String, int> answers;
  final int currentQuestionIndex;
  final bool isSubmitting;

  EQTestState({
    this.answers = const {},
    this.currentQuestionIndex = 0,
    this.isSubmitting = false,
  });

  EQTestState copyWith({
    Map<String, int>? answers,
    int? currentQuestionIndex,
    bool? isSubmitting,
  }) {
    return EQTestState(
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class EQTestNotifier extends StateNotifier<EQTestState> {
  final EQTestRepository _repository;

  EQTestNotifier(this._repository) : super(EQTestState());

  void setAnswer(String questionId, int answer) {
    final newAnswers = Map<String, int>.from(state.answers);
    newAnswers[questionId] = answer;
    state = state.copyWith(answers: newAnswers);
  }

  void nextQuestion() {
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  Future<void> submitAnswer(String questionId, int answer) async {
    try {
      await _repository.submitAnswer(
        questionId: questionId,
        answer: answer,
      );
      setAnswer(questionId, answer);
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }

  Future<EQResultModel> calculateResults() async {
    try {
      state = state.copyWith(isSubmitting: true);
      final result = await _repository.calculateResults();
      return result;
    } catch (e) {
      throw Exception('Failed to calculate results: $e');
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  void reset() {
    state = EQTestState();
  }
}

final eqTestProvider = StateNotifierProvider<EQTestNotifier, EQTestState>((ref) {
  final repository = ref.watch(eqTestRepositoryProvider);
  return EQTestNotifier(repository);
});
