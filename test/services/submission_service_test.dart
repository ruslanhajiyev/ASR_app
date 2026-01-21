import 'package:asr_app/models/models.dart';
import 'package:asr_app/services/auth_service.dart';
import 'package:asr_app/services/mock_backend_service.dart';
import 'package:asr_app/services/submission_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([MockBackendService, AuthService])
import 'submission_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SubmissionService', () {
    late SubmissionService submissionService;
    late MockMockBackendService mockBackend;
    late MockAuthService mockAuth;

    setUp(() {
      mockBackend = MockMockBackendService();
      mockAuth = MockAuthService();
      submissionService = SubmissionService(
        backend: mockBackend,
        authService: mockAuth,
      );
    });

    test('should create submission successfully', () async {
      when(mockAuth.getUserId()).thenAnswer((_) async => 'user-123');

      final mockSubmission = Submission(
        id: 'sub-123',
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test transcript',
        labels: ['test'],
        createdAt: DateTime.now(),
        metadata: {'key': 'value'},
      );

      when(mockBackend.createSubmission(
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test transcript',
        transcriptDraft: null,
        labels: ['test'],
        audioPath: null,
        metadata: anyNamed('metadata'),
      )).thenAnswer((_) async => mockSubmission);

      final result = await submissionService.createSubmission(
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test transcript',
        labels: ['test'],
      );

      expect(result.id, 'sub-123');
      expect(result.userId, 'user-123');
      expect(result.transcriptFinal, 'Test transcript');
      verify(mockBackend.createSubmission(
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test transcript',
        transcriptDraft: null,
        labels: ['test'],
        audioPath: null,
        metadata: anyNamed('metadata'),
      )).called(1);
    });

    test('should throw exception when user not authenticated', () async {
      when(mockAuth.getUserId()).thenAnswer((_) async => null);

      expect(
        () => submissionService.createSubmission(
          type: SubmissionType.autoVerified,
          transcriptFinal: 'Test',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should include timing metadata in submission', () async {
      when(mockAuth.getUserId()).thenAnswer((_) async => 'user-123');

      final mockSubmission = Submission(
        id: 'sub-123',
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test',
        labels: [],
        createdAt: DateTime.now(),
      );

      when(mockBackend.createSubmission(
        userId: anyNamed('userId'),
        type: anyNamed('type'),
        transcriptFinal: anyNamed('transcriptFinal'),
        transcriptDraft: anyNamed('transcriptDraft'),
        labels: anyNamed('labels'),
        audioPath: anyNamed('audioPath'),
        metadata: anyNamed('metadata'),
      )).thenAnswer((_) async => mockSubmission);

      await submissionService.createSubmission(
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test',
        recordingDuration: const Duration(seconds: 10),
        asrDuration: const Duration(seconds: 5),
        editDuration: const Duration(seconds: 2),
      );

      final captured = verify(mockBackend.createSubmission(
        userId: anyNamed('userId'),
        type: anyNamed('type'),
        transcriptFinal: anyNamed('transcriptFinal'),
        transcriptDraft: anyNamed('transcriptDraft'),
        labels: anyNamed('labels'),
        audioPath: anyNamed('audioPath'),
        metadata: captureAnyNamed('metadata'),
      )).captured.first as Map<String, dynamic>;

      expect(captured['timings'], isNotNull);
      expect(captured['timings']['recordingDurationSeconds'], 10);
      expect(captured['timings']['asrDurationSeconds'], 5);
      expect(captured['timings']['editDurationSeconds'], 2);
    });

    test('should include client info in metadata', () async {
      when(mockAuth.getUserId()).thenAnswer((_) async => 'user-123');

      final mockSubmission = Submission(
        id: 'sub-123',
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test',
        labels: [],
        createdAt: DateTime.now(),
      );

      when(mockBackend.createSubmission(
        userId: anyNamed('userId'),
        type: anyNamed('type'),
        transcriptFinal: anyNamed('transcriptFinal'),
        transcriptDraft: anyNamed('transcriptDraft'),
        labels: anyNamed('labels'),
        audioPath: anyNamed('audioPath'),
        metadata: anyNamed('metadata'),
      )).thenAnswer((_) async => mockSubmission);

      await submissionService.createSubmission(
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test',
      );

      final captured = verify(mockBackend.createSubmission(
        userId: anyNamed('userId'),
        type: anyNamed('type'),
        transcriptFinal: anyNamed('transcriptFinal'),
        transcriptDraft: anyNamed('transcriptDraft'),
        labels: anyNamed('labels'),
        audioPath: anyNamed('audioPath'),
        metadata: captureAnyNamed('metadata'),
      )).captured.first as Map<String, dynamic>;

      expect(captured['logs'], isNotNull);
      expect(captured['sessionId'], isNotNull);
    });

    test('should upload submission successfully', () async {
      when(mockAuth.getToken()).thenAnswer((_) async => 'token-123');

      final submission = Submission(
        id: 'sub-123',
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test',
        labels: [],
        createdAt: DateTime.now(),
        status: SubmissionStatus.queued,
      );

      final uploadingSubmission =
          submission.copyWith(status: SubmissionStatus.uploading);
      final uploadedSubmission =
          submission.copyWith(status: SubmissionStatus.uploaded);

      when(mockBackend.updateSubmissionStatus(
        'sub-123',
        SubmissionStatus.uploading,
      )).thenAnswer((_) async => uploadingSubmission);

      when(mockBackend.updateSubmissionStatus(
        'sub-123',
        SubmissionStatus.uploaded,
      )).thenAnswer((_) async => uploadedSubmission);

      await submissionService.uploadSubmission(submission);

      verify(mockBackend.updateSubmissionStatus(
        'sub-123',
        SubmissionStatus.uploading,
      )).called(1);
      verify(mockBackend.updateSubmissionStatus(
        'sub-123',
        SubmissionStatus.uploaded,
      )).called(1);
    });

    test('should throw exception when not authenticated during upload',
        () async {
      when(mockAuth.getToken()).thenAnswer((_) async => null);

      final submission = Submission(
        id: 'sub-123',
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test',
        labels: [],
        createdAt: DateTime.now(),
      );

      expect(
        () => submissionService.uploadSubmission(submission),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle upload failure', () async {
      when(mockAuth.getToken()).thenAnswer((_) async => 'token-123');

      final submission = Submission(
        id: 'sub-123',
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test',
        labels: [],
        createdAt: DateTime.now(),
        status: SubmissionStatus.queued,
      );

      final uploadingSubmission =
          submission.copyWith(status: SubmissionStatus.uploading);
      final failedSubmission =
          submission.copyWith(status: SubmissionStatus.failed);

      when(mockBackend.updateSubmissionStatus(
        'sub-123',
        SubmissionStatus.uploading,
      )).thenAnswer((_) async => uploadingSubmission);

      when(mockBackend.updateSubmissionStatus(
        'sub-123',
        SubmissionStatus.uploaded,
      )).thenThrow(Exception('Upload failed'));

      when(mockBackend.updateSubmissionStatus(
        'sub-123',
        SubmissionStatus.failed,
        errorMessage: anyNamed('errorMessage'),
      )).thenAnswer((_) async => failedSubmission);

      try {
        await submissionService.uploadSubmission(submission);
        fail('Expected exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      verify(mockBackend.updateSubmissionStatus(
        'sub-123',
        SubmissionStatus.failed,
        errorMessage: anyNamed('errorMessage'),
      )).called(1);
    });
  });
}
