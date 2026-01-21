class TranscriptionResult {
  final String text;
  final double? confidence;
  final Duration? duration;
  final Map<String, dynamic>? metadata;

  TranscriptionResult({
    required this.text,
    this.confidence,
    this.duration,
    this.metadata,
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      text: json['text'] as String,
      confidence: json['confidence'] as double?,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence': confidence,
      'duration': duration?.inMilliseconds,
      'metadata': metadata,
    };
  }
}

