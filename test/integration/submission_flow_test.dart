import 'package:asr_app/models/models.dart';
import 'package:asr_app/services/auth_service.dart';
import 'package:asr_app/services/mock_backend_service.dart';
import 'package:asr_app/services/submission_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Submission Flow Integration Tests', () {
    late MockBackendService backend;
    late AuthService authService;
    late SubmissionService submissionService;

    setUp(() {
      backend = MockBackendService();
      authService = AuthService(backend: backend);
      submissionService = SubmissionService(
        backend: backend,
        authService: authService,
      );
    });

    test('should complete full flow: register -> create submission -> upload',
        () async {
      final registerResponse = await authService.register(
        username: 'testuser',
        password: 'Password123!',
        email: 'test@example.com',
      );

      expect(registerResponse.user.username, 'testuser');
      expect(await authService.isAuthenticated(), isTrue);

      final submission = await submissionService.createSubmission(
        type: SubmissionType.autoVerified,
        transcriptFinal: 'This is a test transcription',
        labels: ['test', 'integration'],
        metadata: {'source': 'test'},
        recordingDuration: const Duration(seconds: 5),
        asrDuration: const Duration(seconds: 2),
      );

      expect(submission.id, isNotEmpty);
      expect(submission.userId, registerResponse.user.id);
      expect(submission.transcriptFinal, 'This is a test transcription');
      expect(submission.labels, ['test', 'integration']);
      expect(submission.status, SubmissionStatus.draft);

      await submissionService.uploadSubmission(submission);

      final token = await authService.getToken();
      final submissions =
          await backend.getSubmissions(registerResponse.user.id, token!);
      expect(submissions.any((s) => s.id == submission.id), isTrue);
    });

    test('should handle offline queue: create submission without upload',
        () async {
      await authService.register(
        username: 'testuser2',
        password: 'Password123!',
        email: 'test2@example.com',
      );

      final submission = await submissionService.createSubmission(
        type: SubmissionType.manual,
        transcriptFinal: 'Offline submission',
        labels: ['offline'],
      );

      expect(submission.status, SubmissionStatus.draft);

      final pending = await submissionService.getPendingSubmissions();
      expect(pending.length, greaterThan(0));
      expect(pending.any((s) => s.id == submission.id), isTrue);
    });

    test('should retry failed uploads', () async {
      await authService.register(
        username: 'testuser3',
        password: 'Password123!',
        email: 'test3@example.com',
      );

      final submission = await submissionService.createSubmission(
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Retry test',
        labels: [],
      );

      try {
        await submissionService.uploadSubmission(submission);
      } catch (e) {
        // Expected to fail
      }

      await submissionService.retryFailedUploads();

      final userId = await authService.getUserId();
      final token = await authService.getToken();
      final submissions = await backend.getSubmissions(userId!, token!);
      expect(submissions.any((s) => s.id == submission.id), isTrue);
    });

    test('should include all metadata in submission', () async {
      await authService.register(
        username: 'testuser4',
        password: 'Password123!',
        email: 'test4@example.com',
      );

      final submission = await submissionService.createSubmission(
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Metadata test',
        labels: ['metadata'],
        recordingDuration: const Duration(seconds: 10),
        asrDuration: const Duration(seconds: 5),
        editDuration: const Duration(seconds: 3),
      );

      expect(submission.metadata, isNotNull);
      expect(submission.metadata!['timings'], isNotNull);
      expect(submission.metadata!['client'], isNotNull);
      expect(submission.metadata!['logs'], isNotNull);
      expect(submission.metadata!['sessionId'], isNotNull);
    });
  });
}
