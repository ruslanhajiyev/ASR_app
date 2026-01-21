import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'auth_provider.dart';

final submissionServiceProvider = Provider<SubmissionService>((ref) {
  return SubmissionService(
    authService: ref.read(authServiceProvider),
  );
});

final submissionsProvider =
    FutureProvider<List<Submission>>((ref) async {
  final service = ref.read(submissionServiceProvider);
  return await service.getSubmissions();
});

final pendingSubmissionsProvider =
    FutureProvider<List<Submission>>((ref) async {
  final service = ref.read(submissionServiceProvider);
  return await service.getPendingSubmissions();
});

final submissionStateProvider =
    StateNotifierProvider<SubmissionNotifier, AsyncValue<Submission?>>(
  (ref) {
    return SubmissionNotifier(ref.read(submissionServiceProvider));
  },
);

class SubmissionNotifier extends StateNotifier<AsyncValue<Submission?>> {
  final SubmissionService _service;

  SubmissionNotifier(this._service) : super(const AsyncValue.data(null));

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
    state = const AsyncValue.loading();
    try {
      final submission = await _service.createSubmission(
        type: type,
        transcriptFinal: transcriptFinal,
        transcriptDraft: transcriptDraft,
        labels: labels,
        audioPath: audioPath,
        recordingStartTime: recordingStartTime,
        recordingDuration: recordingDuration,
        asrDuration: asrDuration,
        editDuration: editDuration,
        metadata: metadata,
      );
      state = AsyncValue.data(submission);
      return submission;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> uploadSubmission(Submission submission) async {
    try {
      await _service.uploadSubmission(submission);
      state = AsyncValue.data(submission);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> retryFailedUploads() async {
    await _service.retryFailedUploads();
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

