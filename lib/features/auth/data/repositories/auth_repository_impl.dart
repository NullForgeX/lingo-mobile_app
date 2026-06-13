import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      return Right(userModel);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Left(ServerFailure("The user doesn't exist from backend"));
      }
      final errorData = e.response?.data;
      if (errorData is Map) {
        final errorObj = errorData['error'];
        if (errorObj is Map) {
          final message = errorObj['message'];
          if (message != null && message.toString().toLowerCase().contains("doesn't exist")) {
            return const Left(ServerFailure("The user doesn't exist from backend"));
          }
        }
      }
      if (e.response?.statusCode == 401) {
        return const Left(ServerFailure('Invalid email or password.'));
      }
      return Left(ServerFailure(e.message ?? 'Server error occurred.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, User>> register(String email, String password, String displayName) async {
    try {
      final userModel = await remoteDataSource.register(email, password, displayName);
      return Right(userModel);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ServerFailure('An account with this email already exists.'));
      }
      return Left(ServerFailure(e.message ?? 'Server error occurred.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get current user.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile() async {
    try {
      final userModel = await remoteDataSource.getUserProfile();
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get user profile.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    String? displayName,
    String? avatarUrl,
    String? avatarAltText,
    String? bio,
    String? preferredLanguageId,
    int? dailyLearningGoalMinutes,
    String? timezone,
  }) async {
    try {
      final userModel = await remoteDataSource.updateUserProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
        avatarAltText: avatarAltText,
        bio: bio,
        preferredLanguageId: preferredLanguageId,
        dailyLearningGoalMinutes: dailyLearningGoalMinutes,
        timezone: timezone,
      );
      return Right(userModel);
    } on DioException catch (e) {
      return Left(
          ServerFailure(e.message ?? 'Failed to update user profile.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, User>> syncOfflineAttempts(List<Map<String, dynamic>> attempts) async {
    try {
      final userModel = await remoteDataSource.syncOfflineAttempts(attempts);
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to sync offline attempts.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }
}

