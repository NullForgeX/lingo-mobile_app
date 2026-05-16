class ApiConstants {
  // Using 10.0.2.2 because the Android emulator cannot reach the Windows localhost.
  static const String baseUrl = 'http://10.0.2.2:777/api/v1';
  
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  
  static const String bootstrap = '/platform/bootstrap';
}
