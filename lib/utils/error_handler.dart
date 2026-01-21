import 'package:flutter/material.dart';
import '../services/logging_service.dart';
import 'constants.dart';

/// Centralized error handling utilities
class ErrorHandler {
  ErrorHandler._();

  /// Shows a snackbar with error message
  static void showError(BuildContext? context, String message) {
    if (context == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: AppConstants.snackBarLongDuration,
      ),
    );
  }

  /// Shows a snackbar with success message
  static void showSuccess(BuildContext? context, String message) {
    if (context == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: AppConstants.snackBarShortDuration,
      ),
    );
  }

  /// Shows a snackbar with info message
  static void showInfo(BuildContext? context, String message) {
    if (context == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: AppConstants.snackBarShortDuration,
      ),
    );
  }

  /// Logs an error and shows a snackbar
  static Future<void> handleError(
    BuildContext? context,
    Object error, {
    String? message,
    String category = AppConstants.logCategorySession,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    final errorMessage = message ?? error.toString();
    
    if (context != null) {
      showError(context, errorMessage);
    }

    await LoggingService().error(
      category: category,
      message: errorMessage,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    ).catchError((e) {
      debugPrint('Failed to log error: $e');
    });
  }
}
