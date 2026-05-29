import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_user.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final String userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  final _suspensionReasonController = TextEditingController();

  @override
  void dispose() {
    _suspensionReasonController.dispose();
    super.dispose();
  }

  void _loadUserDetail() {
    context.read<AdminBloc>().add(LoadUserDetailEvent(widget.userId));
  }

  void _showSuspendDialog(BuildContext context, AdminUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Suspend ${user.displayName ?? user.email}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please specify a reason for suspending this account:'),
              const SizedBox(height: 16),
              TextField(
                controller: _suspensionReasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'e.g. Terms violations, spamming',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _suspensionReasonController.clear();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = _suspensionReasonController.text.trim();
                context.read<AdminBloc>().add(
                      SuspendUserEvent(
                        userId: user.id,
                        reason: reason.isNotEmpty ? reason : null,
                      ),
                    );
                _suspensionReasonController.clear();
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorLight),
              child: const Text('Suspend', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showReactivateDialog(BuildContext context, AdminUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reactivate Account'),
          content: Text('Are you sure you want to reactivate the account for ${user.displayName ?? user.email}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AdminBloc>().add(ReactivateUserEvent(user.id));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Reactivate'),
            ),
          ],
        );
      },
    );
  }

  void _showRevokeSessionsDialog(BuildContext context, AdminUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Revoke Active Sessions'),
          content: Text('This will force logout ${user.displayName ?? user.email} from all signed-in devices. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AdminBloc>().add(RevokeSessionsEvent(user.id));
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorLight),
              child: const Text('Revoke All', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Never';
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
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
            _loadUserDetail(); // Reload user details to reflect status updates
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
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: AppColors.errorLight)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserDetail,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is UserDetailLoadedState) {
            final user = state.user;
            final isSuspended = user.status == 'suspended';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
                          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  (user.displayName ?? user.email)[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.displayName ?? 'No Display Name',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildInfoBadge(user.role.toUpperCase(), Colors.purple),
                            const SizedBox(width: 8),
                            _buildInfoBadge(
                              user.status.toUpperCase(),
                              isSuspended ? AppColors.errorLight : AppColors.primaryLight,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Metadata Info
                  _buildSectionTitle('Account Information'),
                  _buildInfoTile('User ID', user.id),
                  _buildInfoTile('Bio', user.bio ?? 'None'),
                  _buildInfoTile('Timezone', user.timezone ?? 'Not Set'),
                  _buildInfoTile('Preferred Language ID', user.preferredLanguageId ?? 'None'),
                  _buildInfoTile('Daily Learning Goal', user.dailyLearningGoalMinutes != null ? '${user.dailyLearningGoalMinutes} minutes' : 'None'),
                  _buildInfoTile('Joined At', _formatDate(user.createdAt)),
                  _buildInfoTile('Last Login', _formatDate(user.lastLoginAt)),
                  
                  if (isSuspended) ...[
                    const SizedBox(height: 16),
                    _buildSectionTitle('Suspension Details'),
                    _buildInfoTile('Suspended At', _formatDate(user.suspendedAt)),
                    _buildInfoTile('Suspended By ID', user.suspendedByUserId ?? 'System'),
                    _buildInfoTile('Reason', user.suspensionReason ?? 'No reason provided'),
                  ],
                  const SizedBox(height: 32),
                  // Admin Action Buttons
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/admin/user-form', extra: user);
                    },
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    label: const Text('Edit User Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: isSuspended ? () => _showReactivateDialog(context, user) : () => _showSuspendDialog(context, user),
                    icon: Icon(
                      isSuspended ? Icons.check_circle_outline : Icons.block_flipped,
                      color: isSuspended ? AppColors.primaryLight : AppColors.errorLight,
                    ),
                    label: Text(
                      isSuspended ? 'Reactivate Account' : 'Suspend Account',
                      style: TextStyle(
                        color: isSuspended ? AppColors.primaryLight : AppColors.errorLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isSuspended ? AppColors.primaryLight : AppColors.errorLight,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showRevokeSessionsDialog(context, user),
                    icon: const Icon(Icons.power_settings_new, color: Colors.orange),
                    label: const Text('Revoke Active Sessions', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
