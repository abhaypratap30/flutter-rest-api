import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rest_api/features/users/providers/user_provider.dart';
import 'package:flutter_rest_api/shared/widgets/error_view.dart';
import 'package:flutter_rest_api/shared/widgets/skeleton_loader.dart';

class UserDetailScreen extends ConsumerWidget {
  final int userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailProvider(userId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Detail (GET)'),
      ),
      body: userAsync.when(
        loading: () => const UserDetailSkeleton(),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(userDetailProvider(userId)),
        ),
        data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: NetworkImage(user.avatarUrl),
                    child: user.image == null
                        ? Text(
                            user.firstName[0],
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(user.role?.toUpperCase() ?? 'USER'),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  side: BorderSide.none,
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.email_outlined),
                          title: const Text('Email Address'),
                          subtitle: Text(user.email),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.badge_outlined),
                          title: const Text('User ID'),
                          subtitle: Text('#${user.id}'),
                        ),
                        if (user.gender != null) ...[
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: const Text('Gender'),
                            subtitle: Text(user.gender!.toUpperCase()),
                          ),
                        ],
                        if (user.phone != null) ...[
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.phone_outlined),
                            title: const Text('Phone Number'),
                            subtitle: Text(user.phone!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
