import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/practice_bloc.dart';

class AttemptsHistoryScreen extends StatelessWidget {
  const AttemptsHistoryScreen({super.key});

  String _formatDateTime(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$min $period';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice History'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<PracticeBloc, PracticeState>(
        builder: (context, state) {
          if (state is PracticeLoading || state is PracticeInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PracticeError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.errorLight),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load history',
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
                        context.read<PracticeBloc>().add(ListAttemptsEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is AttemptsListLoaded) {
            final attempts = state.attemptsData['items'] as List<dynamic>? ?? [];

            if (attempts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history_edu_rounded,
                          size: 64,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Practice History',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Start learning and complete lesson exercises to see your progress history here.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/practice'),
                        icon: const Icon(Icons.school_rounded, color: Colors.white),
                        label: const Text('Start Practicing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                final status = attempt['status'] ?? 'in_progress';
                final startedAt = attempt['startedAt'] ?? '';
                final attemptNumber = attempt['attemptNumber'] ?? 1;
                final lessonId = attempt['lessonId'] ?? '';
                final scoreSummary = attempt['scoreSummary'] ?? {};
                final score = scoreSummary['score'] ?? 0;
                final maxScore = scoreSummary['maxScore'] ?? 0;
                final percentage = scoreSummary['percentage'] ?? 0.0;
                final passed = scoreSummary['passed'] ?? false;

                Color statusColor;
                IconData statusIcon;
                String statusLabel;

                if (status == 'submitted') {
                  if (passed) {
                    statusColor = AppColors.primaryLight;
                    statusIcon = Icons.check_circle_rounded;
                    statusLabel = 'Passed';
                  } else {
                    statusColor = AppColors.errorLight;
                    statusIcon = Icons.cancel_rounded;
                    statusLabel = 'Failed';
                  }
                } else if (status == 'abandoned') {
                  statusColor = Colors.grey.shade500;
                  statusIcon = Icons.flag_rounded;
                  statusLabel = 'Abandoned';
                } else {
                  statusColor = AppColors.secondaryLight;
                  statusIcon = Icons.hourglass_empty_rounded;
                  statusLabel = 'In Progress';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : Colors.grey[200]!,
                      width: 1.5,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: lessonId.isNotEmpty
                        ? () => context.push('/practice_lesson/$lessonId')
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attempt['lessonTitle'] ?? 'Attempt #$attemptNumber',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Attempt #$attemptNumber • ${_formatDateTime(startedAt)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white38 : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              if (status == 'submitted') ...[
                                const SizedBox(height: 6),
                                Text(
                                  '$score/$maxScore (${percentage.toStringAsFixed(0)}%)',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: passed ? AppColors.primaryLight : AppColors.errorLight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
