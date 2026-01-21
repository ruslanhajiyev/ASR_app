import 'dart:io';
import '../models/transcription_result.dart';

class WhisperMockService {
  bool _initialized = false;

  Future<void> init({
    String? modelPath,
    String language = 'en',
    Map<String, dynamic>? options,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initialized = true;
    print('Mock Whisper service initialized');
  }

  Future<TranscriptionResult> transcribe(String audioPath) async {
    if (!_initialized) {
      throw Exception('Whisper service not initialized. Call init() first.');
    }

    final file = File(audioPath);
    if (!await file.exists()) {
      throw Exception('Audio file not found: $audioPath');
    }

    await Future.delayed(const Duration(seconds: 2));

    return TranscriptionResult(
      text: 'This is a mock transcription. Real whisper.cpp integration is temporarily disabled to prevent crashes.',
      confidence: 0.9,
      duration: null,
      metadata: {
        'model': 'mock',
        'language': 'en',
        'note': 'Using mock service',
      },
    );
  }

  Future<void> dispose() async {
    _initialized = false;
  }

  bool get isInitialized => _initialized;
  String? get modelPath => 'mock';
}

