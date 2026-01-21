import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../services/audio_recording_service.dart';
import '../services/model_management_service.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as date_utils;
import '../utils/error_handler.dart';
import '../utils/validation_utils.dart';

class AutoTranscribeScreen extends ConsumerStatefulWidget {
  const AutoTranscribeScreen({super.key});

  @override
  ConsumerState<AutoTranscribeScreen> createState() =>
      _AutoTranscribeScreenState();
}

class _AutoTranscribeScreenState extends ConsumerState<AutoTranscribeScreen> {
  final _transcriptController = TextEditingController();
  final _labelsController = TextEditingController();
  String? _audioPath;
  String? _draftTranscript;
  bool _isVerified = false;
  String? _modelUsed; 
  

  DateTime? _recordingStartTime;
  DateTime? _transcriptionStartTime;
  DateTime? _editStartTime;
  Duration? _asrDuration;

  @override
  void dispose() {
    _transcriptController.dispose();
    _labelsController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final asrState = ref.read(asrStateProvider);
    if (asrState.isLoading) {
      ErrorHandler.showInfo(
        context,
        'Please wait for transcription engine to initialize',
      );
      return;
    }

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
      final path =
          await ref.read(recordingStateProvider.notifier).stopRecording();
      if (path != null) {
        setState(() {
          _audioPath = path;
        });
        await _transcribe();
      }
    } catch (e) {
      ErrorHandler.showError(context, 'Stop recording failed: $e');
    }
  }

  Future<void> _transcribe() async {
    if (_audioPath == null) return;

    try {
      final file = File(_audioPath!);
      if (!await file.exists()) {
        ErrorHandler.showError(
          context,
          'Audio file not found. Please record again.',
        );
        return;
      }
    } catch (e) {
      ErrorHandler.showError(context, 'Error checking audio file: $e');
      return;
    }

    try {
      ErrorHandler.showInfo(context, 'Initializing transcription...');

      final asrNotifier = ref.read(asrStateProvider.notifier);

      try {
        await asrNotifier.initialize();
      } catch (initError) {
        ErrorHandler.showError(context, 'Initialization failed: $initError');
        return;
      }

      await Future.delayed(AppConstants.shortDelay);

      final file = File(_audioPath!);
      if (!await file.exists()) {
        ErrorHandler.showError(
          context,
          'Audio file was deleted. Please record again.',
        );
        return;
      }

      _transcriptionStartTime = DateTime.now();
      await asrNotifier.transcribe(_audioPath!);
      _asrDuration = DateTime.now().difference(_transcriptionStartTime!);

      final result = ref.read(asrStateProvider);
      result.whenData((transcription) {
        if (transcription != null && mounted) {
          String? modelName;
          if (transcription.metadata != null && transcription.metadata!.containsKey('model')) {
            final modelStr = transcription.metadata!['model'].toString();
            final modelService = ModelManagementService();
            if (modelStr.contains('tiny')) {
              modelName = modelService.getModelInfoByName('Tiny')?.name ?? 'Tiny';
            } else if (modelStr.contains('base')) {
              modelName = modelService.getModelInfoByName('Base')?.name ?? 'Base';
            } else if (modelStr.contains('small')) {
              modelName = modelService.getModelInfoByName('Small')?.name ?? 'Small';
            } else if (modelStr.contains('medium')) {
              modelName = modelService.getModelInfoByName('Medium')?.name ?? 'Medium';
            } else if (modelStr.contains('large')) {
              modelName = modelService.getModelInfoByName('Large')?.name ?? 'Large';
            }
          }
          
          setState(() {
            _draftTranscript = transcription.text;
            _transcriptController.text = transcription.text;
            _editStartTime = DateTime.now();
            _modelUsed = modelName;
          });
        }
      });
    } catch (e) {
      ErrorHandler.showError(context, 'Transcription failed: $e');
    }
  }

  Future<void> _submit() async {
    if (_transcriptController.text.trim().isEmpty) {
      ErrorHandler.showInfo(context, 'Please enter or edit the transcription');
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

      final submission =
          await ref.read(submissionStateProvider.notifier).createSubmission(
        type: SubmissionType.autoVerified,
        transcriptFinal: _transcriptController.text.trim(),
        transcriptDraft: _draftTranscript,
        labels: labels,
        audioPath: _audioPath,
        recordingStartTime: _recordingStartTime,
        recordingDuration: recordingDuration,
        asrDuration: _asrDuration,
        editDuration: editDuration,
        metadata: {
          'verified': _isVerified,
          if (_modelUsed != null) 'model': _modelUsed,
        },
      );

      await ref
          .read(submissionStateProvider.notifier)
          .uploadSubmission(submission);

      await Future.delayed(AppConstants.defaultDelay);

      ref.invalidate(submissionsProvider);
      ref.invalidate(pendingSubmissionsProvider);

      if (mounted) {
        setState(() {
          _transcriptController.clear();
          _labelsController.clear();
          _isVerified = false;
          _audioPath = null;
          _draftTranscript = null;
          _modelUsed = null;
          _recordingStartTime = null;
          _transcriptionStartTime = null;
          _editStartTime = null;
          _asrDuration = null;
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
    final asrState = ref.watch(asrStateProvider);
    final recordingDurationAsync = ref.watch(recordingDurationProvider);
    final recordingDuration = recordingDurationAsync.value ?? Duration.zero;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Transcription'),
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
                            onPressed: asrState.isLoading ? null : _startRecording,
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
                    if (asrState.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Initializing transcription...',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Transcription result
            if (asrState.isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            if (asrState.hasValue && asrState.value != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transcription',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _draftTranscript ?? '',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
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
                labelText: 'Edit Transcription',
                hintText: 'Edit the transcription as needed',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Verified'),
              value: _isVerified,
              onChanged: (value) {
                setState(() {
                  _isVerified = value ?? false;
                });
              },
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
