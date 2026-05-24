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
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.play_lesson, color: Colors.white),
                    ),
                    title: Text(
                      lesson['title'] ?? '',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(lesson['summary'] ?? ''),
                    trailing: const Icon(Icons.play_circle_fill, color: AppColors.primaryLight),
                    onTap: () {
                      context.push('/practice_lesson/${lesson['id']}');
                    },
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
