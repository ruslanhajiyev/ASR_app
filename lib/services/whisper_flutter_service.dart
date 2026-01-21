import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';
import '../models/transcription_result.dart';
import '../services/logging_service.dart';
import '../utils/constants.dart';


class WhisperFlutterService {
  Whisper? _whisper;
  bool _initialized = false;
  WhisperModel _model = WhisperModel.tiny;
  final LoggingService _logger = LoggingService(); 

  Future<void> init({
    String? modelPath,
    WhisperModel? model,
    String language = 'en',
    Map<String, dynamic>? options,
  }) async {
    if (_initialized && _whisper != null) {
      try {
        await _whisper!.getVersion();
        if (model != null && _model != model) {
          debugPrint('Model changed, reinitializing...');
          _whisper = null;
          _initialized = false;
        } else {
          return;
        }
      } catch (e) {
        _logger.warn(
          category: AppConstants.logCategoryAsr,
          message: 'Whisper instance invalid, reinitializing',
          metadata: {'error': e.toString()},
        ).catchError((err) => debugPrint('Logging error: $err'));
        _whisper = null;
        _initialized = false;
      }
    }

    try {
      if (model != null) {
        _model = model;
      } else if (modelPath != null && modelPath != 'auto') {
        final fileName = modelPath.split('/').last.toLowerCase();
        if (fileName.contains('tiny')) {
          _model = WhisperModel.tiny;
        } else if (fileName.contains('base')) {
          _model = WhisperModel.base;
        } else if (fileName.contains('small')) {
          _model = WhisperModel.small;
        } else if (fileName.contains('medium')) {
          _model = WhisperModel.medium;
        } else if (fileName.contains('large')) {
          _model = WhisperModel.largeV1;
        }
      }

     
      final Whisper newWhisper;
      try {
        newWhisper = Whisper(
        model: _model,
        downloadHost:
            "https://huggingface.co/ggerganov/whisper.cpp/resolve/main",
      );
      } catch (e) {
        _logger.error(
          category: AppConstants.logCategoryAsr,
          message: 'Failed to create Whisper instance',
          error: e,
        ).catchError((err) => debugPrint('Logging error: $err'));
        throw Exception('Failed to create Whisper native instance. This may be due to missing native libraries or insufficient permissions. Error: $e');
      }

      _whisper = newWhisper;
      
    
      await Future.delayed(const Duration(milliseconds: 100));

      try {
        final version = await _whisper!.getVersion();
        print('Whisper version: $version');
        _initialized = true;
        print(
          'WhisperFlutterService initialized successfully with model: $_model',
        );
      } catch (e) {
        print('Could not verify whisper initialization: $e');
        _initialized = true;
        print(
          'WhisperFlutterService initialized (version check failed) with model: $_model',
        );
      }
    } catch (e, stackTrace) {
      print('Whisper initialization error: $e');
      print('Stack trace: $stackTrace');
      _whisper = null;
      _initialized = false;
      throw Exception('Failed to initialize whisper.cpp: $e');
    }
  }

  Future<TranscriptionResult> transcribe(String audioPath) async {
    if (!_initialized || _whisper == null) {
      throw Exception('Whisper service not initialized. Call init() first.');
    }

    final file = File(audioPath);
    if (!await file.exists()) {
      throw Exception('Audio file not found: $audioPath');
    }

    final fileSize = await file.length();
    if (fileSize == 0) {
      throw Exception('Audio file is empty: $audioPath');
    }

    try {
      await file.readAsBytes();
    } catch (e) {
      throw Exception('Cannot read audio file: $audioPath. Error: $e');
    }

    try {
      print('Starting transcription with whisper_flutter_new...');
      print('Audio file: $audioPath');
      print('File size: $fileSize bytes');
      print('Model: $_model');

      if (_whisper == null) {
        throw Exception('Whisper instance is null');
      }

      final transcription = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false, 
          isNoTimestamps: true, 
          splitOnWord: false, 
        ),
      );

      if (transcription.text.isEmpty) {
        throw Exception('Transcription returned empty result');
      }

      print('Transcription completed successfully');
      print(
        'Result: ${transcription.text.substring(0, transcription.text.length > 100 ? 100 : transcription.text.length)}...',
      );

      return TranscriptionResult(
        text: transcription.text.trim(),
        confidence: 0.85,
        duration: null,
        metadata: {
          'model': _model.toString(),
          'language': 'en',
          'package': 'whisper_flutter_new',
        },
      );
    } catch (e, stackTrace) {
      print('Transcription error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Transcription failed: $e');
    }
  }

  Future<void> dispose() async {
    _whisper = null;
    _initialized = false;
  }

  bool get isInitialized => _initialized;
  String? get modelPath => _model.toString();
}
