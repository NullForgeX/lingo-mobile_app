import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/home_bloc.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get current logged-in user id to highlight their row
    String? currentUserId;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      currentUserId = authState.user.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is LeaderboardLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LeaderboardError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.errorLight),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load leaderboard',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(LoadLeaderboardEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is LeaderboardLoaded) {
            final items = state.leaderboardData['items'] as List<dynamic>? ?? [];

            if (items.isEmpty) {
              return Center(
                child: Text(
                  'No rankings available yet.',
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            final top1 = items.isNotEmpty ? items[0] : null;
            final top2 = items.length > 1 ? items[1] : null;
            final top3 = items.length > 2 ? items[2] : null;
            final remaining = items.length > 3 ? items.sublist(3) : [];

            return Column(
              children: [
                // Top 3 Podium
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surface : theme.colorScheme.primary.withValues(alpha: 0.03),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.borderDark : Colors.grey[200]!,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Rank 2
                      if (top2 != null)
                        Expanded(
                          child: _buildPodiumUser(
                            context,
                            user: top2,
                            rank: 2,
                            avatarRadius: 30,
                            borderColor: Colors.grey.shade400,
                            isDark: isDark,
                          ),
                        )
                      else
                        const Spacer(),

                      // Rank 1
                      if (top1 != null)
                        Expanded(
                          child: _buildPodiumUser(
                            context,
                            user: top1,
                            rank: 1,
                            avatarRadius: 40,
                            borderColor: Colors.amber.shade600,
                            isDark: isDark,
                          ),
                        )
                      else
                        const Spacer(),

                      // Rank 3
                      if (top3 != null)
                        Expanded(
                          child: _buildPodiumUser(
                            context,
                            user: top3,
                            rank: 3,
                            avatarRadius: 26,
                            borderColor: Colors.deepOrange.shade300,
                            isDark: isDark,
                          ),
                        )
                      else
                        const Spacer(),
                    ],
                  ),
                ),

                // Rank 4+ List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: remaining.length,
                    itemBuilder: (context, index) {
                      final item = remaining[index];
                      final rank = item['rank'] ?? (index + 4);
                      final displayName = item['displayName'] ?? 'Learner';
                      final totalXp = item['totalXp'] ?? 0;
                      final completedLessons = item['completedLessonCount'] ?? 0;
                      final badgeCount = item['badgeCount'] ?? 0;
                      final learnerId = item['learnerId'];

                      final isMe = currentUserId != null && learnerId == currentUserId;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: isMe
                            ? AppColors.primaryLight.withValues(alpha: 0.08)
                            : (isDark ? theme.colorScheme.surface : Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isMe
                                ? AppColors.primaryLight
                                : (isDark ? AppColors.borderDark : Colors.grey[200]!),
                            width: isMe ? 2 : 1.5,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '$rank',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isMe ? AppColors.primaryLight : (isDark ? Colors.white70 : Colors.black54),
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
                                child: Text(
                                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'L',
                                  style: const TextStyle(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            displayName + (isMe ? ' (You)' : ''),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '📚 $completedLessons lessons completed • 🏆 $badgeCount badges',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flash_on_rounded, color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '$totalXp XP',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPodiumUser(
    BuildContext context, {
    required Map<String, dynamic> user,
    required int rank,
    required double avatarRadius,
    required Color borderColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final displayName = user['displayName'] ?? 'Learner';
    final totalXp = user['totalXp'] ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rank == 1) ...[
          const Icon(Icons.emoji_events_rounded, color: Colors.orangeAccent, size: 32),
          const SizedBox(height: 4),
        ],
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 3),
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'L',
                  style: TextStyle(
                    fontSize: avatarRadius * 0.7,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: rank == 1 ? FontWeight.bold : FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flash_on_rounded, color: Colors.orange, size: 14),
            Text(
              '$totalXp XP',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
