import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/models.dart';
import '../utils/constants.dart';
import 'mock_backend_service.dart';
import 'auth_service.dart';
import 'logging_service.dart';
import 'encryption_service.dart';

class SubmissionService {
  final MockBackendService _backend;
  final AuthService _authService;
  final LoggingService _logger = LoggingService();
  final EncryptionService _encryption = EncryptionService();

  SubmissionService({
    MockBackendService? backend,
    AuthService? authService,
  })  : _backend = backend ?? MockBackendService(),
        _authService = authService ?? AuthService();

  Future<Submission> createSubmission({
    required SubmissionType type,
    required String transcriptFinal,
    String? transcriptDraft,
    List<String>? labels,
    String? audioPath,
    Map<String, dynamic>? metadata,
    DateTime? recordingStartTime,
    Duration? recordingDuration,
    Duration? asrDuration,
    Duration? editDuration,
  }) async {
    final userId = await _authService.getUserId();
    if (userId == null) {
      await _logger.error(
        category: AppConstants.logCategorySubmission,
        message: 'Failed to create submission: user not authenticated',
      );
      throw Exception('User not authenticated');
    }

    final logBundle = await _logger.createLogBundle(
      recordingStartTime: recordingStartTime,
      submissionTime: DateTime.now(),
    );

    final enhancedMetadata = {
      ...?metadata,
      'client': logBundle['client'],
      'timings': {
        if (recordingDuration != null) 'recordingDurationSeconds': recordingDuration.inSeconds,
        if (asrDuration != null) 'asrDurationSeconds': asrDuration.inSeconds,
        if (editDuration != null) 'editDurationSeconds': editDuration.inSeconds,
      },
      'logs': logBundle['logs'],
      'sessionId': logBundle['sessionId'],
    };

    final submission = await _backend.createSubmission(
      userId: userId,
      type: type,
      transcriptFinal: transcriptFinal,
      transcriptDraft: transcriptDraft,
      labels: labels,
      audioPath: audioPath,
      metadata: enhancedMetadata,
    );

    await _logger.info(
      category: AppConstants.logCategorySubmission,
      message: 'Submission created',
      metadata: {
        'submissionId': submission.id,
        'type': type.toString(),
        'hasAudio': audioPath != null,
      },
    );

    await _addToQueue(submission);

    return submission;
  }

  Future<void> uploadSubmission(Submission submission) async {
    final token = await _authService.getToken();
    if (token == null) {
      await _logger.error(
        category: AppConstants.logCategorySubmission,
        message: 'Failed to upload submission: user not authenticated',
        metadata: {'submissionId': submission.id},
      );
      throw Exception('User not authenticated');
    }

    try {
      await _logger.info(
        category: AppConstants.logCategorySubmission,
        message: 'Starting upload',
        metadata: {'submissionId': submission.id},
      );

      await _backend.updateSubmissionStatus(
        submission.id,
        SubmissionStatus.uploading,
      );

      await Future.delayed(AppConstants.uploadSimulationDelay);

      await _backend.updateSubmissionStatus(
        submission.id,
        SubmissionStatus.uploaded,
      );

      await _logger.info(
        category: AppConstants.logCategorySubmission,
        message: 'Upload successful',
        metadata: {'submissionId': submission.id},
      );

      await _removeFromQueue(submission.id);
    } catch (e, stackTrace) {
      await _logger.error(
        category: AppConstants.logCategorySubmission,
        message: 'Upload failed',
        metadata: {'submissionId': submission.id},
        error: e,
        stackTrace: stackTrace,
      );

      await _backend.updateSubmissionStatus(
        submission.id,
        SubmissionStatus.failed,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<List<Submission>> getSubmissions() async {
    final token = await _authService.getToken();
    final userId = await _authService.getUserId();

    if (token == null || userId == null) {
      await _logger.warn(
        category: AppConstants.logCategorySubmission,
        message: 'getSubmissions: token or userId is null',
      );
      return [];
    }

    try {
      final submissions = await _backend.getSubmissions(userId, token);
      await _logger.info(
        category: AppConstants.logCategorySubmission,
        message: 'Retrieved submissions',
        metadata: {
          'count': submissions.length,
          'userId': userId,
        },
      );
      return submissions;
    } catch (e, stackTrace) {
      await _logger.error(
        category: AppConstants.logCategorySubmission,
        message: 'getSubmissions error',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<void> retryFailedUploads() async {
    final queue = await _getQueue();
    final failedSubmissions = queue.where(
      (s) => s.status == SubmissionStatus.failed ||
          s.status == SubmissionStatus.queued,
    );

    for (final submission in failedSubmissions) {
      try {
        await uploadSubmission(submission);
      } catch (e) {
        // Continue with next submission
      }
    }
  }

  Future<List<Submission>> getPendingSubmissions() async {
    return await _getQueue();
  }

  Future<void> _addToQueue(Submission submission) async {
    final queue = await _getQueue();
    queue.add(submission);
    await _saveQueue(queue);
  }

  Future<void> _removeFromQueue(String submissionId) async {
    final queue = await _getQueue();
    queue.removeWhere((s) => s.id == submissionId);
    await _saveQueue(queue);
  }

  Future<List<Submission>> _getQueue() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${AppConstants.submissionQueueFileName}');

      if (!await file.exists()) {
        return [];
      }

      final encryptedContent = await file.readAsString();
      
      final decryptedContent = await _encryption.decrypt(encryptedContent);
      
      final List<dynamic> jsonList = json.decode(decryptedContent);
      return jsonList
          .map((json) => Submission.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await _logger.warn(
        category: AppConstants.logCategorySubmission,
        message: 'Failed to load queue',
        metadata: {'error': e.toString()},
      );
      return [];
    }
  }

  Future<void> _saveQueue(List<Submission> queue) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${AppConstants.submissionQueueFileName}');
      final jsonList = queue.map((s) => s.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      final encryptedContent = await _encryption.encrypt(jsonString);
      await file.writeAsString(encryptedContent);
    } catch (e) {
      await _logger.error(
        category: AppConstants.logCategorySubmission,
        message: 'Failed to save queue',
        error: e,
      );
    }
  }

  Future<void> clearLocalData() async {
    try {
      final userId = await _authService.getUserId();
      final directory = await getApplicationDocumentsDirectory();
      
      final queueFile = File('${directory.path}/${AppConstants.submissionQueueFileName}');
      if (await queueFile.exists()) {
        await queueFile.delete();
      }
      
      if (userId != null) {
        await _backend.clearUserSubmissions(userId);
      }
      
      try {
        final files = directory.listSync();
        for (var file in files) {
          if (file is File && file.path.contains(AppConstants.audioFilePattern)) {
            await file.delete();
          }
        }
      } catch (e) {
        await _logger.warn(
          category: AppConstants.logCategorySubmission,
          message: 'Some audio files could not be deleted',
          metadata: {'error': e.toString()},
        );
      }
      
      await _logger.info(
        category: AppConstants.logCategorySubmission,
        message: 'Local submission data cleared',
        metadata: {'userId': userId},
      );
    } catch (e) {
      await _logger.error(
        category: AppConstants.logCategorySubmission,
        message: 'Failed to clear local data',
        error: e,
      );
      rethrow;
    }
  }
}

