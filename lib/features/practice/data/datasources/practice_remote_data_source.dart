import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

abstract class PracticeRemoteDataSource {
  Future<Map<String, dynamic>> getLessonDetail(String lessonId);
  Future<Map<String, dynamic>> getLessonRuntime(String lessonId);
  Future<Map<String, dynamic>> startLessonAttempt(String lessonId);
  Future<Map<String, dynamic>> submitAttempt(String attemptId, List<Map<String, dynamic>> answers);
  Future<Map<String, dynamic>> startExerciseAttempt(String exerciseId);
  Future<Map<String, dynamic>> listAttempts({int page = 1, int pageSize = 20, String order = 'desc'});
  Future<Map<String, dynamic>> abandonAttempt(String attemptId);
}

class PracticeRemoteDataSourceImpl implements PracticeRemoteDataSource {
  final Dio dio;

  PracticeRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getLessonDetail(String lessonId) async {
    final response = await dio.get(ApiConstants.getLessonDetail.replaceAll('{lessonId}', lessonId));
    return response.data['data'];
  }

  @override
  Future<Map<String, dynamic>> getLessonRuntime(String lessonId) async {
    final response = await dio.get(ApiConstants.getLessonRuntime.replaceAll('{lessonId}', lessonId));
    return response.data['data'];
  }

  @override
  Future<Map<String, dynamic>> startLessonAttempt(String lessonId) async {
    final response = await dio.post(
      ApiConstants.startLessonAttempt.replaceAll('{lessonId}', lessonId),
      data: const {},
    );
    return response.data['data'];
  }

  @override
  Future<Map<String, dynamic>> submitAttempt(String attemptId, List<Map<String, dynamic>> answers) async {
    final response = await dio.post(
      ApiConstants.submitAttempt.replaceAll('{attemptId}', attemptId),
      data: {'answers': answers},
    );
    return response.data['data'];
  }

  @override
  Future<Map<String, dynamic>> startExerciseAttempt(String exerciseId) async {
    final response = await dio.post(
      ApiConstants.startExerciseAttempt.replaceAll('{exerciseId}', exerciseId),
      data: const {},
    );
    return response.data['data'];
  }

  @override
  Future<Map<String, dynamic>> listAttempts({int page = 1, int pageSize = 20, String order = 'desc'}) async {
    final response = await dio.get(
      ApiConstants.listAttempts,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'order': order,
      },
    );
    return response.data['data'];
  }

  @override
  Future<Map<String, dynamic>> abandonAttempt(String attemptId) async {
    final response = await dio.post(
      ApiConstants.abandonAttempt.replaceAll('{attemptId}', attemptId),
      data: const {},
    );
    return response.data['data'];
  }
}
