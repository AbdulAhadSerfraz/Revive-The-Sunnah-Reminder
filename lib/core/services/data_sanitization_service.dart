import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';

/// Comprehensive data sanitization service
class DataSanitizationService {
  static DataSanitizationService? _instance;
  static DataSanitizationService get instance =>
      _instance ??= DataSanitizationService._();

  DataSanitizationService._();

  final LoggingService _logger = LoggingService.instance;

  // Dangerous patterns to detect and clean
  static const List<String> _sqlInjectionPatterns = [
    r"'\s*(or|and)\s*'\s*=\s*'",
    r"\bunion\b.*\bselect\b",
    r"\bselect\b.*\bfrom\b",
    r"\binsert\b.*\binto\b",
    r"\bdelete\b.*\bfrom\b",
    r"\bupdate\b.*\bset\b",
    r"\bdrop\b.*\btable\b",
    r"\balter\b.*\btable\b",
    r"\bexec\b.*\b\(",
    r"\bexecute\b.*\b\(",
  ];

  static final List<String> _xssPatterns = [
    r"<script[^>]*>.*?</script>",
    r"javascript\s*:",
    r"vbscript\s*:",
    r'on\w+\s*=(["'
        "'"
        r']).*?\1', // Pattern for on= attributes
    r"<iframe[^>]*>.*?</iframe>",
    r"<object[^>]*>.*?</object>",
    r"<embed[^>]*>.*?</embed>",
    r"<applet[^>]*>.*?</applet>",
    r"<meta[^>]*http-equiv[^>]*>",
    r'<link[^>]*href\s*=(["'
        "'"
        r']).*?\1javascript:', // Pattern for link href with javascript
  ];

  static const List<String> _pathTraversalPatterns = [
    r"\.\.\/",
    r"\.\.\\\\",
    r"%2e%2e%2f",
    r"%2e%2e%5c",
    r"\\\.\\\.\\",
  ];

  /// Sanitize general text input
  String sanitizeText(
    String input, {
    bool removeHtml = true,
    bool removeSql = true,
    bool removeXss = true,
    bool removePathTraversal = true,
    bool normalizeWhitespace = true,
    bool trimWhitespace = true,
    int? maxLength,
  }) {
    try {
      String sanitized = input;

      // Remove null bytes and control characters
      sanitized = _removeControlCharacters(sanitized);

      // Remove SQL injection patterns
      if (removeSql) {
        sanitized = _removeSqlInjection(sanitized);
      }

      // Remove XSS patterns
      if (removeXss) {
        sanitized = _removeXssPatterns(sanitized);
      }

      // Remove path traversal patterns
      if (removePathTraversal) {
        sanitized = _removePathTraversal(sanitized);
      }

      // Remove HTML tags
      if (removeHtml) {
        sanitized = _removeHtmlTags(sanitized);
      }

      // Normalize whitespace
      if (normalizeWhitespace) {
        sanitized = _normalizeWhitespace(sanitized);
      }

      // Trim whitespace
      if (trimWhitespace) {
        sanitized = sanitized.trim();
      }

      // Limit length
      if (maxLength != null && sanitized.length > maxLength) {
        sanitized = sanitized.substring(0, maxLength);
        _logger.warning('Text truncated to $maxLength characters');
      }

      return sanitized;
    } catch (e) {
      _logger.error('Error sanitizing text', e);
      return '';
    }
  }

  /// Sanitize email address
  String sanitizeEmail(String email) {
    try {
      // Convert to lowercase and trim
      String sanitized = email.toLowerCase().trim();

      // Remove dangerous characters
      sanitized = sanitized.replaceAll(RegExp(r'[^a-z0-9@._+-]'), '');

      // Basic format validation
      if (!RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$')
          .hasMatch(sanitized)) {
        _logger.warning('Invalid email format after sanitization: $email');
        return '';
      }

      return sanitized;
    } catch (e) {
      _logger.error('Error sanitizing email', e);
      return '';
    }
  }

