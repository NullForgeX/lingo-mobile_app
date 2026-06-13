import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/curriculum_bloc.dart';

class UnitsScreen extends StatefulWidget {
  final String languageId;

  const UnitsScreen({super.key, required this.languageId});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CurriculumBloc>().add(LoadUnitsEvent(widget.languageId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Units'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: BlocBuilder<CurriculumBloc, CurriculumState>(
        builder: (context, state) {
          if (state is CurriculumLoading || state is CurriculumInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CurriculumError) {
            return Center(child: Text(state.message));
          } else if (state is UnitsLoaded) {
            final units = state.units;
            if (units.isEmpty) {
              return const Center(child: Text('No units available for this language.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                final order = unit['order'] ?? 0;
                final title = unit['title'] ?? '';
                final summary = unit['summary'] ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 3,
                  child: InkWell(
                    onTap: () {
                      context.push('/units/${widget.languageId}/lessons/${unit['id']}');
                    },
                    child: Container(
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${order + 1}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
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
                                  const SizedBox(height: 8),
                                  Text(
                                    summary,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondaryLight,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.secondaryLight,
                              size: 28,
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
