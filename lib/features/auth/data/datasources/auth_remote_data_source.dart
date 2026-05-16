import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String displayName);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

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
      return UserModel.fromJson(response.data['data']);
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
}
