import '../../domain/entities/sync_result.dart';
import 'user_model.dart';

class SyncResultModel extends SyncResult {
  const SyncResultModel({
    required super.user,
    required super.xp,
    required super.streak,
  });

  factory SyncResultModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? json;
    final xpJson = json['xp'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final streakJson = json['streak'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return SyncResultModel(
      user: UserModel.fromJson(userJson),
      xp: Map<String, dynamic>.from(xpJson),
      streak: Map<String, dynamic>.from(streakJson),
    );
  }
}
