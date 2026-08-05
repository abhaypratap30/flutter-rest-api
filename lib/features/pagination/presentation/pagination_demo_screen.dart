import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rest_api/core/models/pagination_model.dart';
import 'package:flutter_rest_api/features/users/providers/user_provider.dart';

class PaginationDemoScreen extends ConsumerWidget {
  const PaginationDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userListProvider);
    final notifier = ref.read(userListProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination Strategies'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.numbers, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Pagination Type Switcher',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<PaginationType>(
                      segments: const [
                        ButtonSegment(
                          value: PaginationType.pageNumber,
                          label: Text('Page-Based (skip/limit)'),
                          icon: Icon(Icons.format_list_numbered),
                        ),
                        ButtonSegment(
                          value: PaginationType.cursor,
                          label: Text('Cursor-Based (opaque token)'),
                          icon: Icon(Icons.token_outlined),
                        ),
                      ],
                      selected: {state.params.type},
                      onSelectionChanged: (set) {
                        if (set.isNotEmpty) {
                          notifier.setPaginationType(set.first);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Pagination Meta',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildMetaRow('Current Mode', state.params.type.name.toUpperCase()),
                    _buildMetaRow('Current Page Number', '${state.params.page}'),
                    _buildMetaRow('Items Limit Per Request', '${state.params.limit}'),
                    _buildMetaRow('Offset (Skip calculated)', '${state.params.skip}'),
                    _buildMetaRow('Total Loaded Items Count', '${state.users.length}'),
                    _buildMetaRow('Total Server Records', '${state.totalCount}'),
                    _buildMetaRow('Has Next Page', state.hasNextPage ? 'YES' : 'NO'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.hasNextPage && !state.isFetchingMore
                        ? () => notifier.fetchNextPage()
                        : null,
                    icon: const Icon(Icons.arrow_downward),
                    label: state.isFetchingMore
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Load Next Page (Infinite Scroll)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }
}
