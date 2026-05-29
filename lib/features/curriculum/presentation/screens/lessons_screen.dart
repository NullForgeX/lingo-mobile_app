import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/curriculum_bloc.dart';

class LessonsScreen extends StatefulWidget {
  final String unitId;

  const LessonsScreen({super.key, required this.unitId});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CurriculumBloc>().add(LoadLessonsEvent(widget.unitId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
      ),
      body: BlocBuilder<CurriculumBloc, CurriculumState>(
        builder: (context, state) {
          if (state is CurriculumLoading || state is CurriculumInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CurriculumError) {
            return Center(child: Text(state.message));
          } else if (state is LessonsLoaded) {
            final lessons = state.lessons;
            if (lessons.isEmpty) {
              return const Center(child: Text('No lessons available for this unit.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final title = lesson['title'] ?? '';
                final summary = lesson['summary'] ?? '';
                final duration = lesson['estimatedDurationMinutes'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 3,
                  child: InkWell(
                    onTap: () {
                      context.push('/practice_lesson/${lesson['id']}');
                    },
                    child: Container(
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.play_lesson_rounded,
                              color: AppColors.primaryLight,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                ),
                                if (summary.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    summary,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondaryLight,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                                if (duration != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 14,
                                        color: AppColors.primaryLight,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$duration min',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_circle_filled_rounded,
                              color: AppColors.primaryLight,
                              size: 32,
                            ),
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
