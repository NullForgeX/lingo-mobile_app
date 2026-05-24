class ApiConstants {
  // Using 10.0.2.2 because the Android emulator cannot reach the Windows localhost.
  static const String baseUrl = 'http://10.0.2.2:777/api/v1';
  
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  
  static const String bootstrap = '/platform/bootstrap';
  // Curriculum Listing
  static const String getLanguages = '/learning/languages';
  static const String getUnits = '/learning/languages/{languageId}/units';
  static const String getLessons = '/learning/units/{unitId}/lessons';
  static const String getDashboard = '/learning/dashboard';

  // Learning & Practice
  static const String getLessonRuntime = '/learning/lessons/{lessonId}/runtime';
  static const String startLessonAttempt = '/learning/lessons/{lessonId}/attempts';
  static const String startExerciseAttempt = '/learning/exercises/{exerciseId}/attempts';
  static const String submitAttempt = '/learning/attempts/{attemptId}/submit';
  static const String getAttemptResult = '/learning/attempts/{attemptId}/result';
}
