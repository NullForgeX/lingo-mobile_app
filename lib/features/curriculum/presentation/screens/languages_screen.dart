import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hive/hive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/repositories/curriculum_repository.dart';
import '../bloc/curriculum_bloc.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  List<dynamic> _languages = [];

  @override
  void initState() {
    super.initState();
    context.read<CurriculumBloc>().add(LoadLanguagesEvent());

    final authState = context.read<AuthBloc>().state;
    String? prefLanguageId;
    if (authState is AuthAuthenticated) {
      prefLanguageId = authState.user.preferredLanguageId;
    } else {
      final box = Hive.box('guest_dashboard_box');
      final dashboard = box.get('dashboard', defaultValue: <dynamic, dynamic>{}) as Map;
      final preferredLanguage = dashboard['preferredLanguage'] as Map?;
      if (preferredLanguage != null) {
        prefLanguageId = preferredLanguage['id']?.toString();
      }
    }

    if (prefLanguageId != null && prefLanguageId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/units/$prefLanguageId');
        }
      });
    }
  }

  void _showLanguageDetails(BuildContext context, Map<String, dynamic> initialLang, bool isSelecting) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CurriculumBloc>()),
            BlocProvider.value(value: context.read<AuthBloc>()),
          ],
          child: LanguageDetailsBottomSheet(
            initialLanguage: initialLang,
            isSelecting: isSelecting,
            onSelect: () {
              context.read<CurriculumBloc>().add(SelectLanguageEvent(initialLang['id']));
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Languages'),
      ),
      body: BlocConsumer<CurriculumBloc, CurriculumState>(
        listener: (context, state) {
          if (state is LanguagesLoaded) {
            setState(() {
              _languages = state.languages;
            });
          } else if (state is LanguageSelectedState) {
            // Dismiss bottom sheet if open
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            // Update auth state in memory
            context.read<AuthBloc>().add(UserProfileUpdated(state.user));
            // Navigate to units
            context.push('/units/${state.user.preferredLanguageId}');
          } else if (state is CurriculumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorLight,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CurriculumLoading || state is CurriculumInitial;

          if (isLoading && _languages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_languages.isEmpty && state is CurriculumError) {
            return Center(child: Text(state.message));
          }

          if (_languages.isEmpty && !isLoading) {
            return const Center(child: Text('No languages available yet.'));
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  final name = lang['name'] ?? '';
                  final nativeName = lang['nativeName'] ?? '';
                  final script = lang['script'] ?? '';
                  final summary = lang['summary'] ?? '';
                  final levels = lang['proficiencyLevels'] as List<dynamic>? ?? [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 3,
                    child: InkWell(
                      onTap: isLoading
                          ? null
                          : () {
                              _showLanguageDetails(context, lang, isLoading);
                            },
                      child: Container(
                        color: Theme.of(context).cardColor,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.translate_rounded,
                                    color: AppColors.primaryLight,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nativeName.isNotEmpty ? '$name ($nativeName)' : name,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                      ),
                                      if (script.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                          ),
                                          child: Text(
                                            'Script: $script',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.black38,
                                  size: 24,
                                ),
                              ],
                            ),
                            if (summary.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Text(
                                summary,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.3,
                                ),
                              ),
                            ],
                            if (levels.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: levels.map<Widget>((level) {
                                  final label = level['label'] ?? '';
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.primaryLight.withOpacity(0.15),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.15),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryLight),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class LanguageDetailsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> initialLanguage;
  final VoidCallback onSelect;
  final bool isSelecting;

  const LanguageDetailsBottomSheet({
    super.key,
    required this.initialLanguage,
    required this.onSelect,
    required this.isSelecting,
  });

  @override
  State<LanguageDetailsBottomSheet> createState() => _LanguageDetailsBottomSheetState();
}

class _LanguageDetailsBottomSheetState extends State<LanguageDetailsBottomSheet> {
  Map<String, dynamic>? _detailedLanguage;
  String? _errorMessage;
  bool _isLoadingDetail = true;

  @override
  void initState() {
    super.initState();
    _loadLanguageDetail();
  }

  Future<void> _loadLanguageDetail() async {
    try {
      final repository = sl<CurriculumRepository>();
      final result = await repository.getLanguageDetail(widget.initialLanguage['id']);
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _errorMessage = failure.message;
              _isLoadingDetail = false;
            });
          }
        },
        (languageData) {
          if (mounted) {
            setState(() {
              _detailedLanguage = languageData;
              _isLoadingDetail = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingDetail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.initialLanguage['name'] ?? '';
    final nativeName = widget.initialLanguage['nativeName'] ?? '';
    final script = widget.initialLanguage['script'] ?? '';
    final summary = widget.initialLanguage['summary'] ?? '';
    final levels = widget.initialLanguage['proficiencyLevels'] as List<dynamic>? ?? [];
    
    final description = _detailedLanguage?['description'] ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    color: AppColors.primaryLight,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nativeName.isNotEmpty ? '$name ($nativeName)' : name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Script: $script',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'About the Course',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoadingDetail)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(color: AppColors.primaryLight),
                ),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Failed to load details: $_errorMessage',
                  style: const TextStyle(color: AppColors.errorLight),
                ),
              )
            else
              Text(
                description.isNotEmpty ? description : summary,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Proficiency Levels Included',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: levels.map<Widget>((level) {
                final label = level['label'] ?? '';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryLight.withOpacity(0.15),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: widget.isSelecting ? null : widget.onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: widget.isSelecting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Select & Start Learning',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