  /// Sanitize phone number
  String sanitizePhoneNumber(String phone) {
    try {
      // Remove all non-digit characters except +
      String sanitized = phone.replaceAll(RegExp(r'[^\d+]'), '');

      // Ensure proper format
      if (sanitized.startsWith('+')) {
        // International format
        sanitized = sanitized.replaceAll(RegExp(r'^\++'), '+');
      } else {
        // Remove any + from middle or end
        sanitized = sanitized.replaceAll('+', '');
      }

      return sanitized;
    } catch (e) {
      _logger.error('Error sanitizing phone number', e);
      return '';
    }
  }

  /// Sanitize URL
  String sanitizeUrl(String url) {
    try {
      String sanitized = url.trim();

      // Remove dangerous protocols
      final dangerousProtocols = ['javascript:', 'vbscript:', 'data:', 'file:'];
      for (final protocol in dangerousProtocols) {
        if (sanitized.toLowerCase().startsWith(protocol)) {
          _logger.warning('Dangerous protocol removed from URL: $protocol');
          return '';
        }
      }

      // Ensure http/https protocol
      if (!sanitized.startsWith('http://') &&
          !sanitized.startsWith('https://')) {
        sanitized = 'https://$sanitized';
      }

      // Validate URL structure
      try {
        final uri = Uri.parse(sanitized);
        if (!uri.hasScheme || !uri.hasAuthority) {
          return '';
        }
        return uri.toString();
      } catch (e) {
        _logger.warning('Invalid URL structure: $url');
        return '';
      }
    } catch (e) {
      _logger.error('Error sanitizing URL', e);
      return '';
    }
  }

  /// Sanitize file name
  String sanitizeFileName(String fileName) {
    try {
      String sanitized = fileName.trim();

      // Remove path traversal attempts
      sanitized = sanitized.replaceAll(RegExp(r'[\\\\/]'), '');

      // Remove dangerous characters
      sanitized = sanitized.replaceAll(RegExp(r'[<>:\"|?*]'), '');

      // Remove control characters
      sanitized = sanitized.replaceAll(RegExp(r'[\\x00-\\x1f\\x7f]'), '');

      // Remove leading/trailing dots and spaces
      sanitized = sanitized.replaceAll(RegExp(r'^[.\\s]+|[.\\s]+$'), '');

      // Ensure not empty and not reserved names
      final reservedNames = [
        'CON',
        'PRN',
        'AUX',
        'NUL',
        'COM1',
        'COM2',
        'COM3',
        'COM4',
        'COM5',
        'COM6',
        'COM7',
        'COM8',
        'COM9',
        'LPT1',
        'LPT2',
        'LPT3',
        'LPT4',
        'LPT5',
        'LPT6',
        'LPT7',
        'LPT8',
        'LPT9'
      ];

      final nameWithoutExt = sanitized.split('.').first.toUpperCase();
      if (reservedNames.contains(nameWithoutExt)) {
        sanitized = '_$sanitized';
      }

      // Limit length
      if (sanitized.length > 255) {
        final ext = sanitized.split('.').last;
        final nameLength = 255 - ext.length - 1;
        sanitized = '${sanitized.substring(0, nameLength)}.$ext';
      }

      return sanitized.isEmpty ? 'file' : sanitized;
    } catch (e) {
      _logger.error('Error sanitizing file name', e);
      return 'file';
    }
  }

  /// Sanitize JSON data
  Map<String, dynamic>? sanitizeJson(
    Map<String, dynamic> json, {
    List<String>? allowedKeys,
    int maxDepth = 10,
    int maxStringLength = 10000,
  }) {
    try {
      return _sanitizeJsonRecursive(
        json,
        allowedKeys: allowedKeys,
        currentDepth: 0,
        maxDepth: maxDepth,
        maxStringLength: maxStringLength,
      ) as Map<String, dynamic>?;
    } catch (e) {
      _logger.error('Error sanitizing JSON', e);
      return null;
    }
  }

