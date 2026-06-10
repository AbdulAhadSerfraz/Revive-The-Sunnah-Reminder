import 'package:flutter_test/flutter_test.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/validation_service.dart';
import 'package:revive_sunnah_reminder/core/services/data_sanitization_service.dart';
import 'package:revive_sunnah_reminder/core/services/encryption_service.dart';

void main() {
  group('Fixed Services Tests', () {
    test('Logging Service initializes correctly', () {
      final loggingService = LoggingService.instance;
      expect(loggingService, isNotNull);
      
      // Test logging functionality
      loggingService.info('Test message');
      loggingService.debug('Debug message');
      loggingService.warning('Warning message');
    });

    test('Validation Service validates email correctly', () {
      final validationService = ValidationService.instance;
      
      // Test valid email
      final validResult = validationService.validateEmail('test@example.com');
      expect(validResult.isValid, true);
      expect(validResult.sanitizedValue, 'test@example.com');
      
      // Test invalid email
      final invalidResult = validationService.validateEmail('invalid-email');
      expect(invalidResult.isValid, false);
      expect(invalidResult.errorMessage, isNotNull);
    });

    test('Data Sanitization Service sanitizes text correctly', () {
      final sanitizationService = DataSanitizationService.instance;
      
      // Test basic text sanitization
      final sanitized = sanitizationService.sanitizeText('  Hello World  ');
      expect(sanitized, 'Hello World');
      
      // Test email sanitization
      final email = sanitizationService.sanitizeEmail('TEST@EXAMPLE.COM');
      expect(email, 'test@example.com');
    });

    test('Encryption Service initializes and encrypts data', () async {
      final encryptionService = EncryptionService.instance;
      await encryptionService.initialize();
      
      // Test encryption
      const testData = 'Hello, World!';
      final encrypted = encryptionService.encryptData(testData);
      expect(encrypted, isNotNull);
      
      // Test decryption
      if (encrypted != null) {
        final decrypted = encryptionService.decryptData(encrypted);
        expect(decrypted, testData);
      }
    });

    test('Validation Service validates passwords correctly', () {
      final validationService = ValidationService.instance;
      
      // Test strong password
      final strongResult = validationService.validatePassword(
        'StrongPass123!',
        required: true,
        requireUppercase: true,
        requireLowercase: true,
        requireNumbers: true,
        requireSpecialChars: true,
      );
      expect(strongResult.isValid, true);
      
      // Test weak password
      final weakResult = validationService.validatePassword(
        '123',
        required: true,
        minLength: 6,
      );
      expect(weakResult.isValid, false);
    });
  });
}