import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getDashboard();
  Future<Map<String, dynamic>> getLeaderboard({int page = 1, int pageSize = 20, String order = 'desc'});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await dio.get(ApiConstants.getDashboard);
    return response.data['data'];
  }

  @override
  Future<Map<String, dynamic>> getLeaderboard({int page = 1, int pageSize = 20, String order = 'desc'}) async {
    final response = await dio.get(
      ApiConstants.getLeaderboard,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'order': order,
      },
    );
    return response.data['data'];
  }
}
