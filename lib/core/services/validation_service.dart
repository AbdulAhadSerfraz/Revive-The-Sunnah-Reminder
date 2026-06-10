import 'dart:convert';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';

/// Validation result class
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? sanitizedValue;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.sanitizedValue,
  });

  factory ValidationResult.valid(String? sanitizedValue) {
    return ValidationResult(
      isValid: true,
      sanitizedValue: sanitizedValue,
    );
  }

  factory ValidationResult.invalid(String errorMessage) {
    return ValidationResult(
      isValid: false,
      errorMessage: errorMessage,
    );
  }
}

/// Comprehensive input validation service
class ValidationService {
  static ValidationService? _instance;
  static ValidationService get instance => _instance ??= ValidationService._();

  ValidationService._();

  final LoggingService _logger = LoggingService.instance;

  /// Validate and sanitize text input
  ValidationResult validateText(
    String? input, {
    int? minLength,
    int? maxLength,
    bool required = false,
    bool allowSpecialChars = true,
    bool allowNumbers = true,
    bool allowSpaces = true,
    String? customPattern,
  }) {
    try {
      // Check if required
      if (required && (input == null || input.trim().isEmpty)) {
        return ValidationResult.invalid('This field is required');
      }

      // If not required and empty, return valid
      if (!required && (input == null || input.trim().isEmpty)) {
        return ValidationResult.valid('');
      }

      // Sanitize input
      String sanitized = sanitizeText(input!);

      // Check length constraints
      if (minLength != null && sanitized.length < minLength) {
        return ValidationResult.invalid(
            'Minimum length is $minLength characters');
      }

      if (maxLength != null && sanitized.length > maxLength) {
        return ValidationResult.invalid(
            'Maximum length is $maxLength characters');
      }

      // Check character restrictions
      if (!allowNumbers && sanitized.contains(RegExp(r'\d'))) {
        return ValidationResult.invalid('Numbers are not allowed');
      }

      if (!allowSpaces && sanitized.contains(' ')) {
        return ValidationResult.invalid('Spaces are not allowed');
      }

      if (!allowSpecialChars && sanitized.contains(RegExp(r'[^\w\s]'))) {
        return ValidationResult.invalid('Special characters are not allowed');
      }

      // Check custom pattern
      if (customPattern != null && !RegExp(customPattern).hasMatch(sanitized)) {
        return ValidationResult.invalid('Invalid format');
      }

      return ValidationResult.valid(sanitized);
    } catch (e) {
      _logger.error('Error validating text input', e);
      return ValidationResult.invalid('Validation error occurred');
    }
  }

  /// Validate email address
  ValidationResult validateEmail(String? email, {bool required = false}) {
    try {
      if (required && (email == null || email.trim().isEmpty)) {
        return ValidationResult.invalid('Email is required');
      }

      if (!required && (email == null || email.trim().isEmpty)) {
        return ValidationResult.valid('');
      }

      // Sanitize email
      String sanitized = email!.trim().toLowerCase();

      // Email regex pattern
      const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

      if (!RegExp(emailPattern).hasMatch(sanitized)) {
        return ValidationResult.invalid('Please enter a valid email address');
      }

      return ValidationResult.valid(sanitized);
    } catch (e) {
      _logger.error('Error validating email', e);
      return ValidationResult.invalid('Email validation error');
    }
  }

  /// Validate phone number
  ValidationResult validatePhoneNumber(String? phone, {bool required = false}) {
    try {
      if (required && (phone == null || phone.trim().isEmpty)) {
        return ValidationResult.invalid('Phone number is required');
      }

      if (!required && (phone == null || phone.trim().isEmpty)) {
        return ValidationResult.valid('');
      }

      // Sanitize phone (remove all non-digit characters except +)
      String sanitized = phone!.replaceAll(RegExp(r'[^\d+]'), '');

      // Check phone number length (international format)
      if (sanitized.length < 10 || sanitized.length > 15) {
        return ValidationResult.invalid('Please enter a valid phone number');
      }

      // Check if starts with + for international format
      if (sanitized.startsWith('+') && sanitized.length < 11) {
        return ValidationResult.invalid(
            'Please enter a valid international phone number');
      }

      return ValidationResult.valid(sanitized);
    } catch (e) {
      _logger.error('Error validating phone number', e);
      return ValidationResult.invalid('Phone validation error');
    }
  }

