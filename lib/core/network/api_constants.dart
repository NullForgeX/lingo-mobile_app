class ApiConstants {
  // Use 10.0.2.2 for Android emulator pointing to localhost, or your actual local IP.
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  
  static const String bootstrap = '/platform/bootstrap';
}
