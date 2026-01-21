import 'package:flutter/services.dart';
import '../models/transcription_result.dart';

class WhisperPlatformService {
  static const MethodChannel _channel = MethodChannel('asr_app/whisper');

  Future<bool> init({
    required String modelPath,
    String language = 'en',
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'init',
        {
          'modelPath': modelPath,
          'language': language,
        },
      );
      return result ?? false;
    } catch (e) {
      throw Exception('Failed to initialize ASR: $e');
    }
  }

  Future<TranscriptionResult> transcribe(String audioPath) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'transcribe',
        {'audioPath': audioPath},
      );
      
      if (result == null) {
        throw Exception('Transcription returned null');
      }

      return TranscriptionResult(
        text: result['text'] as String,
        confidence: (result['confidence'] as num?)?.toDouble(),
        duration: result['duration'] != null
            ? Duration(milliseconds: result['duration'] as int)
            : null,
        metadata: result['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw Exception('Transcription failed: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
    } catch (e) {
      // Ignore dispose errors
    }
  }
}