  /// Recursively sanitize JSON data
  dynamic _sanitizeJsonRecursive(
    dynamic data, {
    List<String>? allowedKeys,
    required int currentDepth,
    required int maxDepth,
    required int maxStringLength,
  }) {
    if (currentDepth >= maxDepth) {
      _logger.warning('JSON depth limit exceeded');
      return null;
    }

    if (data is Map<String, dynamic>) {
      final sanitized = <String, dynamic>{};

      for (final entry in data.entries) {
        // Check if key is allowed
        if (allowedKeys != null && !allowedKeys.contains(entry.key)) {
          continue;
        }

        // Sanitize key
        final sanitizedKey = sanitizeText(
          entry.key,
          maxLength: 100,
          removeHtml: true,
          removeSql: true,
          removeXss: true,
        );

        if (sanitizedKey.isEmpty) continue;

        // Recursively sanitize value
        final sanitizedValue = _sanitizeJsonRecursive(
          entry.value,
          allowedKeys: allowedKeys,
          currentDepth: currentDepth + 1,
          maxDepth: maxDepth,
          maxStringLength: maxStringLength,
        );

        if (sanitizedValue != null) {
          sanitized[sanitizedKey] = sanitizedValue;
        }
      }

      return sanitized;
    } else if (data is List) {
      final sanitized = <dynamic>[];

      for (final item in data) {
        final sanitizedItem = _sanitizeJsonRecursive(
          item,
          allowedKeys: allowedKeys,
          currentDepth: currentDepth + 1,
          maxDepth: maxDepth,
          maxStringLength: maxStringLength,
        );

        if (sanitizedItem != null) {
          sanitized.add(sanitizedItem);
        }
      }

      return sanitized;
    } else if (data is String) {
      return sanitizeText(
        data,
        maxLength: maxStringLength,
        removeHtml: true,
        removeSql: true,
        removeXss: true,
      );
    } else if (data is num || data is bool) {
      return data;
    } else {
      // Unsupported data type
      return null;
    }
  }

  /// Remove control characters
  String _removeControlCharacters(String input) {
    // Remove null bytes and other control characters except tab, newline, carriage return
    return input.replaceAll(
        RegExp(r'[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\x7F]'), '');
  }

  /// Remove SQL injection patterns
  String _removeSqlInjection(String input) {
    String sanitized = input;

    for (final pattern in _sqlInjectionPatterns) {
      sanitized =
          sanitized.replaceAll(RegExp(pattern, caseSensitive: false), '');
    }

    return sanitized;
  }

  /// Remove XSS patterns
  String _removeXssPatterns(String input) {
    String sanitized = input;

    for (final pattern in _xssPatterns) {
      sanitized =
          sanitized.replaceAll(RegExp(pattern, caseSensitive: false), '');
    }

    return sanitized;
  }

  /// Remove path traversal patterns
  String _removePathTraversal(String input) {
    String sanitized = input;

    for (final pattern in _pathTraversalPatterns) {
      sanitized =
          sanitized.replaceAll(RegExp(pattern, caseSensitive: false), '');
    }

    return sanitized;
  }

  /// Remove HTML tags
  String _removeHtmlTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Normalize whitespace
  String _normalizeWhitespace(String input) {
    return input
        .replaceAll(RegExp(r'\\s+'),
            ' ') // Replace multiple whitespace with single space
        .replaceAll(RegExp(r'\n+'),
            '\n') // Replace multiple newlines with single newline
        .replaceAll(
            RegExp(r'\\t+'), '\\t'); // Replace multiple tabs with single tab
  }

  /// Hash sensitive data
  String hashSensitiveData(String data, {String? salt}) {
    try {
      final saltBytes = salt != null ? utf8.encode(salt) : _generateSalt();
      final dataBytes = utf8.encode(data);
      final combined = [...saltBytes, ...dataBytes];

      final digest = sha256.convert(combined);
      return digest.toString();
    } catch (e) {
      _logger.error('Error hashing sensitive data', e);
      return '';
    }
  }

  /// Generate random salt
  List<int> _generateSalt() {
    final random = Random.secure();
    return List.generate(32, (index) => random.nextInt(256));
  }

