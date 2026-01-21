import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/constants.dart';

enum LogSeverity {
  info,
  warn,
  error,
}

class LogEvent {
  final DateTime timestamp;
  final LogSeverity severity;
  final String category;
  final String message;
  final Map<String, dynamic>? metadata;
  final String? stackTrace;

  LogEvent({
    required this.timestamp,
    required this.severity,
    required this.category,
    required this.message,
    this.metadata,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name.toUpperCase(),
      'category': category,
      'message': message,
      if (metadata != null) 'metadata': metadata,
      if (stackTrace != null) 'stackTrace': _sanitizeStackTrace(stackTrace!),
    };
  }

  String _sanitizeStackTrace(String stackTrace) {
    return stackTrace
        .replaceAll(RegExp(r'file:///[A-Z]:[^ ]+'), '[REDACTED_PATH]')
        .replaceAll(RegExp(r'C:\\Users\\[^\\]+'), '[REDACTED_USER]')
        .replaceAll(RegExp(r'/Users/[^/]+'), '[REDACTED_USER]');
  }
}

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  final List<LogEvent> _logs = [];
  File? _logFile;
  String? _sessionId;
  DateTime? _sessionStartTime;
  PackageInfo? _packageInfo;
  Map<String, dynamic>? _deviceInfo;

  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/${AppConstants.logFileName}');

      _loadLogs().catchError((e) => debugPrint('Failed to load logs: $e'));

      PackageInfo.fromPlatform().then((info) {
        _packageInfo = info;
      }).catchError((e) {
        debugPrint('Failed to load package info: $e');
        return null;
      });

      _loadDeviceInfo().catchError((e) {
        debugPrint('Failed to load device info: $e');
      });

      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _sessionStartTime = DateTime.now();

      info(
        category: AppConstants.logCategorySession,
        message: 'Session started',
        metadata: {
          'sessionId': _sessionId,
        },
      ).catchError((e) => debugPrint('Failed to log session start: $e'));
    } catch (e) {
      debugPrint('LoggingService initialization failed: $e');
    }
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
        };
      }
    } catch (e) {
      _deviceInfo = {'platform': 'unknown', 'error': e.toString()};
    }
  }

  Future<void> _loadLogs() async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        final content = await _logFile!.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        _logs.clear();
        _logs.addAll(
          jsonList.map((json) => LogEvent(
                timestamp: DateTime.parse(json['timestamp']),
                severity: LogSeverity.values.firstWhere(
                  (e) => e.name.toUpperCase() == json['severity'],
                ),
                category: json['category'],
                message: json['message'],
                metadata: json['metadata'] != null
                    ? Map<String, dynamic>.from(json['metadata'])
                    : null,
                stackTrace: json['stackTrace'],
              )),
        );
        if (_logs.length > AppConstants.maxLogsInMemory) {
          _logs.removeRange(0, _logs.length - AppConstants.maxLogsInMemory);
        }
      }
    } catch (e) {
      debugPrint('Failed to load logs: $e');
    }
  }

  Future<void> _saveLogs() async {
    try {
      if (_logFile != null) {
        final jsonList = _logs.map((log) => log.toJson()).toList();
        await _logFile!.writeAsString(json.encode(jsonList));
      }
    } catch (e) {
      debugPrint('Failed to save logs: $e');
    }
  }

  Future<void> info({
    required String category,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(LogSeverity.info, category, message, metadata);
  }

  Future<void> warn({
    required String category,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(LogSeverity.warn, category, message, metadata);
  }

  Future<void> error({
    required String category,
    required String message,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    await _log(
      LogSeverity.error,
      category,
      message,
      metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> _log(
    LogSeverity severity,
    String category,
    String message,
    Map<String, dynamic>? metadata, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    try {
      final event = LogEvent(
        timestamp: DateTime.now(),
        severity: severity,
        category: category,
        message: message,
        metadata: metadata,
        stackTrace: stackTrace?.toString() ?? error?.toString(),
      );

      _logs.add(event);

      if (kDebugMode) {
        final severityStr = severity.name.toUpperCase();
        debugPrint('[$severityStr] [$category] $message');
        if (metadata != null) {
          debugPrint('  Metadata: $metadata');
        }
        if (error != null) {
          debugPrint('  Error: $error');
        }
      }

      if (_logs.length > AppConstants.maxLogsInMemory) {
        _logs.removeAt(0);
      }

      if (_logs.length % AppConstants.logSaveInterval == 0 &&
          _logFile != null) {
        _saveLogs().catchError((e) => debugPrint('Failed to save logs: $e'));
      }
    } catch (e) {
      debugPrint('Logging error: $e');
    }
  }

  List<LogEvent> getLogs({
    String? category,
    LogSeverity? minSeverity,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    var filtered = _logs;

    if (category != null) {
      filtered = filtered.where((log) => log.category == category).toList();
    }

    if (minSeverity != null) {
      final severityIndex = LogSeverity.values.indexOf(minSeverity);
      filtered = filtered.where((log) {
        final logSeverityIndex = LogSeverity.values.indexOf(log.severity);
        return logSeverityIndex >= severityIndex;
      }).toList();
    }

    if (startTime != null) {
      filtered =
          filtered.where((log) => log.timestamp.isAfter(startTime)).toList();
    }

    if (endTime != null) {
      filtered =
          filtered.where((log) => log.timestamp.isBefore(endTime)).toList();
    }

    return filtered;
  }

  Future<Map<String, dynamic>> createLogBundle({
    String? submissionId,
    DateTime? recordingStartTime,
    DateTime? submissionTime,
  }) async {
    final startTime = recordingStartTime ??
        (submissionTime != null
            ? submissionTime.subtract(AppConstants.logBundleDefaultWindow)
            : null);
    final endTime = submissionTime ?? DateTime.now();

    final relevantLogs = getLogs(
      startTime: startTime,
      endTime: endTime,
    );

    return {
      'sessionId': _sessionId,
      'sessionStartTime': _sessionStartTime?.toIso8601String(),
      'bundleCreatedAt': DateTime.now().toIso8601String(),
      'submissionId': submissionId,
      'client': {
        'appVersion': _packageInfo?.version ?? 'unknown',
        'buildNumber': _packageInfo?.buildNumber ?? 'unknown',
        'packageName': _packageInfo?.packageName ?? 'unknown',
        if (_deviceInfo != null) ..._deviceInfo!,
      },
      'logs': relevantLogs.map((log) => log.toJson()).toList(),
      'logCount': relevantLogs.length,
    };
  }

  Future<void> clearLogs() async {
    _logs.clear();
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.delete();
    }
    await info(
      category: AppConstants.logCategorySession,
      message: 'Logs cleared',
    );
  }

  Duration? get sessionDuration {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  Future<void> endSession() async {
    if (_sessionStartTime != null) {
      final duration = sessionDuration;
      await info(
        category: AppConstants.logCategorySession,
        message: 'Session ended',
        metadata: {
          'sessionId': _sessionId,
          'durationSeconds': duration?.inSeconds ?? 0,
        },
      );
      await _saveLogs();
    }
  }

  List<Map<String, dynamic>> getAllLogsJson() {
    return _logs.map((log) => log.toJson()).toList();
  }
}
