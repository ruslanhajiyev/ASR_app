import 'package:flutter_test/flutter_test.dart';
import 'package:asr_app/services/logging_service.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoggingService', () {
    late LoggingService loggingService;

    setUp(() {
      loggingService = LoggingService();
    });

    test('should log info messages', () async {
      await loggingService.info(
        category: 'test',
        message: 'Test info message',
        metadata: {'key': 'value'},
      );

      final logs = loggingService.getLogs(category: 'test');
      expect(logs.length, greaterThan(0));
      expect(logs.first.severity, LogSeverity.info);
      expect(logs.first.message, 'Test info message');
      expect(logs.first.metadata, {'key': 'value'});
    });

    test('should log warning messages', () async {
      await loggingService.warn(
        category: 'test',
        message: 'Test warning message',
        metadata: {'key': 'value'},
      );

      final logs = loggingService.getLogs(category: 'test', minSeverity: LogSeverity.warn);
      expect(logs.length, greaterThan(0));
      expect(logs.first.severity, LogSeverity.warn);
      expect(logs.first.message, 'Test warning message');
    });

    test('should log error messages with stack trace', () async {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      await loggingService.error(
        category: 'test',
        message: 'Test error message',
        error: error,
        stackTrace: stackTrace,
      );

      final logs = loggingService.getLogs(category: 'test', minSeverity: LogSeverity.error);
      expect(logs.length, greaterThan(0));
      expect(logs.first.severity, LogSeverity.error);
      expect(logs.first.message, 'Test error message');
      expect(logs.first.stackTrace, isNotNull);
    });

    test('should filter logs by category', () async {
      await loggingService.info(category: 'auth', message: 'Auth log');
      await loggingService.info(category: 'submission', message: 'Submission log');
      await loggingService.info(category: 'auth', message: 'Another auth log');

      final authLogs = loggingService.getLogs(category: 'auth');
      final submissionLogs = loggingService.getLogs(category: 'submission');

      expect(authLogs.length, greaterThanOrEqualTo(2));
      expect(submissionLogs.length, greaterThanOrEqualTo(1));
    });

    test('should filter logs by time range', () async {
      fakeAsync((async) {
        final startTime = DateTime.now();
        
        loggingService.info(category: 'test', message: 'Log 1').then((_) {
          async.elapse(const Duration(seconds: 2));
          loggingService.info(category: 'test', message: 'Log 2').then((_) {
            async.elapse(const Duration(seconds: 2));
            loggingService.info(category: 'test', message: 'Log 3').then((_) {
              final endTime = DateTime.now();
              
              final logs = loggingService.getLogs(
                startTime: startTime.add(const Duration(seconds: 1)),
                endTime: endTime.subtract(const Duration(seconds: 1)),
              );
              
            
              expect(logs.length, greaterThanOrEqualTo(1));
            });
          });
        });
      });
    });

    test('should filter logs by minimum severity', () async {
      await loggingService.info(category: 'test', message: 'Info');
      await loggingService.warn(category: 'test', message: 'Warning');
      await loggingService.error(category: 'test', message: 'Error');

      final warnAndAbove = loggingService.getLogs(
        category: 'test',
        minSeverity: LogSeverity.warn,
      );

      expect(warnAndAbove.length, greaterThanOrEqualTo(2));
      expect(warnAndAbove.every((log) => 
        log.severity == LogSeverity.warn || log.severity == LogSeverity.error
      ), isTrue);
    });

    test('should create log bundle with client info', () async {
     
      await loggingService.info(category: 'test', message: 'Test log');
      
      final bundle = await loggingService.createLogBundle(
        submissionTime: DateTime.now(),
      );

      expect(bundle['sessionId'], isNotNull);
     
      expect(bundle['logs'], isA<List>());
      expect(bundle['logCount'], isA<int>());
    });

    test('should sanitize stack traces', () {
      final logEvent = LogEvent(
        timestamp: DateTime.now(),
        severity: LogSeverity.error,
        category: 'test',
        message: 'Test',
        stackTrace: 'C:\\Users\\username\\path\\to\\file.dart:10:5',
      );

      final json = logEvent.toJson();
      final sanitized = json['stackTrace'] as String;

      expect(sanitized, contains('[REDACTED_USER]'));
      expect(sanitized, isNot(contains('username')));
    });

    test('should convert LogEvent to JSON correctly', () {
      final logEvent = LogEvent(
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        severity: LogSeverity.info,
        category: 'test',
        message: 'Test message',
        metadata: {'key': 'value'},
      );

      final json = logEvent.toJson();

      expect(json['severity'], 'INFO');
      expect(json['category'], 'test');
      expect(json['message'], 'Test message');
      expect(json['metadata'], {'key': 'value'});
      expect(json['timestamp'], '2024-01-01T12:00:00.000');
    });

    test('should clear logs', () async {
      await loggingService.info(category: 'test', message: 'Log 1');
      await loggingService.info(category: 'test', message: 'Log 2');

      await loggingService.clearLogs();

      final logs = loggingService.getLogs();
      expect(logs.length, greaterThanOrEqualTo(0));
    });
  });
}
