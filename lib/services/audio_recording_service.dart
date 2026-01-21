import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'logging_service.dart';

enum RecordingState {
  idle,
  recording,
  stopped,
  error,
}

class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  final LoggingService _logger = LoggingService();
  RecordingState _state = RecordingState.idle;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  RecordingState get state => _state;
  String? get currentRecordingPath => _currentRecordingPath;
  Duration? get recordingDuration {
    if (_recordingStartTime == null) return null;
    return DateTime.now().difference(_recordingStartTime!);
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      await _logger.warn(
        category: 'recording',
        message: 'Microphone permission denied',
        metadata: {'status': status.toString()},
      );
      return false;
    }
    
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      await _logger.warn(
        category: 'recording',
        message: 'Microphone permission not available via recorder',
      );
      return false;
    }
    
    await _logger.info(
      category: 'recording',
      message: 'Microphone permission granted',
    );
    
    return true;
  }

  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      return false;
    }
    
    final hasPermission = await _recorder.hasPermission();
    return hasPermission;
  }

  Future<void> startRecording() async {
    if (_state == RecordingState.recording) {
      await _logger.warn(
        category: 'recording',
        message: 'Attempted to start recording while already recording',
      );
      throw Exception('Already recording');
    }

    final hasPermission = await this.hasPermission();
    if (!hasPermission) {
      final granted = await requestPermission();
      if (!granted) {
        _state = RecordingState.error;
        await _logger.error(
          category: 'recording',
          message: 'Microphone permission denied',
        );
        throw Exception('Microphone permission denied. Please grant microphone permission in app settings.');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final finalCheck = await _recorder.hasPermission();
    if (!finalCheck) {
      _state = RecordingState.error;
      await _logger.error(
        category: 'recording',
        message: 'Microphone permission not available after request',
      );
      throw Exception('Microphone permission not available. Please grant permission and try again.');
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath =
          '${directory.path}/recording_$timestamp.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav, 
          bitRate: 128000,
          sampleRate: 16000, 
          numChannels: 1, 
        ),
        path: _currentRecordingPath!,
      );

      _recordingStartTime = DateTime.now();
      _state = RecordingState.recording;
      
      await _logger.info(
        category: 'recording',
        message: 'Recording started',
        metadata: {
          'audioPath': _currentRecordingPath,
          'format': 'WAV',
          'sampleRate': 16000,
          'channels': 1,
          'bitRate': 128000,
        },
      );
    } catch (e, stackTrace) {
      _state = RecordingState.error;
      await _logger.error(
        category: 'recording',
        message: 'Failed to start recording',
        error: e,
        stackTrace: stackTrace,
      );
      final errorMessage = e.toString();
      if (errorMessage.contains('permission') || errorMessage.contains('Permission')) {
        throw Exception('Microphone permission denied. Please grant permission in app settings.');
      } else if (errorMessage.contains('busy') || errorMessage.contains('already')) {
        throw Exception('Microphone is already in use by another app. Please close other apps using the microphone.');
      } else {
        throw Exception('Failed to start recording: $e');
      }
    }
  }

  Future<String?> stopRecording() async {
    if (_state != RecordingState.recording) {
      return null;
    }

    try {
      final path = await _recorder.stop();
      final duration = recordingDuration;
      _state = RecordingState.stopped;
      
      await _logger.info(
        category: 'recording',
        message: 'Recording stopped',
        metadata: {
          'audioPath': path ?? _currentRecordingPath,
          'durationSeconds': duration?.inSeconds ?? 0,
        },
      );
      
      _recordingStartTime = null;
      return path ?? _currentRecordingPath;
    } catch (e, stackTrace) {
      _state = RecordingState.error;
      await _logger.error(
        category: 'recording',
        message: 'Failed to stop recording',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to stop recording: $e');
    }
  }

  Future<void> cancelRecording() async {
    if (_state == RecordingState.recording) {
      await _recorder.stop();
      if (_currentRecordingPath != null) {
        try {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Ignore deletion errors
        }
      }
    }
    _currentRecordingPath = null;
    _recordingStartTime = null;
    _state = RecordingState.idle;
  }

  Future<void> dispose() async {
    if (_state == RecordingState.recording) {
      await _recorder.stop();
    }
    await _recorder.dispose();
    _state = RecordingState.idle;
  }
}