  /// Mask sensitive data for logging
  String maskSensitiveData(
    String data, {
    int visibleChars = 4,
    String maskChar = '*',
  }) {
    if (data.length <= visibleChars) {
      return maskChar * data.length;
    }

    final visiblePart = data.substring(0, visibleChars);
    final maskedPart = maskChar * (data.length - visibleChars);

    return visiblePart + maskedPart;
  }

  /// Clean data for database storage
  Map<String, dynamic> sanitizeForDatabase(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        sanitized[key] = sanitizeText(
          value,
          removeHtml: true,
          removeSql: true,
          removeXss: true,
          removePathTraversal: true,
        );
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = sanitizeForDatabase(value);
      } else if (value is List) {
        sanitized[key] = value.map((item) {
          if (item is String) {
            return sanitizeText(item);
          } else if (item is Map<String, dynamic>) {
            return sanitizeForDatabase(item);
          }
          return item;
        }).toList();
      } else {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  /// Validate and sanitize search query
  String sanitizeSearchQuery(String query) {
    try {
      String sanitized = query.trim();

      // Remove SQL injection patterns
      sanitized = _removeSqlInjection(sanitized);

      // Remove dangerous characters for search
      sanitized = sanitized.replaceAll(RegExp(r'[<>\"\\\\]'), '');

      // Limit length
      if (sanitized.length > 100) {
        sanitized = sanitized.substring(0, 100);
      }

      // Remove extra whitespace
      sanitized = sanitized.replaceAll(RegExp(r'\\s+'), ' ');

      return sanitized;
    } catch (e) {
      _logger.error('Error sanitizing search query', e);
      return '';
    }
  }

  /// Check if input contains dangerous patterns
  bool containsDangerousPatterns(String input) {
    final allPatterns = [
      ..._sqlInjectionPatterns,
      ..._xssPatterns,
      ..._pathTraversalPatterns
    ];

    for (final pattern in allPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        _logger.warning('Dangerous pattern detected: $pattern');
        return true;
      }
    }

    return false;
  }

  /// Generate security report for input
  Map<String, dynamic> generateSecurityReport(String input) {
    final report = <String, dynamic>{
      'length': input.length,
      'containsHtml': RegExp(r'<[^>]*>').hasMatch(input),
      'containsScript':
          RegExp(r'<script', caseSensitive: false).hasMatch(input),
      'containsSqlKeywords': false,
      'containsXssPatterns': false,
      'containsPathTraversal': false,
      'controlCharacters':
          RegExp(r'[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\x7F]').hasMatch(input),
      'dangerousPatterns': <String>[],
    };

    // Check SQL injection patterns
    for (final pattern in _sqlInjectionPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        report['containsSqlKeywords'] = true;
        (report['dangerousPatterns'] as List<String>).add('SQL: $pattern');
      }
    }

    // Check XSS patterns
    for (final pattern in _xssPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        report['containsXssPatterns'] = true;
        (report['dangerousPatterns'] as List<String>).add('XSS: $pattern');
      }
    }

    // Check path traversal patterns
    for (final pattern in _pathTraversalPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        report['containsPathTraversal'] = true;
        (report['dangerousPatterns'] as List<String>).add('Path: $pattern');
      }
    }

    report['riskLevel'] = _calculateRiskLevel(report);

    return report;
  }

  /// Calculate risk level based on security report
  String _calculateRiskLevel(Map<String, dynamic> report) {
    int riskScore = 0;

    if (report['containsScript'] == true) riskScore += 10;
    if (report['containsSqlKeywords'] == true) riskScore += 8;
    if (report['containsXssPatterns'] == true) riskScore += 7;
    if (report['containsPathTraversal'] == true) riskScore += 6;
    if (report['containsHtml'] == true) riskScore += 3;
    if (report['controlCharacters'] == true) riskScore += 2;

    final patternCount = (report['dangerousPatterns'] as List).length;
    riskScore += patternCount * 2;

    if (riskScore >= 10) return 'HIGH';
    if (riskScore >= 5) return 'MEDIUM';
    if (riskScore >= 1) return 'LOW';
    return 'SAFE';
  }
}
