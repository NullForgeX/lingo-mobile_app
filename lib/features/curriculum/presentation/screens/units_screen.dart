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
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.secondaryLight,
                      child: Icon(Icons.menu_book, color: Colors.white),
                    ),
                    title: Text(
                      unit['title'] ?? '',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(unit['summary'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.push('/units/${widget.languageId}/lessons/${unit['id']}');
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
