import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/curriculum_bloc.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CurriculumBloc>().add(LoadLanguagesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Languages'),
      ),
      body: BlocBuilder<CurriculumBloc, CurriculumState>(
        builder: (context, state) {
          if (state is CurriculumLoading || state is CurriculumInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CurriculumError) {
            return Center(child: Text(state.message));
          } else if (state is LanguagesLoaded) {
            final languages = state.languages;
            if (languages.isEmpty) {
              return const Center(child: Text('No languages available yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final lang = languages[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.language, color: Colors.white),
                    ),
                    title: Text(
                      lang['name'] ?? '',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(lang['summary'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to Units screen (we'll implement this route next)
                      context.push('/units/${lang['id']}');
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
