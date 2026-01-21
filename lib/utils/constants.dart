/// Application-wide constants
class AppConstants {
  AppConstants._();

  // File names
  static const String submissionQueueFileName = 'submission_queue.json.encrypted';
  static const String logFileName = 'app_logs.json';

  // Log categories
  static const String logCategoryAsr = 'asr';
  static const String logCategorySubmission = 'submission';
  static const String logCategorySession = 'session';
  static const String logCategoryAuth = 'auth';

  // Durations
  static const Duration defaultDelay = Duration(milliseconds: 200);
  static const Duration shortDelay = Duration(milliseconds: 500);
  static const Duration uploadSimulationDelay = Duration(seconds: 1);
  static const Duration snackBarShortDuration = Duration(seconds: 2);
  static const Duration snackBarLongDuration = Duration(seconds: 5);
  static const Duration logBundleDefaultWindow = Duration(hours: 1);

  // Logging
  static const int maxLogsInMemory = 1000;
  static const int logSaveInterval = 10;

  // Password validation
  static const int minPasswordLength = 8;
  static final RegExp passwordUppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp passwordLowercaseRegex = RegExp(r'[a-z]');
  static final RegExp passwordNumberRegex = RegExp(r'[0-9]');
  static final RegExp passwordSymbolRegex = RegExp(r'[^a-zA-Z0-9]');

  // UI
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double iconSize = 64.0;
  static const double largeIconSize = 80.0;

  // Audio file patterns
  static const String audioFilePattern = 'recording_';
}
