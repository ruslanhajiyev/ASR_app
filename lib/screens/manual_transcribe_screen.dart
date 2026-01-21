import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/audio_recording_service.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as date_utils;
import '../utils/error_handler.dart';
import '../utils/validation_utils.dart';

class ManualTranscribeScreen extends ConsumerStatefulWidget {
  const ManualTranscribeScreen({super.key});

  @override
  ConsumerState<ManualTranscribeScreen> createState() =>
      _ManualTranscribeScreenState();
}

class _ManualTranscribeScreenState extends ConsumerState<ManualTranscribeScreen> {
  final _transcriptController = TextEditingController();
  final _labelsController = TextEditingController();
  String? _audioPath;
  
  DateTime? _recordingStartTime;
  DateTime? _editStartTime;

  @override
  void dispose() {
    _transcriptController.dispose();
    _labelsController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      _recordingStartTime = DateTime.now();
      await ref.read(recordingStateProvider.notifier).startRecording();
    } catch (e) {
      _recordingStartTime = null;
      ErrorHandler.showError(context, 'Recording failed: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await ref.read(recordingStateProvider.notifier).stopRecording();
      if (path != null) {
        setState(() {
          _audioPath = path;
          _editStartTime = DateTime.now();
        });
      }
    } catch (e) {
      ErrorHandler.showError(context, 'Stop recording failed: $e');
    }
  }

  Future<void> _submit() async {
    if (_transcriptController.text.trim().isEmpty) {
      ErrorHandler.showInfo(context, 'Please enter the transcription');
      return;
    }

    if (_audioPath == null) {
      ErrorHandler.showInfo(context, 'Please record audio first');
      return;
    }

    try {
      final labels = ValidationUtils.parseLabels(_labelsController.text);

      final recordingDuration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!)
          : null;
      final editDuration = _editStartTime != null
          ? DateTime.now().difference(_editStartTime!)
          : null;

      final submission = await ref.read(submissionStateProvider.notifier)
          .createSubmission(
            type: SubmissionType.manual,
            transcriptFinal: _transcriptController.text.trim(),
            labels: labels,
            audioPath: _audioPath,
            recordingStartTime: _recordingStartTime,
            recordingDuration: recordingDuration,
            editDuration: editDuration,
          );

      await ref.read(submissionStateProvider.notifier)
          .uploadSubmission(submission);

      await Future.delayed(AppConstants.defaultDelay);

      ref.invalidate(submissionsProvider);
      ref.invalidate(pendingSubmissionsProvider);

      if (mounted) {
        setState(() {
          _transcriptController.clear();
          _labelsController.clear();
          _audioPath = null;
          _recordingStartTime = null;
          _editStartTime = null;
        });

        ErrorHandler.showSuccess(context, 'Submission successful!');
      }
    } catch (e) {
      ErrorHandler.showError(context, 'Submission failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingStateProvider);
    final recordingDurationAsync = ref.watch(recordingDurationProvider);
    final recordingDuration = recordingDurationAsync.value ?? Duration.zero;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Transcription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (recordingState == RecordingState.recording)
                      Column(
                        children: [
                          const Icon(
                            Icons.mic,
                            size: AppConstants.iconSize,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            date_utils.DateUtils.formatDuration(recordingDuration),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      )
                    else
                      const Icon(
                        Icons.mic_none,
                        size: AppConstants.iconSize,
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (recordingState == RecordingState.idle ||
                            recordingState == RecordingState.stopped)
                          ElevatedButton.icon(
                            onPressed: _startRecording,
                            icon: const Icon(Icons.fiber_manual_record),
                            label: const Text('Record'),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: _stopRecording,
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                      ],
                    ),
                    if (_audioPath != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Recording saved',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _transcriptController,
              decoration: const InputDecoration(
                labelText: 'Transcription',
                hintText: 'Type the transcription here',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelsController,
              decoration: const InputDecoration(
                labelText: 'Labels (comma-separated)',
                hintText: 'e.g., meeting, important, follow-up',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

}

