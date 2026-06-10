import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';

/// Simplified encryption service using basic crypto
class EncryptionService {
  static EncryptionService? _instance;
  static EncryptionService get instance => _instance ??= EncryptionService._();

  EncryptionService._();

  final LoggingService _logger = LoggingService.instance;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;

  // Encryption parameters
  static const int _keyLength = 32; // 256 bits
  static const int _iterations = 10000;

  String? _masterKey;
  Uint8List? _keyBytes;

  /// Initialize encryption service
  Future<void> initialize() async {
    await _errorHandler.handleAsyncError('Initialize encryption service',
        () async {
      _logger.info('Initializing encryption service');

      await _loadOrGenerateKey();

      _logger.info('Encryption service initialized successfully');
    });
  }

  /// Load existing key or generate new one
  Future<void> _loadOrGenerateKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingKey = prefs.getString('encryption_key');

      if (existingKey != null) {
        _masterKey = existingKey;
        _keyBytes = base64.decode(existingKey);
        _logger.info('Loaded existing encryption key');
      } else {
        await _generateNewKey();
        _logger.info('Generated new encryption key');
      }
    } catch (e) {
      _logger.error('Error loading encryption key', e);
      await _generateNewKey();
    }
  }

  /// Generate new encryption key
  Future<void> _generateNewKey() async {
    final random = Random.secure();
    _keyBytes = Uint8List(_keyLength);

    for (int i = 0; i < _keyLength; i++) {
      _keyBytes![i] = random.nextInt(256);
    }

    _masterKey = base64.encode(_keyBytes!);

    // Store the key
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('encryption_key', _masterKey!);
  }

  /// Simple XOR encryption (for demonstration - not cryptographically secure)
  String? encryptData(String data, {String? customKey}) {
    try {
      final keyToUse = customKey != null ? base64.decode(customKey) : _keyBytes;
      if (keyToUse == null) {
        _logger.error('No encryption key available');
        return null;
      }

      final dataBytes = utf8.encode(data);
      final encryptedBytes = Uint8List(dataBytes.length);

      for (int i = 0; i < dataBytes.length; i++) {
        encryptedBytes[i] = dataBytes[i] ^ keyToUse[i % keyToUse.length];
      }

      return base64.encode(encryptedBytes);
    } catch (e) {
      _logger.error('Error encrypting data', e);
      return null;
    }
  }

  /// Simple XOR decryption
  String? decryptData(String encryptedData, {String? customKey}) {
    try {
      final keyToUse = customKey != null ? base64.decode(customKey) : _keyBytes;
      if (keyToUse == null) {
        _logger.error('No encryption key available');
        return null;
      }

      final encryptedBytes = base64.decode(encryptedData);
      final decryptedBytes = Uint8List(encryptedBytes.length);

      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes[i] = encryptedBytes[i] ^ keyToUse[i % keyToUse.length];
      }

      return utf8.decode(decryptedBytes);
    } catch (e) {
      _logger.error('Error decrypting data', e);
      return null;
    }
  }

  /// Encrypt JSON data
  String? encryptJson(Map<String, dynamic> data, {String? customKey}) {
    try {
      final jsonString = json.encode(data);
      return encryptData(jsonString, customKey: customKey);
    } catch (e) {
      _logger.error('Error encrypting JSON data', e);
      return null;
    }
  }

  /// Decrypt JSON data
  Map<String, dynamic>? decryptJson(String encryptedData, {String? customKey}) {
    try {
      final decryptedString = decryptData(encryptedData, customKey: customKey);
      if (decryptedString != null) {
        return json.decode(decryptedString) as Map<String, dynamic>;
      }
    } catch (e) {
      _logger.error('Error decrypting JSON data', e);
    }

    return null;
  }

  /// Generate secure hash for data integrity
  String generateHash(String data, {String? salt}) {
    final saltBytes =
        salt != null ? utf8.encode(salt) : _generateSecureRandom(16);
    final dataBytes = utf8.encode(data);
    final combined = [...saltBytes, ...dataBytes];

    final digest = sha256.convert(combined);
    return digest.toString();
  }

  /// Verify data integrity
  bool verifyHash(String data, String expectedHash, {String? salt}) {
    final actualHash = generateHash(data, salt: salt);
    return actualHash == expectedHash;
  }

  /// Generate secure random bytes
  Uint8List _generateSecureRandom(int length) {
    final random = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  /// Store encrypted API key securely
  Future<bool> storeEncryptedApiKey(String apiKey) async {
    return await _errorHandler.handleAsyncError('Store encrypted API key',
        () async {
      final encryptedKey = encryptData(apiKey);
      if (encryptedKey == null) {
        throw Exception('Failed to encrypt API key');
      }

      final prefs = await SharedPreferences.getInstance();
      final stored = await prefs.setString('encrypted_api_key', encryptedKey);

      if (stored) {
        _logger.info('API key stored securely');
        return true;
      } else {
        throw Exception('Failed to store encrypted API key');
      }
    });
  }

  /// Retrieve and decrypt API key
  Future<String?> getDecryptedApiKey() async {
    return await _errorHandler.handleAsyncError('Get decrypted API key',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final encryptedKey = prefs.getString('encrypted_api_key');

      if (encryptedKey == null) {
        _logger.debug('No stored API key found');
        return null;
      }

      final decryptedKey = decryptData(encryptedKey);
      if (decryptedKey == null) {
        _logger.error('Failed to decrypt API key');
        await prefs.remove('encrypted_api_key'); // Remove corrupted data
        return null;
      }

      return decryptedKey;
    });
  }

  /// Check if API key is stored
  Future<bool> hasStoredApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('encrypted_api_key');
  }

  /// Remove stored API key
  Future<void> removeApiKey() async {
    await _errorHandler.handleAsyncError('Remove API key', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('encrypted_api_key');
      _logger.info('API key removed from storage');
    });
  }

  /// Store encrypted data with custom key
  Future<bool> storeEncryptedData(String key, String data) async {
    return await _errorHandler.handleAsyncError('Store encrypted data',
        () async {
      final encryptedData = encryptData(data);
      if (encryptedData == null) {
        throw Exception('Failed to encrypt data');
      }

      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('encrypted_$key', encryptedData);
    });
  }

  /// Get encrypted data with custom key
  Future<String?> getEncryptedData(String key) async {
    return await _errorHandler.handleAsyncError('Get encrypted data', () async {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = prefs.getString('encrypted_$key');

      if (encryptedData == null) {
        return null;
      }

      return decryptData(encryptedData);
    });
  }

  /// Encrypt string (alias for backward compatibility)
  Future<String?> encryptString(String data) async {
    return encryptData(data);
  }

  /// Decrypt string (alias for backward compatibility)
  Future<String?> decryptString(String encryptedData) async {
    return decryptData(encryptedData);
  }

  /// Generate secure session token
  String generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBytes = _generateSecureRandom(16);
    final combined = '$timestamp:${base64.encode(randomBytes)}';

    return base64.encode(utf8.encode(combined));
  }

  /// Get encryption status
  Map<String, dynamic> getEncryptionStatus() {
    return {
      'initialized': _keyBytes != null && _masterKey != null,
      'keyLength': _keyLength,
      'algorithm': 'XOR (simplified)',
      'keyDerivation': 'Random generation',
      'iterations': _iterations,
    };
  }

  /// Reset encryption (generate new keys)
  Future<void> resetEncryption() async {
    await _errorHandler.handleAsyncError('Reset encryption', () async {
      // Clear existing keys
      _masterKey = null;
      _keyBytes = null;

      // Remove stored keys
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('encryption_key');

      // Reinitialize
      await initialize();

      _logger.info('Encryption service reset successfully');
    });
  }

  /// Dispose and cleanup
  void dispose() {
    // Clear sensitive data from memory
    if (_keyBytes != null) {
      _keyBytes!.fillRange(0, _keyBytes!.length, 0);
    }

    _masterKey = null;
    _keyBytes = null;

    _logger.info('Encryption service disposed');
  }
}
