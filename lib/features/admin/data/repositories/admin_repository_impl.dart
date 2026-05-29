import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUsers({
    required int page,
    required int pageSize,
    String? search,
    String? role,
    String? status,
    String? sort,
    String? order,
  }) async {
    try {
      final result = await remoteDataSource.getUsers(
        page: page,
        pageSize: pageSize,
        search: search,
        role: role,
        status: status,
        sort: sort,
        order: order,
      );
      return Right(result);
    } on DioException catch (e) {
      final message = e.response?.data['error']?['message'] ?? e.message ?? 'Failed to fetch users';
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> getUser(String userId) async {
    try {
      final userModel = await remoteDataSource.getUser(userId);
      return Right(userModel);
    } on DioException catch (e) {
      final message = e.response?.data['error']?['message'] ?? e.message ?? 'Failed to load user details';
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> createUser({
    required String email,
    required String password,
    String? displayName,
    required String role,
    required String status,
  }) async {
    try {
      final userModel = await remoteDataSource.createUser(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        status: status,
      );
      return Right(userModel);
    } on DioException catch (e) {
      final message = e.response?.data['error']?['message'] ?? e.message ?? 'Failed to create user';
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> updateUser(
    String userId, {
    String? displayName,
    String? avatarUrl,
    String? avatarAltText,
    String? bio,
    String? preferredLanguageId,
    int? dailyLearningGoalMinutes,
    String? timezone,
    String? role,
    String? status,
    String? suspensionReason,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (displayName != null) updates['displayName'] = displayName;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      if (avatarAltText != null) updates['avatarAltText'] = avatarAltText;
      if (bio != null) updates['bio'] = bio;
      if (preferredLanguageId != null) updates['preferredLanguageId'] = preferredLanguageId;
      if (dailyLearningGoalMinutes != null) updates['dailyLearningGoalMinutes'] = dailyLearningGoalMinutes;
      if (timezone != null) updates['timezone'] = timezone;
      if (role != null) updates['role'] = role;
      if (status != null) updates['status'] = status;
      if (suspensionReason != null) updates['suspensionReason'] = suspensionReason;

      final userModel = await remoteDataSource.updateUser(userId, updates);
      return Right(userModel);
    } on DioException catch (e) {
      final message = e.response?.data['error']?['message'] ?? e.message ?? 'Failed to update user';
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> suspendUser(String userId, String? reason) async {
    try {
      final userModel = await remoteDataSource.suspendUser(userId, reason);
      return Right(userModel);
    } on DioException catch (e) {
      final message = e.response?.data['error']?['message'] ?? e.message ?? 'Failed to suspend user';
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, AdminUser>> reactivateUser(String userId) async {
    try {
      final userModel = await remoteDataSource.reactivateUser(userId);
      return Right(userModel);
    } on DioException catch (e) {
      final message = e.response?.data['error']?['message'] ?? e.message ?? 'Failed to reactivate user';
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> revokeUserSessions(String userId) async {
    try {
      await remoteDataSource.revokeUserSessions(userId);
      return const Right(null);
    } on DioException catch (e) {
      final message = e.response?.data['error']?['message'] ?? e.message ?? 'Failed to revoke sessions';
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }
}