  /// Validate password
  ValidationResult validatePassword(
    String? password, {
    bool required = false,
    int minLength = 6,
    bool requireUppercase = false,
    bool requireLowercase = false,
    bool requireNumbers = false,
    bool requireSpecialChars = false,
  }) {
    try {
      if (required && (password == null || password.isEmpty)) {
        return ValidationResult.invalid('Password is required');
      }

      if (!required && (password == null || password.isEmpty)) {
        return ValidationResult.valid('');
      }

      if (password!.length < minLength) {
        return ValidationResult.invalid(
            'Password must be at least $minLength characters');
      }

      if (requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
        return ValidationResult.invalid(
            'Password must contain at least one uppercase letter');
      }

      if (requireLowercase && !password.contains(RegExp(r'[a-z]'))) {
        return ValidationResult.invalid(
            'Password must contain at least one lowercase letter');
      }

      if (requireNumbers && !password.contains(RegExp(r'\d'))) {
        return ValidationResult.invalid(
            'Password must contain at least one number');
      }

      if (requireSpecialChars && !password.contains(RegExp(r'[!@#\$&*~]'))) {
        return ValidationResult.invalid(
            'Password must contain at least one special character');
      }

      return ValidationResult.valid(password);
    } catch (e) {
      _logger.error('Error validating password', e);
      return ValidationResult.invalid('Password validation error');
    }
  }

  /// Validate URL
  ValidationResult validateUrl(String? url, {bool required = false}) {
    try {
      if (required && (url == null || url.trim().isEmpty)) {
        return ValidationResult.invalid('URL is required');
      }

      if (!required && (url == null || url.trim().isEmpty)) {
        return ValidationResult.valid('');
      }

      String sanitized = url!.trim();

      // Add http:// if no protocol specified
      if (!sanitized.startsWith('http://') &&
          !sanitized.startsWith('https://')) {
        sanitized = 'https://$sanitized';
      }

      // URL validation
      try {
        final uri = Uri.parse(sanitized);
        if (!uri.hasScheme || !uri.hasAuthority) {
          return ValidationResult.invalid('Please enter a valid URL');
        }
      } catch (e) {
        return ValidationResult.invalid('Please enter a valid URL');
      }

      return ValidationResult.valid(sanitized);
    } catch (e) {
      _logger.error('Error validating URL', e);
      return ValidationResult.invalid('URL validation error');
    }
  }

  /// Validate numeric input
  ValidationResult validateNumber(
    String? input, {
    bool required = false,
    num? min,
    num? max,
    bool allowDecimals = true,
  }) {
    try {
      if (required && (input == null || input.trim().isEmpty)) {
        return ValidationResult.invalid('This field is required');
      }

      if (!required && (input == null || input.trim().isEmpty)) {
        return ValidationResult.valid('');
      }

      String sanitized = input!.trim();

      // Parse number
      num? number;
      try {
        if (allowDecimals) {
          number = double.parse(sanitized);
        } else {
          number = int.parse(sanitized);
        }
      } catch (e) {
        return ValidationResult.invalid('Please enter a valid number');
      }

      // Check range
      if (min != null && number < min) {
        return ValidationResult.invalid('Value must be at least $min');
      }

      if (max != null && number > max) {
        return ValidationResult.invalid('Value must be at most $max');
      }

      return ValidationResult.valid(number.toString());
    } catch (e) {
      _logger.error('Error validating number', e);
      return ValidationResult.invalid('Number validation error');
    }
  }

