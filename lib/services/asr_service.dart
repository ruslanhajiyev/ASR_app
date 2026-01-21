import 'dart:io';

import 'package:whisper_flutter_new/whisper_flutter_new.dart';

import '../models/transcription_result.dart';
import '../utils/constants.dart';
import 'logging_service.dart';
import 'whisper_flutter_service.dart';


class AsrService {
  final WhisperFlutterService _whisperService = WhisperFlutterService();
  final LoggingService _logger = LoggingService();
  bool _initialized = false;
  String? _modelPath;

  Future<void> init({
    String? modelPath,
    WhisperModel? model,
    String language = 'en',
    Map<String, dynamic>? options,
  }) async {
    final initStartTime = DateTime.now();

    try {
      _logger.info(
        category: AppConstants.logCategoryAsr,
        message: 'Initializing ASR engine',
        metadata: {
          'modelPath': modelPath ?? 'auto',
          'language': language,
        },
      ).catchError((e) => print('Logging error: $e'));

      await _whisperService.init(
        modelPath: modelPath,
        model: model,
        language: language,
        options: options,
      );

      _modelPath = modelPath ?? (model != null ? model.toString() : 'auto');
      _initialized = true;

      final initDuration = DateTime.now().difference(initStartTime);
      _logger.info(
        category: AppConstants.logCategoryAsr,
        message: 'ASR engine initialized',
        metadata: {
          'modelPath': _modelPath,
          'initDurationSeconds': initDuration.inSeconds,
        },
      ).catchError((e) => print('Logging error: $e'));
    } catch (e, stackTrace) {
      _logger
          .error(
            category: AppConstants.logCategoryAsr,
            message: 'ASR initialization failed',
            metadata: {
              'modelPath': modelPath ?? 'auto',
              'language': language,
            },
            error: e,
            stackTrace: stackTrace,
          )
          .catchError((err) => print('Logging error: $err'));
      rethrow;
    }
  }

  Future<TranscriptionResult> transcribeFile(String audioPath) async {
    if (!_initialized) {
      _logger
          .error(
            category: AppConstants.logCategoryAsr,
            message: 'ASR service not initialized',
          )
          .catchError((e) => print('Logging error: $e'));
      throw Exception('ASR service not initialized. Call init() first.');
    }

    final file = File(audioPath);
    if (!await file.exists()) {
      _logger.error(
        category: AppConstants.logCategoryAsr,
        message: 'Audio file not found',
        metadata: {'audioPath': audioPath},
      ).catchError((e) => print('Logging error: $e'));
      throw Exception('Audio file not found: $audioPath');
    }

    final transcriptionStartTime = DateTime.now();
    final fileSize = await file.length();

    try {
      _logger.info(
        category: AppConstants.logCategoryAsr,
        message: 'Starting transcription',
        metadata: {
          'audioPath': audioPath,
          'fileSizeBytes': fileSize,
          'modelPath': _modelPath,
        },
      ).catchError((e) => print('Logging error: $e'));

      final result = await _whisperService.transcribe(audioPath);

      final transcriptionDuration =
          DateTime.now().difference(transcriptionStartTime);

      _logger.info(
        category: AppConstants.logCategoryAsr,
        message: 'Transcription completed',
        metadata: {
          'audioPath': audioPath,
          'transcriptionDurationSeconds': transcriptionDuration.inSeconds,
          'modelPath': _modelPath,
          'resultLength': result.text.length,
          'confidence': result.confidence,
        },
      ).catchError((e) => print('Logging error: $e'));

      return result;
    } catch (e, stackTrace) {
      final transcriptionDuration =
          DateTime.now().difference(transcriptionStartTime);
      _logger
          .error(
            category: AppConstants.logCategoryAsr,
            message: 'Transcription failed',
            metadata: {
              'audioPath': audioPath,
              'fileSizeBytes': fileSize,
              'transcriptionDurationSeconds': transcriptionDuration.inSeconds,
              'modelPath': _modelPath,
            },
            error: e,
            stackTrace: stackTrace,
          )
          .catchError((err) => print('Logging error: $err'));
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _whisperService.dispose();
    _initialized = false;
    _modelPath = null;
  }

  bool get isInitialized => _initialized;
  String? get modelPath => _modelPath;
}
