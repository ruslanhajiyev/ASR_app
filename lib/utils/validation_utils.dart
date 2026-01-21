import '../utils/constants.dart';

/// Validation utility functions
class ValidationUtils {
  ValidationUtils._();

  /// Validates password strength and returns error message if invalid
  /// Returns null if password is valid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    final List<String> missingRequirements = [];

    if (value.length < AppConstants.minPasswordLength) {
      missingRequirements.add('At least 8 characters');
    }
    if (!value.contains(AppConstants.passwordUppercaseRegex)) {
      missingRequirements.add('uppercase letter');
    }
    if (!value.contains(AppConstants.passwordLowercaseRegex)) {
      missingRequirements.add('lowercase letter');
    }
    if (!value.contains(AppConstants.passwordNumberRegex)) {
      missingRequirements.add('number');
    }
    if (!value.contains(AppConstants.passwordSymbolRegex)) {
      missingRequirements.add('symbol');
    }

    if (missingRequirements.isNotEmpty) {
      return missingRequirements.join(', ');
    }

    return null;
  }

  /// Parses comma-separated labels string into a list
  static List<String> parseLabels(String labelsText) {
    return labelsText
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
