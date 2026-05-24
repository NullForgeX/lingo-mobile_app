import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

abstract class PracticeRemoteDataSource {
  Future<Map<String, dynamic>> getLessonRuntime(String lessonId);
  Future<Map<String, dynamic>> startLessonAttempt(String lessonId);
  Future<Map<String, dynamic>> submitAttempt(String attemptId, List<Map<String, dynamic>> answers);
}

class PracticeRemoteDataSourceImpl implements PracticeRemoteDataSource {
  final Dio dio;

  PracticeRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getLessonRuntime(String lessonId) async {
    final response = await dio.get(ApiConstants.getLessonRuntime.replaceAll('{lessonId}', lessonId));
    return response.data['data'];
  }

  @override
  Future<Map<String, dynamic>> startLessonAttempt(String lessonId) async {
    final response = await dio.post(ApiConstants.startLessonAttempt.replaceAll('{lessonId}', lessonId));
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
}
