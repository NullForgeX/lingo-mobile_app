import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

abstract class CurriculumRemoteDataSource {
  Future<List<dynamic>> getLanguages();
  Future<List<dynamic>> getUnits(String languageId);
  Future<List<dynamic>> getLessons(String unitId);
}

class CurriculumRemoteDataSourceImpl implements CurriculumRemoteDataSource {
  final Dio dio;

  CurriculumRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getLanguages() async {
    final response = await dio.get(ApiConstants.getLanguages);
    return response.data['data']['items'];
  }

  @override
  Future<List<dynamic>> getUnits(String languageId) async {
    final response = await dio.get(ApiConstants.getUnits.replaceAll('{languageId}', languageId));
    return response.data['data']['items'];
  }

  @override
  Future<List<dynamic>> getLessons(String unitId) async {
    final response = await dio.get(ApiConstants.getLessons.replaceAll('{unitId}', unitId));
    return response.data['data']['items'];
  }
}
