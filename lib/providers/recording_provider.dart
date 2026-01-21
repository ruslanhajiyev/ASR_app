import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_recording_service.dart';

final audioRecordingServiceProvider =
    Provider<AudioRecordingService>((ref) {
  return AudioRecordingService();
});

final recordingStateProvider =
    StateNotifierProvider<RecordingNotifier, RecordingState>((ref) {
  return RecordingNotifier(ref.read(audioRecordingServiceProvider));
});

final recordingDurationProvider = StreamProvider<Duration>((ref) {
  final recordingState = ref.watch(recordingStateProvider);
  final service = ref.read(audioRecordingServiceProvider);
  
  if (recordingState != RecordingState.recording) {
    return Stream.value(Duration.zero);
  }

  final controller = StreamController<Duration>();
  Timer? timer;

  timer = Timer.periodic(const Duration(seconds: 1), (t) {
    final duration = service.recordingDuration;
    if (duration != null) {
      controller.add(duration);
    } else {
      controller.add(Duration.zero);
    }
  });

  ref.onDispose(() {
    timer?.cancel();
    if (!controller.isClosed) {
      controller.close();
    }
  });

  return controller.stream;
});

class RecordingNotifier extends StateNotifier<RecordingState> {
  final AudioRecordingService _service;

  RecordingNotifier(this._service) : super(RecordingState.idle) {
    _updateState();
  }

  void _updateState() {
    state = _service.state;
  }

  Future<void> startRecording() async {
    try {
      await _service.startRecording();
      _updateState();
    } catch (e) {
      _updateState();
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _service.stopRecording();
      _updateState();
      return path;
    } catch (e) {
      _updateState();
      rethrow;
    }
  }

  Future<void> cancelRecording() async {
    await _service.cancelRecording();
    _updateState();
  }

  Duration? get recordingDuration => _service.recordingDuration;
  String? get currentRecordingPath => _service.currentRecordingPath;
}

