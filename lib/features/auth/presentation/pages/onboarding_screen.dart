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
  int _currentStep = 1;
  String? _selectedLanguageId;
  int? _selectedGoalMinutes;

  final List<Map<String, dynamic>> _goals = [
    {
      'minutes': 5,
      'label': 'Casual',
      'emoji': '🌱',
      'desc': '5 minutes per day',
      'subtitle': 'Perfect for busy schedules',
    },
    {
      'minutes': 15,
      'label': 'Regular',
      'emoji': '🔥',
      'desc': '15 minutes per day',
      'subtitle': 'Recommended for most learners',
    },
    {
      'minutes': 30,
      'label': 'Intense',
      'emoji': '🚀',
      'desc': '30 minutes per day',
      'subtitle': 'For serious language goals',
    },
  ];

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
    if (_selectedLanguageId != null && _selectedGoalMinutes != null) {
      context.read<AuthBloc>().add(
            UpdatePreferencesRequested(
              preferredLanguageId: _selectedLanguageId!,
              dailyLearningGoalMinutes: _selectedGoalMinutes!,
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
            if (authState is AuthAuthenticated) {
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
                      const SizedBox(height: 16),
                      _buildStepIndicator(isDark),
                      const SizedBox(height: 32),
                      Expanded(
                        child: _currentStep == 1
                            ? _buildLanguageSelectionStep(isDark)
                            : _buildGoalSelectionStep(isDark),
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

  Widget _buildStepIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(1, 'Language', _currentStep >= 1, isDark),
        Container(
          width: 48,
          height: 2,
          color: _currentStep > 1
              ? AppColors.primaryLight
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        _buildStepCircle(2, 'Daily Goal', _currentStep == 2, isDark),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label, bool isActive, bool isDark) {
    final color = isActive
        ? AppColors.primaryLight
        : (isDark ? AppColors.borderDark : AppColors.borderLight);
    final textColor = isActive
        ? Colors.white
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
      ],
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

  Widget _buildGoalSelectionStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Set your daily goal',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how much time you want to dedicate daily.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
            itemCount: _goals.length,
            itemBuilder: (context, index) {
              final goal = _goals[index];
              final minutes = goal['minutes'] as int;
              final isSelected = _selectedGoalMinutes == minutes;

              final cardColor = isSelected
                  ? AppColors.primaryLight.withValues(alpha: 0.1)
                  : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

              final borderColor = isSelected
                  ? AppColors.primaryLight
                  : (isDark ? AppColors.borderDark : AppColors.borderLight);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGoalMinutes = minutes;
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
                      Text(
                        goal['emoji'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['label'] as String,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal['subtitle'] as String,
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
                        '${minutes}m / day',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
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

  Widget _buildNavigationButtons(bool isSaving) {
    final nextDisabled = _currentStep == 1
        ? _selectedLanguageId == null
        : _selectedGoalMinutes == null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 1)
          OutlinedButton(
            onPressed: isSaving
                ? null
                : () {
                    setState(() {
                      _currentStep = 1;
                    });
                  },
            child: const Text('Back'),
          )
        else
          const SizedBox.shrink(),
        ElevatedButton(
          onPressed: nextDisabled || isSaving
              ? null
              : () {
                  if (_currentStep == 1) {
                    setState(() {
                      _currentStep = 2;
                    });
                  } else {
                    _onFinish();
                  }
                },
          child: Text(_currentStep == 1 ? 'Continue' : 'Start Learning'),
        ),
      ],
    );
  }
}
