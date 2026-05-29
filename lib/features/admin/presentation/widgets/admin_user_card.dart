import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_user.dart';

class AdminUserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  Color _getRoleColor(String role) {
    switch (role) {
      case 'system_admin':
        return Colors.purple;
      case 'content_manager':
        return AppColors.secondaryLight;
      default:
        return AppColors.primaryLight;
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'suspended') {
      return AppColors.errorLight;
    }
    return AppColors.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = user.displayName ?? '';
    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : user.email[0].toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(
                  initial,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        title: Text(
          displayName.isNotEmpty ? displayName : user.email,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (displayName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                _buildBadge(
                  user.role.replaceAll('_', ' ').toUpperCase(),
                  _getRoleColor(user.role),
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  user.status.toUpperCase(),
                  _getStatusColor(user.status),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
