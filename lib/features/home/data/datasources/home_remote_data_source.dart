import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getDashboard();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await dio.get(ApiConstants.getDashboard);
    return response.data['data'];
  }
}
