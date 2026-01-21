import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../services/submission_service.dart';
import '../services/logging_service.dart';
import 'submissions_screen.dart';
import 'model_management_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final pendingSubmissions = ref.watch(pendingSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (authState.hasValue && authState.value != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('User'),
                subtitle: Text(authState.value!.username),
              ),
            ),
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.model_training),
              title: const Text('Model Management'),
              subtitle: const Text('Select and manage Whisper models'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ModelManagementScreen(),
                  ),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.list),
              title: const Text('View Submissions'),
              subtitle: const Text('View all submitted transcriptions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubmissionsScreen(),
                  ),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.queue),
              title: const Text('Pending Submissions'),
              subtitle: pendingSubmissions.when(
                data: (submissions) => Text('${submissions.length} pending'),
                loading: () => const Text('Loading...'),
                error: (_, __) => const Text('Error'),
              ),
              trailing: pendingSubmissions.when(
                data: (submissions) => submissions.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          ref
                              .read(submissionStateProvider.notifier)
                              .retryFailedUploads();
                        },
                      )
                    : null,
                loading: () => null,
                error: (_, __) => null,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Device Info'),
              subtitle: Text('Platform: ${Platform.operatingSystem}'),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.orange),
              title: const Text(
                'Clear Local Data',
                style: TextStyle(color: Colors.orange),
              ),
              subtitle: const Text('Delete all local submissions and logs'),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Local Data'),
                    content: const Text(
                      'This will delete all local submissions, logs, and cached data. '
                      'This action cannot be undone. Continue?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  try {
                    final submissionService = SubmissionService();
                    final loggingService = LoggingService();

                    await submissionService.clearLocalData();
                    
                    await loggingService.clearLogs();

                    ref.invalidate(submissionsProvider);
                    ref.invalidate(pendingSubmissionsProvider);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Local data cleared successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to clear data: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
