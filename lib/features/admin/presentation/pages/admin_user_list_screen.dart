import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/admin_user_card.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final _searchController = TextEditingController();
  String? _selectedRole;
  String? _selectedStatus;
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    context.read<AdminBloc>().add(
          LoadUsersEvent(
            page: _currentPage,
            pageSize: _pageSize,
            search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
            role: _selectedRole,
            status: _selectedStatus,
          ),
        );
  }

  void _onSearch() {
    setState(() {
      _currentPage = 1;
    });
    _loadUsers();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedRole = null;
      _selectedStatus = null;
      _currentPage = 1;
    });
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        leading: GoRouter.of(context).canPop()
            ? null
            : IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  context.go('/home');
                },
                tooltip: 'Go to Learner Dashboard',
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh list',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Panel
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch();
                  },
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Role dropdown
                DropdownButton<String>(
                  value: _selectedRole,
                  hint: const Text('Filter Role'),
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryLight),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Roles')),
                    DropdownMenuItem(value: 'learner', child: Text('Learner')),
                    DropdownMenuItem(value: 'content_manager', child: Text('Content Manager')),
                    DropdownMenuItem(value: 'system_admin', child: Text('System Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                      _currentPage = 1;
                    });
                    _loadUsers();
                  },
                ),
                const SizedBox(width: 16),
                // Status dropdown
                DropdownButton<String>(
                  value: _selectedStatus,
                  hint: const Text('Filter Status'),
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryLight),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Statuses')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                      _currentPage = 1;
                    });
                    _loadUsers();
                  },
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.errorLight),
                ),
              ],
            ),
          ),
          const Divider(),
          // User List
          Expanded(
            child: BlocConsumer<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is AdminActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.primaryLight,
                    ),
                  );
                  _loadUsers(); // Refresh after action
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
                if (state is AdminLoading && _currentPage == 1) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AdminErrorState && _currentPage == 1) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message, style: const TextStyle(color: AppColors.errorLight)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUsers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is UsersLoadedState) {
                  final users = state.users;
                  final pagination = state.pagination;
                  final totalPages = pagination['totalPages'] as int? ?? 1;

                  if (users.isEmpty) {
                    return const Center(child: Text('No users match the search criteria.'));
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return AdminUserCard(
                              user: user,
                              onTap: () {
                                context.push('/admin/user/${user.id}');
                              },
                            );
                          },
                        ),
                      ),
                      // Pagination Controls
                      if (totalPages > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _currentPage > 1
                                    ? () {
                                        setState(() {
                                          _currentPage--;
                                        });
                                        _loadUsers();
                                      }
                                    : null,
                              ),
                              Text(
                                'Page $_currentPage of $totalPages',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _currentPage < totalPages
                                    ? () {
                                        setState(() {
                                          _currentPage++;
                                        });
                                        _loadUsers();
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/admin/user-form');
        },
        backgroundColor: AppColors.primaryLight,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
