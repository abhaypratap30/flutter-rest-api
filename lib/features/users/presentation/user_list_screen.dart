import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rest_api/core/providers/core_providers.dart';
import 'package:flutter_rest_api/features/users/presentation/user_detail_screen.dart';
import 'package:flutter_rest_api/features/users/presentation/user_form_dialog.dart';
import 'package:flutter_rest_api/features/users/providers/user_provider.dart';
import 'package:flutter_rest_api/shared/widgets/empty_view.dart';
import 'package:flutter_rest_api/shared/widgets/error_view.dart';
import 'package:flutter_rest_api/shared/widgets/skeleton_loader.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(userListProvider.notifier).fetchNextPage();
    }
  }

  void _confirmDelete(int userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User (DELETE)'),
        content: const Text('Are you sure you want to delete this user from the server?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final userRepository = ref.read(userRepositoryProvider);
              final result = await userRepository.deleteUser(userId);
              result.when(
                success: (_) {
                  ref.read(userListProvider.notifier).removeUserLocal(userId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User deleted successfully!')),
                    );
                  }
                },
                failure: (msg, code, ex) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Delete failed: $msg')),
                    );
                  }
                },
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Create User',
            onPressed: () => UserFormDialog.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(userListProvider.notifier).searchUsers('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                ref.read(userListProvider.notifier).searchUsers(val.trim());
              },
            ),
          ),
          Expanded(
            child: _buildBody(state, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(UserListState state, ThemeData theme) {
    if (state.isLoading && state.users.isEmpty) {
      return const UserListSkeleton();
    }

    if (state.errorMessage != null && state.users.isEmpty) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => ref.read(userListProvider.notifier).fetchUsers(refresh: true),
      );
    }

    if (state.users.isEmpty) {
      return EmptyView(
        title: 'No users found',
        description: 'Try searching for a different keyword or create a new user.',
        buttonText: 'Refresh List',
        onAction: () => ref.read(userListProvider.notifier).fetchUsers(refresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(userListProvider.notifier).fetchUsers(refresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.users.length + (state.hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.users.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final user = state.users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: NetworkImage(user.avatarUrl),
                child: user.image == null ? Text(user.firstName[0]) : null,
              ),
              title: Text(
                user.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    onPressed: () => UserFormDialog.show(context, user: user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(user.id),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => UserDetailScreen(userId: user.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
