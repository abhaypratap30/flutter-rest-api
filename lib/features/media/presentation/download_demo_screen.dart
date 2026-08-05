import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rest_api/features/media/providers/file_provider.dart';
import 'package:flutter_rest_api/shared/widgets/custom_button.dart';

class DownloadDemoScreen extends ConsumerWidget {
  const DownloadDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadNotifierProvider);
    final notifier = ref.read(downloadNotifierProvider.notifier);
    final theme = Theme.of(context);

    const demoUrl = 'https://dummyjson.com/users';

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Download Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.cloud_download_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'File Download Stream',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Demonstrates downloading remote payloads directly to local storage with real-time byte tracking.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (state.isTransferring) ...[
                      LinearProgressIndicator(
                        value: state.progress > 0 ? state.progress : null,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Downloading... ${(state.progress * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Cancel Download',
                        isOutlined: true,
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        onPressed: () => notifier.cancel(),
                      ),
                    ] else ...[
                      CustomButton(
                        text: 'Start Download Demo',
                        icon: Icons.download_rounded,
                        onPressed: () => notifier.startDownload(demoUrl, 'sample_dataset.json'),
                      ),
                    ],
                    if (state.isSuccess && state.resultPath != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Download Complete!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              'Saved to:\n${state.resultPath}',
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
