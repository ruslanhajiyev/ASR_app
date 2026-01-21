enum SubmissionType {
  autoVerified,
  manual,
}

enum SubmissionStatus {
  draft,
  queued,
  uploading,
  uploaded,
  failed,
}

class Submission {
  final String id;
  final String userId;
  final SubmissionType type;
  final String? audioPath;
  final String transcriptFinal;
  final String? transcriptDraft;
  final List<String> labels;
  final SubmissionStatus status;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final Map<String, dynamic>? metadata;
  final String? errorMessage;

  Submission({
    required this.id,
    required this.userId,
    required this.type,
    this.audioPath,
    required this.transcriptFinal,
    this.transcriptDraft,
    required this.labels,
    this.status = SubmissionStatus.draft,
    required this.createdAt,
    this.submittedAt,
    this.metadata,
    this.errorMessage,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: SubmissionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      audioPath: json['audioPath'] as String?,
      transcriptFinal: json['transcriptFinal'] as String,
      transcriptDraft: json['transcriptDraft'] as String?,
      labels: List<String>.from(json['labels'] as List),
      status: SubmissionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SubmissionStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'audioPath': audioPath,
      'transcriptFinal': transcriptFinal,
      'transcriptDraft': transcriptDraft,
      'labels': labels,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'metadata': metadata,
      'errorMessage': errorMessage,
    };
  }

  Submission copyWith({
    String? id,
    String? userId,
    SubmissionType? type,
    String? audioPath,
    String? transcriptFinal,
    String? transcriptDraft,
    List<String>? labels,
    SubmissionStatus? status,
    DateTime? createdAt,
    DateTime? submittedAt,
    Map<String, dynamic>? metadata,
    String? errorMessage,
  }) {
    return Submission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      audioPath: audioPath ?? this.audioPath,
      transcriptFinal: transcriptFinal ?? this.transcriptFinal,
      transcriptDraft: transcriptDraft ?? this.transcriptDraft,
      labels: labels ?? this.labels,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      metadata: metadata ?? this.metadata,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

