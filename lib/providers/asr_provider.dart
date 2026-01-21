import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';
import '../models/transcription_result.dart';
import '../services/asr_service.dart';
import '../services/logging_service.dart';
import '../services/model_loader_service.dart';
import '../services/model_management_service.dart';
import '../utils/constants.dart';

final asrServiceProvider = Provider<AsrService>((ref) {
  return AsrService();
});

final modelLoaderProvider = Provider<ModelLoaderService>((ref) {
  return ModelLoaderService();
});

final selectedModelProvider = FutureProvider<WhisperModel>((ref) async {
  final service = ModelManagementService();
  return await service.getSelectedModel();
});

final asrStateProvider =
    StateNotifierProvider<AsrNotifier, AsyncValue<TranscriptionResult?>>(
  (ref) {
    return AsrNotifier(ref.read(asrServiceProvider));
  },
);

class AsrNotifier extends StateNotifier<AsyncValue<TranscriptionResult?>> {
  final AsrService _service;
  final LoggingService _logger = LoggingService();
  WhisperModel? _lastInitializedModel;

  AsrNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> initialize({WhisperModel? model}) async {
    // Get selected model if not provided
    WhisperModel modelToUse = model ?? WhisperModel.tiny;
    if (model == null) {
      try {
        final service = ModelManagementService();
        modelToUse = await service.getSelectedModel();
      } catch (e) {
        _logger.warn(
          category: AppConstants.logCategoryAsr,
          message: 'Error getting selected model, using default',
          metadata: {'error': e.toString()},
        ).catchError((err) => debugPrint('Logging error: $err'));
      }
    }

    if (_service.isInitialized && _lastInitializedModel == modelToUse) {
      if (state.hasError) {
        _logger.info(
          category: AppConstants.logCategoryAsr,
          message: 'Previous initialization had error, reinitializing',
        ).catchError((err) => debugPrint('Logging error: $err'));
      } else {
        return;
      }
    }

    state = const AsyncValue.loading();

    try {
      await _service.init(
        model: modelToUse,
        language: 'en',
      );
      _lastInitializedModel = modelToUse;
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error(
        category: AppConstants.logCategoryAsr,
        message: 'ASR Initialization Error',
        error: e,
        stackTrace: stackTrace,
      ).catchError((err) => debugPrint('Logging error: $err'));
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> transcribe(String audioPath) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.transcribeFile(audioPath);
      state = AsyncValue.data(result);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

