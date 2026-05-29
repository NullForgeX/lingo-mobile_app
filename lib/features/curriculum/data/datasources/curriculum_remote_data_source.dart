import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/data/models/user_model.dart';

abstract class CurriculumRemoteDataSource {
  Future<List<dynamic>> getLanguages();
  Future<Map<String, dynamic>> getLanguageDetail(String languageId);
  Future<List<dynamic>> getUnits(String languageId);
  Future<List<dynamic>> getLessons(String unitId);
  Future<UserModel> selectLanguage(String languageId);
}

class CurriculumRemoteDataSourceImpl implements CurriculumRemoteDataSource {
  final Dio dio;

  CurriculumRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getLanguages() async {
    final response = await dio.get(
      ApiConstants.getLanguages,
      queryParameters: {
        'page': 1,
        'pageSize': 20,
        'sort': 'name',
        'order': 'asc',
      },
    );
    return response.data['data']['items'];
  }

  @override
  Future<Map<String, dynamic>> getLanguageDetail(String languageId) async {
    final response = await dio.get(
      ApiConstants.getLanguageDetail.replaceAll('{languageId}', languageId),
    );
    return response.data['data'];
  }

  @override
  Future<List<dynamic>> getUnits(String languageId) async {
    final response = await dio.get(
      ApiConstants.getUnits.replaceAll('{languageId}', languageId),
      queryParameters: {
        'page': 1,
        'pageSize': 20,
        'sort': 'order',
        'order': 'asc',
      },
    );
    return response.data['data']['items'];
  }

  @override
  Future<List<dynamic>> getLessons(String unitId) async {
    final response = await dio.get(ApiConstants.getLessons.replaceAll('{unitId}', unitId));
    return response.data['data']['items'];
  }

  @override
  Future<UserModel> selectLanguage(String languageId) async {
    final response = await dio.post(
      ApiConstants.selectLanguage.replaceAll('{languageId}', languageId),
    );
    if (response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['error']?['message'] ?? 'Failed to select language',
      );
    }
  }
}
