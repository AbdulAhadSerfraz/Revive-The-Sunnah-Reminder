import 'package:dio/dio.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';
import 'package:revive_sunnah_reminder/models/chat_message.dart';

class AIChatService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _modelName = 'deepseek/deepseek-chat';
  static const String _apiKey = '';

  final Dio _dio;
  final LoggingService _logger = LoggingService.instance;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;

  bool _isInitialized = false;

  AIChatService() : _dio = Dio() {
    _setupDio();
    _initializeWithHardcodedKey();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // Add security-focused interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Never log sensitive data - only log endpoint
        _logger.debug('[AI Chat] Request to: ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.debug('[AI Chat] Response: ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) {
        // Log error without exposing sensitive data
        final errorMsg = error.response?.statusCode != null
            ? 'HTTP ${error.response!.statusCode}'
            : 'Network error';
        _logger.error('[AI Chat] $errorMsg', error.error);
        handler.next(error);
      },
    ));
  }

  /// Initialize with hardcoded API key
  Future<void> _initializeWithHardcodedKey() async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
      _dio.options.headers['HTTP-Referer'] = 'https://revive-sunnah.app';
      _dio.options.headers['X-Title'] = 'Revive Sunnah Reminder';

      // Validate API key with a test request
      await _validateApiKey();

      _isInitialized = true;
      _logger.info('AI Chat Service initialized with hardcoded API key');
    } catch (e) {
      _logger.error('Failed to initialize AI Chat Service', e);
      rethrow;
    }
  }

  /// Initialize service (kept for compatibility)
  Future<void> initialize([String? apiKey]) async {
    if (apiKey != null) {
      // Allow override for testing
      _dio.options.headers['Authorization'] = 'Bearer $apiKey';
      await _validateApiKey();
      _isInitialized = true;
    } else {
      await _initializeWithHardcodedKey();
    }
  }

  Future<ChatMessage> sendMessage({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
  }) async {
    return await _errorHandler.handleAsyncError(
      'Send AI message',
      () async {
        if (!_isInitialized) {
          throw AIChatException('AI Chat Service not initialized.');
        }

        // Validate and sanitize input
        final sanitizedMessage = _sanitizeUserInput(userMessage);
        if (sanitizedMessage.isEmpty) {
          throw AIChatException('Message cannot be empty');
        }

        // Build Islamic-focused system prompt
        final systemPrompt = _buildIslamicSystemPrompt();
        final messages = _buildMessageHistory(
            systemPrompt, conversationHistory, sanitizedMessage);

        final response = await _dio.post('/chat/completions', data: {
          'model': _modelName,
          'messages': messages,
          'max_tokens': 800, // Reasonable limit for concise responses
          'temperature': 0.3, // Lower for more consistent Islamic answers
          'top_p': 0.8, // More focused responses
          'frequency_penalty': 0.2,
          'presence_penalty': 0.1,
          'stream': false,
        });

        if (response.statusCode == 200) {
          final data = response.data;
          final content = data['choices'][0]['message']['content'];

          // Validate and enhance response
          final validatedContent = _validateAndEnhanceResponse(content);

          return ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: validatedContent,
            isUser: false,
            timestamp: DateTime.now(),
            type: ChatMessageType.text,
            metadata: {
              'model': _modelName,
              'tokens_used': data['usage']?['total_tokens'],
              'validated': true,
              'response_time': DateTime.now().toIso8601String(),
            },
          );
        } else {
          throw AIChatException(
              'Failed to get AI response: ${response.statusCode}');
        }
      },
    );
  }

  /// Build Islamic-focused system prompt
  String _buildIslamicSystemPrompt() {
    return '''You are a knowledgeable Islamic scholar assistant specialized in authentic Hadith and Sunnah practices. Your primary role is to help Muslims understand and implement the teachings of Prophet Muhammad (ﷺ) in their daily lives.

STRICT GUIDELINES - You MUST follow these rules:

1. AUTHENTICITY: Only provide information based on authentic Islamic sources (Quran, authentic Hadith, consensus of scholars)
2. ISLAMIC FOCUS: Only answer questions related to Islam, Hadith, Sunnah, Islamic practices, and Islamic guidance
3. RESPECTFUL LANGUAGE: Always use appropriate Islamic etiquette and terminology
4. CONCISE RESPONSES: Keep answers clear, understandable, and practical (maximum 400 words)
5. SOURCE REFERENCES: Include authentic hadith references when possible
6. PRACTICAL GUIDANCE: Focus on how to implement teachings in modern daily life
7. HUMILITY: If unsure about any Islamic ruling, recommend consulting qualified scholars

ISLAMIC TERMINOLOGY TO USE:
- Prophet Muhammad (ﷺ) or Rasulullah (ﷺ)
- Companions: (رضي الله عنه) for male, (رضي الله عنها) for female
- Allah (سبحانه وتعالى) or Allah (SWT)
- Use "In sha Allah" for future events
- Use "Barakallahu feeki/feeka" for blessings

FORBIDDEN RESPONSES:
- Do NOT answer non-Islamic questions
- Do NOT provide medical, legal, or financial advice
- Do NOT engage in controversial theological debates
- Do NOT provide information about other religions in detail
- Do NOT give personal opinions - only authentic Islamic teachings

RESPONSE FORMAT:
- Start with Islamic greeting when appropriate
- Provide authentic Islamic answer
- Include relevant Islamic references if available
- End with practical implementation advice
- Keep response clear and actionable

Remember: You are helping Muslims revive the Sunnah and strengthen their connection with Islamic teachings. Always encourage good deeds, righteousness, and following the authentic path of Prophet Muhammad (ﷺ).''';
  }

  List<Map<String, String>> _buildMessageHistory(
    String systemPrompt,
    List<ChatMessage> history,
    String currentMessage,
  ) {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // Add recent conversation history (limit to last 8 messages for context)
    final recentHistory =
        history.length > 8 ? history.sublist(history.length - 8) : history;

    for (final message in recentHistory) {
      // Only include text messages to avoid confusion
      if (message.type == ChatMessageType.text ||
          message.type == ChatMessageType.explanation) {
        messages.add({
          'role': message.isUser ? 'user' : 'assistant',
          'content': message.content,
        });
      }
    }

    // Add current user message
    messages.add({
      'role': 'user',
      'content': currentMessage,
    });

    return messages;
  }

  /// Validate API key with test request
  Future<void> _validateApiKey() async {
    try {
      final response = await _dio.get('/models');
      if (response.statusCode != 200) {
        throw AIChatException('Invalid API key');
      }
    } catch (e) {
      throw AIChatException('API key validation failed: ${e.toString()}');
    }
  }

  /// Sanitize user input
  String _sanitizeUserInput(String input) {
    // Remove excessive whitespace and limit length
    final sanitized = input.trim();
    if (sanitized.length > 1000) {
      return sanitized.substring(0, 1000);
    }
    return sanitized;
  }

  /// Validate and enhance AI response
  String _validateAndEnhanceResponse(String response) {
    // Basic validation and enhancement
    String enhanced = response.trim();

    // Ensure response is not empty
    if (enhanced.isEmpty) {
      enhanced =
          'I apologize, but I couldn\'t generate a proper response. Please try rephrasing your question about Islamic teachings.';
    }

    // Add Islamic closing if response seems complete but lacks it
    if (!enhanced.toLowerCase().contains('allah') &&
        !enhanced.toLowerCase().contains('insha') &&
        enhanced.length > 100) {
      enhanced +=
          '\n\nMay Allah (SWT) guide us all to follow the authentic Sunnah.';
    }

    return enhanced;
  }

  /// Get service status
  Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'hasApiKey': true, // Always true with hardcoded key
      'modelName': _modelName,
      'baseUrl': _baseUrl,
    };
  }

  /// Test connection
  Future<bool> testConnection() async {
    try {
      if (!_isInitialized) return false;
      await _dio.get('/models');
      return true;
    } catch (e) {
      _logger.error('Connection test failed', e);
      return false;
    }
  }
}

/// Custom exception for AI Chat Service
class AIChatException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  const AIChatException(this.message, [this.statusCode, this.details]);

  @override
  String toString() {
    if (details != null) {
      return 'AIChatException: $message - $details';
    }
    return 'AIChatException: $message';
  }

  /// Check if error is related to API key
  bool get isApiKeyError {
    return message.toLowerCase().contains('api key') ||
        message.toLowerCase().contains('unauthorized') ||
        statusCode == 401;
  }

  /// Check if error is related to network
  bool get isNetworkError {
    return message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection') ||
        statusCode == null;
  }

  /// Check if error is related to quota/limits
  bool get isQuotaError {
    return message.toLowerCase().contains('quota') ||
        message.toLowerCase().contains('limit') ||
        statusCode == 429;
  }
}
