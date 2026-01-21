import 'package:flutter_test/flutter_test.dart';
import 'package:asr_app/models/submission.dart';

void main() {
  group('Submission Model', () {
    test('should create a submission with all fields', () {
      final submission = Submission(
        id: 'test-id',
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        audioPath: '/path/to/audio.wav',
        transcriptFinal: 'Hello world',
        transcriptDraft: 'Hello',
        labels: ['test', 'demo'],
        status: SubmissionStatus.draft,
        createdAt: DateTime(2024, 1, 1),
        metadata: {'key': 'value'},
      );

      expect(submission.id, 'test-id');
      expect(submission.userId, 'user-123');
      expect(submission.type, SubmissionType.autoVerified);
      expect(submission.audioPath, '/path/to/audio.wav');
      expect(submission.transcriptFinal, 'Hello world');
      expect(submission.transcriptDraft, 'Hello');
      expect(submission.labels, ['test', 'demo']);
      expect(submission.status, SubmissionStatus.draft);
      expect(submission.metadata, {'key': 'value'});
    });

    test('should serialize to JSON correctly', () {
      final submission = Submission(
        id: 'test-id',
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Hello world',
        labels: [],
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        submittedAt: DateTime(2024, 1, 1, 12, 5, 0),
        metadata: {'key': 'value'},
      );

      final json = submission.toJson();

      expect(json['id'], 'test-id');
      expect(json['userId'], 'user-123');
      expect(json['type'], 'autoVerified');
      expect(json['transcriptFinal'], 'Hello world');
      expect(json['status'], 'draft');
      expect(json['metadata'], {'key': 'value'});
      expect(json['createdAt'], '2024-01-01T12:00:00.000');
      expect(json['submittedAt'], '2024-01-01T12:05:00.000');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'userId': 'user-123',
        'type': 'autoVerified',
        'audioPath': '/path/to/audio.wav',
        'transcriptFinal': 'Hello world',
        'transcriptDraft': 'Hello',
        'labels': ['test', 'demo'],
        'status': 'draft',
        'createdAt': '2024-01-01T12:00:00.000',
        'submittedAt': '2024-01-01T12:05:00.000',
        'metadata': {'key': 'value'},
      };

      final submission = Submission.fromJson(json);

      expect(submission.id, 'test-id');
      expect(submission.userId, 'user-123');
      expect(submission.type, SubmissionType.autoVerified);
      expect(submission.audioPath, '/path/to/audio.wav');
      expect(submission.transcriptFinal, 'Hello world');
      expect(submission.transcriptDraft, 'Hello');
      expect(submission.labels, ['test', 'demo']);
      expect(submission.status, SubmissionStatus.draft);
      expect(submission.metadata, {'key': 'value'});
    });

    test('should handle manual submission type', () {
      final submission = Submission(
        id: 'test-id',
        userId: 'user-123',
        type: SubmissionType.manual,
        transcriptFinal: 'Manual transcript',
        labels: [],
        createdAt: DateTime(2024, 1, 1),
      );

      expect(submission.type, SubmissionType.manual);
      expect(submission.toJson()['type'], 'manual');
    });

    test('should handle copyWith correctly', () {
      final original = Submission(
        id: 'test-id',
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Original',
        labels: [],
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(
        transcriptFinal: 'Updated',
        status: SubmissionStatus.uploaded,
      );

      expect(updated.id, original.id);
      expect(updated.userId, original.userId);
      expect(updated.transcriptFinal, 'Updated');
      expect(updated.status, SubmissionStatus.uploaded);
      expect(original.transcriptFinal, 'Original'); 
    });

    test('should handle optional fields', () {
      final submission = Submission(
        id: 'test-id',
        userId: 'user-123',
        type: SubmissionType.autoVerified,
        transcriptFinal: 'Test',
        labels: [],
        createdAt: DateTime(2024, 1, 1),
      );

      expect(submission.audioPath, isNull);
      expect(submission.transcriptDraft, isNull);
      expect(submission.submittedAt, isNull);
      expect(submission.metadata, isNull);
      expect(submission.errorMessage, isNull);
    });
  });
}
