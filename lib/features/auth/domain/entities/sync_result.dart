import 'user.dart';

class SyncResult {
  final User user;
  final Map<String, dynamic> xp;
  final Map<String, dynamic> streak;

  const SyncResult({
    required this.user,
    required this.xp,
    required this.streak,
  });
}
