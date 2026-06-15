import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../models/user_model.dart';
import '../models/sync_result_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String displayName);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Future<UserModel> getUserProfile();
  Future<UserModel> updateUserProfile({
    String? displayName,
    String? avatarUrl,
    String? avatarAltText,
    String? bio,
    String? preferredLanguageId,
    int? dailyLearningGoalMinutes,
    String? timezone,
  });
  Future<SyncResultModel> syncOfflineAttempts(List<Map<String, dynamic>> attempts);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<SyncResultModel> syncOfflineAttempts(List<Map<String, dynamic>> attempts) async {
    final sanitizedAttempts = attempts.map((attempt) {
      final answersList = attempt['answers'] as List<dynamic>? ?? [];
      final sanitizedAnswers = answersList.map((ans) {
        final ansMap = Map<String, dynamic>.from(ans as Map);
        final Map<String, dynamic> sanitizedAns = {
          'exerciseId': ansMap['exerciseId']?.toString(),
          'isCorrect': ansMap['isCorrect'] ?? false,
        };
        
        if (ansMap['selectedOptionIds'] != null) {
          sanitizedAns['selectedOptionIds'] = List<String>.from(ansMap['selectedOptionIds'] as List);
        }
        if (ansMap['response'] != null) {
          sanitizedAns['response'] = ansMap['response'].toString();
        }
        if (ansMap['pairs'] != null) {
          sanitizedAns['pairs'] = (ansMap['pairs'] as List).map((p) {
            final pMap = Map<String, dynamic>.from(p as Map);
            return {
              'leftOptionId': pMap['leftOptionId'],
              'rightOptionId': pMap['rightOptionId'],
            };
          }).toList();
        }
        if (ansMap['orderedOptionIds'] != null) {
          sanitizedAns['orderedOptionIds'] = List<String>.from(ansMap['orderedOptionIds'] as List);
        }
        return sanitizedAns;
      }).toList();

      return {
        'lessonId': attempt['lessonId']?.toString(),
        'score': attempt['score'] ?? 0,
        'maxScore': attempt['maxScore'] ?? 1,
        'passed': attempt['passed'] ?? false,
        'xpEarned': attempt['xpEarned'] ?? 0,
        'startedAt': DateTime.parse(attempt['startedAt'].toString()).toUtc().toIso8601String(),
        'completedAt': DateTime.parse(attempt['completedAt'].toString()).toUtc().toIso8601String(),
        'answers': sanitizedAnswers,
      };
    }).toList();

    final response = await dio.post(
      ApiConstants.syncAttempts,
      data: {
        'attempts': sanitizedAttempts,
      },
    );
    if (response.data['success'] == true) {
      return SyncResultModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Sync failed',
      );
    }
  }


  @override
  Future<UserModel> login(String email, String password) async {
    final response = await dio.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    if (response.data['success'] == true) {
      final userJson = response.data['data'];
      try {
        final profileResponse = await dio.get(ApiConstants.profile);
        if (profileResponse.data['success'] == true) {
          return UserModel.fromJson(profileResponse.data['data']);
        }
      } catch (_) {
        // Fallback to base user if profile retrieval fails
      }
      return UserModel.fromJson(userJson);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Login failed',
      );
    }
  }

  @override
  Future<UserModel> register(String email, String password, String displayName) async {
    final response = await dio.post(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'displayName': displayName,
      },
    );
    if (response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Registration failed',
      );
    }
  }

  @override
  Future<void> logout() async {
    await dio.post(ApiConstants.logout);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await dio.get(ApiConstants.me);
    if (response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Failed to get user',
      );
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    final response = await dio.get(ApiConstants.profile);
    if (response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Failed to get profile',
      );
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    String? displayName,
    String? avatarUrl,
    String? avatarAltText,
    String? bio,
    String? preferredLanguageId,
    int? dailyLearningGoalMinutes,
    String? timezone,
  }) async {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['displayName'] = displayName;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (avatarAltText != null) data['avatarAltText'] = avatarAltText;
    if (bio != null) data['bio'] = bio;
    if (preferredLanguageId != null) data['preferredLanguageId'] = preferredLanguageId;
    if (dailyLearningGoalMinutes != null) data['dailyLearningGoalMinutes'] = dailyLearningGoalMinutes;
    if (timezone != null) data['timezone'] = timezone;

    final response = await dio.patch(
      ApiConstants.profile,
      data: data,
    );
    if (response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Failed to update profile',
      );
    }
  }
}