  /// Validate date
  ValidationResult validateDate(
    String? input, {
    bool required = false,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    try {
      if (required && (input == null || input.trim().isEmpty)) {
        return ValidationResult.invalid('Date is required');
      }

      if (!required && (input == null || input.trim().isEmpty)) {
        return ValidationResult.valid('');
      }

      DateTime? date;
      try {
        date = DateTime.parse(input!);
      } catch (e) {
        return ValidationResult.invalid(
            'Please enter a valid date (YYYY-MM-DD)');
      }

      if (minDate != null && date.isBefore(minDate)) {
        return ValidationResult.invalid(
            'Date must be after ${minDate.toIso8601String().split('T')[0]}');
      }

      if (maxDate != null && date.isAfter(maxDate)) {
        return ValidationResult.invalid(
            'Date must be before ${maxDate.toIso8601String().split('T')[0]}');
      }

      return ValidationResult.valid(date.toIso8601String().split('T')[0]);
    } catch (e) {
      _logger.error('Error validating date', e);
      return ValidationResult.invalid('Date validation error');
    }
  }

  /// Validate JSON input
  ValidationResult validateJson(String? input, {bool required = false}) {
    try {
      if (required && (input == null || input.trim().isEmpty)) {
        return ValidationResult.invalid('JSON is required');
      }

      if (!required && (input == null || input.trim().isEmpty)) {
        return ValidationResult.valid('{}');
      }

      try {
        final decoded = json.decode(input!);
        final encoded = json.encode(decoded); // Re-encode to standardize format
        return ValidationResult.valid(encoded);
      } catch (e) {
        return ValidationResult.invalid('Please enter valid JSON');
      }
    } catch (e) {
      _logger.error('Error validating JSON', e);
      return ValidationResult.invalid('JSON validation error');
    }
  }

  /// Sanitize text input to prevent XSS and injection attacks
  String sanitizeText(String input) {
    // Remove null bytes
    String sanitized = input.replaceAll('\\x00', '');

    // Remove or escape dangerous characters
    sanitized = sanitized.replaceAll('<script', '&lt;script');
    sanitized = sanitized.replaceAll('</script>', '&lt;/script&gt;');
    sanitized = sanitized.replaceAll('<iframe', '&lt;iframe');
    sanitized = sanitized.replaceAll('javascript:', 'javascript&#58;');
    sanitized = sanitized.replaceAll('vbscript:', 'vbscript&#58;');
    sanitized = sanitized.replaceAll('onload=', 'onload&#61;');
    sanitized = sanitized.replaceAll('onerror=', 'onerror&#61;');

    // Trim whitespace
    sanitized = sanitized.trim();

    return sanitized;
  }

  /// Sanitize HTML content
  String sanitizeHtml(String input) {
    String sanitized = input;

    // Remove dangerous HTML tags
    final dangerousTags = [
      'script',
      'iframe',
      'object',
      'embed',
      'form',
      'input',
      'button',
      'select',
      'textarea',
      'link',
      'meta',
      'style'
    ];

    for (final tag in dangerousTags) {
      sanitized = sanitized.replaceAll(
        RegExp('<$tag[^>]*>', caseSensitive: false),
        '&lt;$tag&gt;',
      );
      sanitized = sanitized.replaceAll(
        RegExp('</$tag>', caseSensitive: false),
        '&lt;/$tag&gt;',
      );
    }

    // Remove event handlers - using simple string replacement
    sanitized = sanitized.replaceAll('onclick=', 'onclick-disabled=');
    sanitized = sanitized.replaceAll('onload=', 'onload-disabled=');
    sanitized = sanitized.replaceAll('onerror=', 'onerror-disabled=');
    sanitized = sanitized.replaceAll('onmouseover=', 'onmouseover-disabled=');

    return sanitized;
  }

  /// Validate file upload
  ValidationResult validateFileUpload(
    String fileName,
    int fileSize, {
    List<String>? allowedExtensions,
    int? maxSizeBytes,
    bool required = false,
  }) {
    try {
      if (required && fileName.isEmpty) {
        return ValidationResult.invalid('File is required');
      }

      if (!required && fileName.isEmpty) {
        return ValidationResult.valid('');
      }

      // Check file extension
      if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
        final extension = fileName.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(extension)) {
          return ValidationResult.invalid(
            'Only ${allowedExtensions.join(', ')} files are allowed',
          );
        }
      }

      // Check file size
      if (maxSizeBytes != null && fileSize > maxSizeBytes) {
        final maxMB = (maxSizeBytes / 1024 / 1024).toStringAsFixed(1);
        return ValidationResult.invalid(
            'File size must be less than ${maxMB}MB');
      }

      return ValidationResult.valid(fileName);
    } catch (e) {
      _logger.error('Error validating file upload', e);
      return ValidationResult.invalid('File validation error');
    }
  }

  /// Batch validate multiple fields
  Map<String, ValidationResult> validateFields(Map<String, dynamic> fields) {
    final results = <String, ValidationResult>{};

    try {
      for (final entry in fields.entries) {
        final fieldName = entry.key;
        final fieldConfig = entry.value as Map<String, dynamic>;
        final value = fieldConfig['value'] as String?;
        final type = fieldConfig['type'] as String;

        switch (type) {
          case 'text':
            results[fieldName] = validateText(
              value,
              required: fieldConfig['required'] ?? false,
              minLength: fieldConfig['minLength'],
              maxLength: fieldConfig['maxLength'],
              allowSpecialChars: fieldConfig['allowSpecialChars'] ?? true,
              allowNumbers: fieldConfig['allowNumbers'] ?? true,
              allowSpaces: fieldConfig['allowSpaces'] ?? true,
            );
            break;
          case 'email':
            results[fieldName] = validateEmail(
              value,
              required: fieldConfig['required'] ?? false,
            );
            break;
          case 'phone':
            results[fieldName] = validatePhoneNumber(
              value,
              required: fieldConfig['required'] ?? false,
            );
            break;
          case 'password':
            results[fieldName] = validatePassword(
              value,
              required: fieldConfig['required'] ?? false,
              minLength: fieldConfig['minLength'] ?? 6,
              requireUppercase: fieldConfig['requireUppercase'] ?? false,
              requireLowercase: fieldConfig['requireLowercase'] ?? false,
              requireNumbers: fieldConfig['requireNumbers'] ?? false,
              requireSpecialChars: fieldConfig['requireSpecialChars'] ?? false,
            );
            break;
          case 'url':
            results[fieldName] = validateUrl(
              value,
              required: fieldConfig['required'] ?? false,
            );
            break;
          case 'number':
            results[fieldName] = validateNumber(
              value,
              required: fieldConfig['required'] ?? false,
              min: fieldConfig['min'],
              max: fieldConfig['max'],
              allowDecimals: fieldConfig['allowDecimals'] ?? true,
            );
            break;
          case 'date':
            results[fieldName] = validateDate(
              value,
              required: fieldConfig['required'] ?? false,
              minDate: fieldConfig['minDate'],
              maxDate: fieldConfig['maxDate'],
            );
            break;
          default:
            results[fieldName] =
                ValidationResult.invalid('Unknown field type: $type');
        }
      }
    } catch (e) {
      _logger.error('Error in batch validation', e);
    }

    return results;
  }

  /// Check if all validation results are valid
  bool areAllValid(Map<String, ValidationResult> results) {
    return results.values.every((result) => result.isValid);
  }

  /// Get first error message from validation results
  String? getFirstError(Map<String, ValidationResult> results) {
    for (final result in results.values) {
      if (!result.isValid) {
        return result.errorMessage;
      }
    }
    return null;
  }

  /// Get all error messages from validation results
  List<String> getAllErrors(Map<String, ValidationResult> results) {
    return results.values
        .where((result) => !result.isValid)
        .map((result) => result.errorMessage!)
        .toList();
  }

  /// Get sanitized values from validation results
  Map<String, String> getSanitizedValues(
      Map<String, ValidationResult> results) {
    final sanitized = <String, String>{};

    for (final entry in results.entries) {
      if (entry.value.isValid && entry.value.sanitizedValue != null) {
        sanitized[entry.key] = entry.value.sanitizedValue!;
      }
    }

    return sanitized;
  }
}
