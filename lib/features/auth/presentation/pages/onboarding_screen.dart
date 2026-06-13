import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../curriculum/presentation/bloc/curriculum_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selectedLanguageId;

  @override
  void initState() {
    super.initState();
    // Load available languages from the backend curriculum
    context.read<CurriculumBloc>().add(LoadLanguagesEvent());
  }

  Map<String, String> _getLanguageMeta(String name) {
    switch (name.toLowerCase()) {
      case 'amharic':
        return {
          'script': 'አ',
          'greeting': 'ሰላም',
          'description': 'Official language of Ethiopia',
        };
      case 'oromo':
      case 'afan oromoo':
        return {
          'script': 'O',
          'greeting': 'Nagaa',
          'description': 'Most widely spoken in Ethiopia',
        };
      case 'tigrinya':
        return {
          'script': 'ት',
          'greeting': 'ሰላም',
          'description': 'Spoken in northern Ethiopia & Eritrea',
        };
      default:
        return {
          'script': 'A',
          'greeting': 'Selam',
          'description': 'Regional language of Abyssinia',
        };
    }
  }

  void _onFinish() {
    if (_selectedLanguageId != null) {
      context.read<AuthBloc>().add(
            UpdatePreferencesRequested(
              preferredLanguageId: _selectedLanguageId!,
              dailyLearningGoalMinutes: 15, // Default to 15 minutes
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is AuthAuthenticated || authState is AuthGuest) {
              // Successfully saved preferences, go to Home
              context.go('/home');
            } else if (authState is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authState.message),
                  backgroundColor: AppColors.errorLight,
                ),
              );
            }
          },
          builder: (context, authState) {
            final isSaving = authState is AuthLoading;

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      Expanded(
                        child: _buildLanguageSelectionStep(isDark),
                      ),
                      const SizedBox(height: 16),
                      _buildNavigationButtons(isSaving),
                    ],
                  ),
                ),
                if (isSaving)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageSelectionStep(bool isDark) {
    return BlocBuilder<CurriculumBloc, CurriculumState>(
      builder: (context, state) {
        if (state is CurriculumLoading || state is CurriculumInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CurriculumError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: isDark ? AppColors.errorDark : AppColors.errorLight),
            ),
          );
        } else if (state is LanguagesLoaded) {
          final languages = state.languages;
          if (languages.isEmpty) {
            return const Center(child: Text('No languages available yet.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose your language',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select the language you want to learn first.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final langId = lang['id'] as String;
                    final name = lang['name'] as String? ?? '';
                    final meta = _getLanguageMeta(name);
                    final isSelected = _selectedLanguageId == langId;

                    final cardColor = isSelected
                        ? AppColors.primaryLight.withValues(alpha: 0.1)
                        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

                    final borderColor = isSelected
                        ? AppColors.primaryLight
                        : (isDark ? AppColors.borderDark : AppColors.borderLight);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLanguageId = langId;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          border: Border.all(color: borderColor, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  meta['script']!,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    meta['description']!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '"${meta['greeting']}"',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.secondaryDark
                                    : AppColors.secondaryLight,
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
    );
  }

  Widget _buildNavigationButtons(bool isSaving) {
    final nextDisabled = _selectedLanguageId == null;

    return ElevatedButton(
      onPressed: nextDisabled || isSaving ? null : _onFinish,
      child: const Text('Start Learning'),
    );
  }
}
