import 'package:dio/dio.dart';
import '../models/admin_user_model.dart';

abstract class AdminRemoteDataSource {
  Future<Map<String, dynamic>> getUsers({
    required int page,
    required int pageSize,
    String? search,
    String? role,
    String? status,
    String? sort,
    String? order,
  });

  Future<AdminUserModel> getUser(String userId);

  Future<AdminUserModel> createUser({
    required String email,
    required String password,
    String? displayName,
    required String role,
    required String status,
  });

  Future<AdminUserModel> updateUser(
    String userId,
    Map<String, dynamic> updates,
  );

  Future<AdminUserModel> suspendUser(String userId, String? reason);

  Future<AdminUserModel> reactivateUser(String userId);

  Future<void> revokeUserSessions(String userId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio dio;

  AdminRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getUsers({
    required int page,
    required int pageSize,
    String? search,
    String? role,
    String? status,
    String? sort,
    String? order,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'pageSize': pageSize,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (role != null && role.isNotEmpty) {
      queryParams['role'] = role;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }
    if (order != null && order.isNotEmpty) {
      queryParams['order'] = order;
    }

    final response = await dio.get(
      '/admin/users',
      queryParameters: queryParams,
    );

    if (response.data['success'] == true) {
      final itemsJson = response.data['data']['items'] as List<dynamic>;
      final items = itemsJson.map((item) => AdminUserModel.fromJson(item)).toList();
      
      final paginationJson = response.data['data']['pagination'] as Map<String, dynamic>;
      
      return {
        'items': items,
        'pagination': paginationJson,
      };
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Failed to load users',
      );
    }
  }

  @override
  Future<AdminUserModel> getUser(String userId) async {
    final response = await dio.get('/admin/users/$userId');
    if (response.data['success'] == true) {
      return AdminUserModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Failed to get user details',
      );
    }
  }

  @override
  Future<AdminUserModel> createUser({
    required String email,
    required String password,
    String? displayName,
    required String role,
    required String status,
  }) async {
    final response = await dio.post(
      '/admin/users',
      data: {
        'email': email,
        'password': password,
        'displayName': displayName,
        'role': role,
        'status': status,
      },
    );
    if (response.data['success'] == true) {
      return AdminUserModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Failed to create user',
      );
    }
  }

  @override
  Future<AdminUserModel> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    final response = await dio.patch(
      '/admin/users/$userId',
      data: updates,
    );
    if (response.data['success'] == true) {
      return AdminUserModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Failed to update user',
      );
    }
  }

  @override
  Future<AdminUserModel> suspendUser(String userId, String? reason) async {
    final response = await dio.post(
      '/admin/users/$userId/suspend',
      data: {'reason': reason},
    );
    if (response.data['success'] == true) {
      return AdminUserModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Failed to suspend user',
      );
    }
  }

  @override
  Future<AdminUserModel> reactivateUser(String userId) async {
    final response = await dio.post('/admin/users/$userId/reactivate');
    if (response.data['success'] == true) {
      return AdminUserModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Failed to reactivate user',
      );
    }
  }

  @override
  Future<void> revokeUserSessions(String userId) async {
    final response = await dio.post('/admin/users/$userId/sessions/revoke');
    if (response.data['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Failed to revoke user sessions',
      );
    }
  }
}
