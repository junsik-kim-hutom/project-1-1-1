import 'package:dio/dio.dart';
import '../models/eq_question_model.dart';
import '../models/eq_result_model.dart';

class EQTestRepository {
  final Dio _dio;

  EQTestRepository(this._dio);

  Future<List<EQQuestionModel>> getQuestions({String? category}) async {
    try {
      final response = await _dio.get(
        '/eq-test/questions',
        queryParameters: category != null ? {'category': category} : null,
      );

      if (response.data['success'] == true) {
        final questions = (response.data['data'] as List)
            .map((q) => EQQuestionModel.fromJson(q))
            .toList();
        return questions;
      }

      throw Exception('Failed to load questions');
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  Future<void> submitAnswer({
    required String questionId,
    required int answer,
  }) async {
    try {
      final response = await _dio.post(
        '/eq-test/answers',
        data: {
          'questionId': questionId,
          'answer': answer,
        },
      );

      if (response.data['success'] != true) {
        throw Exception('Failed to submit answer');
      }
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }

  Future<EQResultModel> calculateResults() async {
    try {
      final response = await _dio.post('/eq-test/results/calculate');

      if (response.data['success'] == true) {
        return EQResultModel.fromJson(response.data['data']);
      }

      throw Exception('Failed to calculate results');
    } catch (e) {
      throw Exception('Failed to calculate results: $e');
    }
  }

  Future<EQResultModel> getResults() async {
    try {
      final response = await _dio.get('/eq-test/results');

      if (response.data['success'] == true) {
        return EQResultModel.fromJson(response.data['data']);
      }

      throw Exception('Failed to load results');
    } catch (e) {
      throw Exception('Failed to load results: $e');
    }
  }
}
