import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../curriculum/presentation/bloc/curriculum_bloc.dart';
import '../../domain/entities/admin_user.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminUserFormScreen extends StatefulWidget {
  final AdminUser? userToEdit;

  const AdminUserFormScreen({super.key, this.userToEdit});

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  
  String _selectedRole = 'learner';
  String _selectedStatus = 'active';
  String? _preferredLanguageId;
  int? _dailyGoalMinutes;

  final List<Map<String, dynamic>> _goals = [
    {'minutes': null, 'label': 'No Goal'},
    {'minutes': 5, 'label': 'Casual (5m)'},
    {'minutes': 15, 'label': 'Regular (15m)'},
    {'minutes': 30, 'label': 'Intense (30m)'},
  ];

  bool get isEditMode => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final user = widget.userToEdit!;
      _emailController.text = user.email;
      _displayNameController.text = user.displayName ?? '';
      _bioController.text = user.bio ?? '';
      _selectedRole = user.role;
      _selectedStatus = user.status;
      _preferredLanguageId = user.preferredLanguageId;
      _dailyGoalMinutes = user.dailyLearningGoalMinutes;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (isEditMode) {
        context.read<AdminBloc>().add(
              UpdateUserEvent(
                userId: widget.userToEdit!.id,
                displayName: _displayNameController.text.trim(),
                bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
                preferredLanguageId: _preferredLanguageId,
                dailyLearningGoalMinutes: _dailyGoalMinutes,
                role: _selectedRole,
                status: _selectedStatus,
              ),
            );
      } else {
        context.read<AdminBloc>().add(
              CreateUserEvent(
                email: _emailController.text.trim(),
                password: _passwordController.text,
                displayName: _displayNameController.text.trim().isNotEmpty
                    ? _displayNameController.text.trim()
                    : null,
                role: _selectedRole,
                status: _selectedStatus,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit User' : 'Create User'),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primaryLight,
              ),
            );
            context.pop(); // Go back to list or detail screen
          } else if (state is AdminErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorLight,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AdminLoading;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isEditMode && !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password (only in create mode)
                  if (!isEditMode) ...[
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Display Name
                  TextFormField(
                    controller: _displayNameController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bio (only in edit mode)
                  if (isEditMode) ...[
                    TextFormField(
                      controller: _bioController,
                      enabled: !isLoading,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.security),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'learner', child: Text('Learner')),
                      DropdownMenuItem(value: 'content_manager', child: Text('Content Manager')),
                      DropdownMenuItem(value: 'system_admin', child: Text('System Admin')),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedRole = value;
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.toggle_on_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  // Preferred Language Dropdown (only in edit mode)
                  if (isEditMode) ...[
                    BlocBuilder<CurriculumBloc, CurriculumState>(
                      builder: (context, currState) {
                        List<DropdownMenuItem<String>> items = [
                          const DropdownMenuItem(value: null, child: Text('None (No preferred language)')),
                        ];

                        if (currState is LanguagesLoaded) {
                          items.addAll(
                            currState.languages.map(
                              (lang) => DropdownMenuItem(
                                value: lang['id'] as String,
                                child: Text(lang['name'] as String? ?? ''),
                              ),
                            ),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: _preferredLanguageId,
                          decoration: const InputDecoration(
                            labelText: 'Preferred Language',
                            prefixIcon: Icon(Icons.language),
                          ),
                          items: items,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _preferredLanguageId = value;
                                  });
                                },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Daily Goal Dropdown (only in edit mode)
                    DropdownButtonFormField<int?>(
                      value: _dailyGoalMinutes,
                      decoration: const InputDecoration(
                        labelText: 'Daily Goal',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: _goals.map((goal) {
                        return DropdownMenuItem<int?>(
                          value: goal['minutes'] as int?,
                          child: Text(goal['label'] as String),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _dailyGoalMinutes = value;
                              });
                            },
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Save Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            isEditMode ? 'Save Changes' : 'Create User',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
