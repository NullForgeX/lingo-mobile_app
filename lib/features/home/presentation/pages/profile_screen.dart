import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../curriculum/presentation/bloc/curriculum_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _preferredLanguageId;
  int? _dailyGoalMinutes;
  bool _initialized = false;
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  String? _timezone;

  final List<Map<String, dynamic>> _goals = [
    {'minutes': 5, 'label': 'Casual (5m)'},
    {'minutes': 15, 'label': 'Regular (15m)'},
    {'minutes': 30, 'label': 'Intense (30m)'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<CurriculumBloc>().add(LoadLanguagesEvent());
    context.read<AuthBloc>().add(LoadProfileRequested());
  }

  @override
  void dispose() {
    if (_initialized) {
      _nameController.dispose();
      _bioController.dispose();
    }
    super.dispose();
  }

  void _savePreferences() {
    context.read<AuthBloc>().add(
          UpdatePreferencesRequested(
            displayName: _nameController.text.trim(),
            bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
            preferredLanguageId: _preferredLanguageId,
            dailyLearningGoalMinutes: _dailyGoalMinutes,
            timezone: _timezone,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferences saved successfully!'),
        backgroundColor: AppColors.primaryLight,
      ),
    );
  }

  void _onLogout() {
    context.read<AuthBloc>().add(LogoutRequested());
    context.go('/login');
  }

  Widget _buildGuestWarningCard(BuildContext context, bool isDark) {
    return Card(
      color: AppColors.secondaryLight.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.secondaryLight, width: 1.5),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.secondaryLight, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You are browsing as a Guest',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryLight,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Create an account or log in to sync your progress, scores, and streak to the cloud database.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Log In / Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestHeader(bool isDark) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
          child: const Icon(Icons.account_circle, size: 100, color: AppColors.primaryLight),
        ),
        const SizedBox(height: 16),
        Text(
          'Guest Learner',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _onLogout,
                  tooltip: 'Logout',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthGuest) {
            if (!_initialized) {
              final box = Hive.box('guest_dashboard_box');
              final dashboard = Map<String, dynamic>.from(box.get('dashboard', defaultValue: <String, dynamic>{}) as Map);
              final prefLang = dashboard['preferredLanguage'];
              _preferredLanguageId = prefLang != null ? prefLang['id'] as String? : null;
              _dailyGoalMinutes = dashboard['dailyLearningGoalMinutes'] as int? ?? 15;
              _nameController = TextEditingController(text: 'Guest Learner');
              _bioController = TextEditingController(text: '');
              _timezone = 'Africa/Addis_Ababa';
              _initialized = true;
            }

            return BlocBuilder<CurriculumBloc, CurriculumState>(
              builder: (context, curriculumState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildGuestWarningCard(context, isDark),
                      const SizedBox(height: 32),
                      _buildGuestHeader(isDark),
                      const SizedBox(height: 32),
                      _buildPreferencesSection(curriculumState, isDark),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _savePreferences,
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          if (authState is AuthAuthenticated) {
            final user = authState.user;

            // Initialize local variables with current user data once
            if (!_initialized) {
              _preferredLanguageId = user.preferredLanguageId;
              _dailyGoalMinutes = user.dailyLearningGoalMinutes;
              _nameController = TextEditingController(text: user.displayName);
              _bioController = TextEditingController(text: user.bio ?? '');
              _timezone = user.timezone;
              _initialized = true;
            }

            return BlocBuilder<CurriculumBloc, CurriculumState>(
              builder: (context, curriculumState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildUserInfoHeader(user, isDark),
                      const SizedBox(height: 32),
                      _buildProfileInfoSection(isDark),
                      const SizedBox(height: 32),
                      _buildPreferencesSection(curriculumState, isDark),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _savePreferences,
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }


  Widget _buildUserInfoHeader(user, bool isDark) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl) : null,
          child: user.avatarUrl == null
              ? const Icon(Icons.person, size: 50, color: AppColors.primaryLight)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            user.role.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(CurriculumState curriculumState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Preferences',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        // Language Preference
        Text(
          'Preferred Language',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
        ),
        const SizedBox(height: 8),
        _buildLanguageDropdown(curriculumState, isDark),
        const SizedBox(height: 24),
        // Daily Goal Preference
        Text(
          'Daily Goal',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
        ),
        const SizedBox(height: 8),
        _buildGoalDropdown(isDark),
      ],
    );
  }

  Widget _buildLanguageDropdown(CurriculumState state, bool isDark) {
    if (state is CurriculumLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is LanguagesLoaded) {
      final languages = state.languages;
      if (languages.isEmpty) {
        return const Text('No languages available');
      }

      // Check if selected language ID exists in list, otherwise default to first
      final items = languages.map<DropdownMenuItem<String>>((lang) {
        return DropdownMenuItem<String>(
          value: lang['id'] as String,
          child: Text(lang['name'] as String? ?? ''),
        );
      }).toList();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _preferredLanguageId,
            items: items,
            onChanged: (value) {
              setState(() {
                _preferredLanguageId = value;
              });
            },
            isExpanded: true,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildGoalDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _dailyGoalMinutes,
          items: _goals.map<DropdownMenuItem<int>>((goal) {
            return DropdownMenuItem<int>(
              value: goal['minutes'] as int,
              child: Text(goal['label'] as String),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _dailyGoalMinutes = value;
            });
          },
          isExpanded: true,
        ),
      ),
    );
  }



  Widget _buildProfileInfoSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        // Display Name Field
        Text(
          'Display Name',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter your display name',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Bio Field
        Text(
          'Biography',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bioController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tell us about your learning goals...',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Timezone Field
        Text(
          'Timezone',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
        ),
        const SizedBox(height: 8),
        _buildTimezoneDropdown(isDark),
      ],
    );
  }

  Widget _buildTimezoneDropdown(bool isDark) {
    final List<String> timezones = [
      'Africa/Addis_Ababa',
      'UTC',
      'America/New_York',
      'Europe/London',
      'Asia/Tokyo',
    ];
    if (_timezone == null || !timezones.contains(_timezone)) {
      if (_timezone != null) {
        timezones.add(_timezone!);
      } else {
        _timezone = 'Africa/Addis_Ababa';
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _timezone,
          items: timezones.map<DropdownMenuItem<String>>((tz) {
            return DropdownMenuItem<String>(
              value: tz,
              child: Text(tz),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _timezone = value;
            });
          },
          isExpanded: true,
        ),
      ),
    );
  }
}
