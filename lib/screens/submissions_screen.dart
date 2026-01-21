import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class SubmissionsScreen extends ConsumerStatefulWidget {
  const SubmissionsScreen({super.key});

  @override
  ConsumerState<SubmissionsScreen> createState() => _SubmissionsScreenState();
}

class _SubmissionsScreenState extends ConsumerState<SubmissionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.invalidate(submissionsProvider);
      }
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  Color _getStatusColor(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.uploaded:
        return Colors.green;
      case SubmissionStatus.uploading:
        return Colors.blue;
      case SubmissionStatus.failed:
        return Colors.red;
      case SubmissionStatus.queued:
        return Colors.orange;
      case SubmissionStatus.draft:
        return Colors.grey;
    }
  }

  String _getStatusText(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.uploaded:
        return 'Uploaded';
      case SubmissionStatus.uploading:
        return 'Uploading';
      case SubmissionStatus.failed:
        return 'Failed';
      case SubmissionStatus.queued:
        return 'Queued';
      case SubmissionStatus.draft:
        return 'Draft';
    }
  }

  String _getTypeText(SubmissionType type) {
    switch (type) {
      case SubmissionType.autoVerified:
        return 'Auto Verified';
      case SubmissionType.manual:
        return 'Manual';
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync = ref.watch(submissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(submissionsProvider);
            },
          ),
        ],
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No submissions yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final sortedSubmissions = List<Submission>.from(submissions)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(submissionsProvider);
            },
            child: ListView.builder(
              itemCount: sortedSubmissions.length,
              itemBuilder: (context, index) {
                final submission = sortedSubmissions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(submission.status),
                      child: Icon(
                        submission.status == SubmissionStatus.uploaded
                            ? Icons.check
                            : submission.status == SubmissionStatus.failed
                                ? Icons.error
                                : Icons.pending,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      _getTypeText(submission.type),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(submission.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(submission.status)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(submission.status),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getStatusColor(submission.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (submission.metadata != null && 
                                submission.metadata!.containsKey('model')) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.model_training,
                                      size: 12,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      submission.metadata!['model'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (submission.labels.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Wrap(
                                spacing: 4,
                                children: submission.labels
                                    .take(3)
                                    .map(
                                      (label) => Chip(
                                        label: Text(
                                          label,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (submission.transcriptDraft != null &&
                                submission.transcriptDraft !=
                                    submission.transcriptFinal) ...[
                              const Text(
                                'Draft Transcript:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                submission.transcriptDraft!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            const Text(
                              'Final Transcript:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              submission.transcriptFinal,
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (submission.labels.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Labels:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: submission.labels
                                    .map(
                                      (label) => Chip(
                                        label: Text(label),
                                        padding: EdgeInsets.zero,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                            if (submission.submittedAt != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Submitted: ${_formatDate(submission.submittedAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            if (submission.metadata != null && 
                                submission.metadata!.containsKey('model')) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.model_training,
                                    size: 16,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Model: ${submission.metadata!['model']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (submission.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red[700],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        submission.errorMessage!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading submissions',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(submissionsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
