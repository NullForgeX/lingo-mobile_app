import 'package:dio/dio.dart';
import 'api_constants.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If the error is 401 Unauthorized, we attempt to refresh the token.
    if (err.response?.statusCode == 401) {
      final isRefreshed = await _refreshToken();

      if (isRefreshed) {
        // Retry the original request
        try {
          final options = err.requestOptions;
          // Clone the request with the same options. The cookie manager
          // will automatically inject the newly refreshed cookies.
          final response = await _dio.request(
            options.path,
            options: Options(
              method: options.method,
              headers: options.headers,
              contentType: options.contentType,
              responseType: options.responseType,
            ),
            data: options.data,
            queryParameters: options.queryParameters,
          );
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      } else {
        // If refresh fails, we can't do anything else.
        // A Bloc down the line should listen to this and log the user out.
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      // The cookie manager handles sending the lingo_refresh_token automatically
      // if it was set during login.
      final response = await _dio.post(ApiConstants.refresh);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
