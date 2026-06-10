import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/models/chat_message.dart';
import 'package:revive_sunnah_reminder/models/chat_session.dart';
import 'package:revive_sunnah_reminder/services/ai_chat_service.dart';
import 'package:revive_sunnah_reminder/core/services/storage_service.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/providers/credits_provider.dart';

class ChatProvider extends ChangeNotifier {
  static const String _chatSessionsKey = 'chat_sessions_v2';
  static const String _currentSessionKey = 'current_session_id_v2';
  static const String _chatSettingsKey = 'chat_settings_v2';

  final AIChatService _aiService;
  final StorageService _storageService;
  final LoggingService _logger = LoggingService.instance;
  // Note: _errorHandler available for future use if needed

  ChatSession? _currentSession;
  List<ChatSession> _sessions = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _isInitialized = false;
  String? _error;

  // Chat settings
  bool _autoSaveEnabled = true;
  int _maxSessionsToKeep = 50;

  ChatProvider({
    required AIChatService aiService,
    required StorageService storageService,
  })  : _aiService = aiService,
        _storageService = storageService;

  // Getters
  ChatSession? get currentSession => _currentSession;
  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  List<ChatMessage> get messages => _currentSession?.messages ?? [];
  bool get hasActiveSession => _currentSession != null;
  bool get hasMessages => messages.isNotEmpty;

  // Settings getters
  bool get autoSaveEnabled => _autoSaveEnabled;
  int get maxSessionsToKeep => _maxSessionsToKeep;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    _clearError();

    try {
      await _loadChatSettings();
      await _loadSessions();
      await _loadCurrentSession();

      _isInitialized = true;
      _logger
          .info('Chat Provider initialized with ${_sessions.length} sessions');
    } catch (e) {
      _setError('Failed to initialize chat: $e');
      _logger.error('Chat initialization failed', e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadChatSettings() async {
    final settings = _storageService.getObject(_chatSettingsKey);
    if (settings != null) {
      _autoSaveEnabled = settings['autoSaveEnabled'] ?? true;
      _maxSessionsToKeep = settings['maxSessionsToKeep'] ?? 50;
    }
  }

  Future<void> _saveChatSettings() async {
    final settings = {
      'autoSaveEnabled': _autoSaveEnabled,
      'maxSessionsToKeep': _maxSessionsToKeep,
    };
    await _storageService.setObject(_chatSettingsKey, settings);
  }

  Future<void> _loadSessions() async {
    final sessionsData = _storageService.getObject(_chatSessionsKey);
    if (sessionsData != null && sessionsData['sessions'] is List) {
      try {
        _sessions = (sessionsData['sessions'] as List)
            .map((data) => ChatSession.fromJson(data))
            .toList();

        // Sort by last modified (newest first)
        _sessions.sort((a, b) => b.lastModified.compareTo(a.lastModified));

        // Clean old sessions if needed
        await _cleanOldSessions();
      } catch (e) {
        _logger.error('Error loading sessions, resetting', e);
        _sessions = [];
      }
    }
  }

  Future<void> _cleanOldSessions() async {
    if (_sessions.length > _maxSessionsToKeep) {
      final toRemove = _sessions.length - _maxSessionsToKeep;
      _sessions.removeRange(_maxSessionsToKeep, _sessions.length);
      _logger.info('Cleaned $toRemove old chat sessions');
      await _saveSessions();
    }
  }

  Future<void> _loadCurrentSession() async {
    final currentSessionData = _storageService.getObject(_currentSessionKey);
    if (currentSessionData != null) {
      final currentSessionId = currentSessionData['sessionId'];
      if (currentSessionId != null) {
        _currentSession = _sessions.firstWhere(
          (session) => session.id == currentSessionId,
          orElse: () => _createNewSession(),
        );
      }
    }

    // Create new session if none exists
    _currentSession = _currentSession ?? _createNewSession();
  }

  ChatSession _createNewSession() {
    final now = DateTime.now();
    return ChatSession(
      id: now.millisecondsSinceEpoch.toString(),
      title: 'New Chat',
      createdAt: now,
      lastModified: now,
    );
  }

  Future<void> startNewChat() async {
    try {
      _currentSession = _createNewSession();
      await _saveCurrentSessionId();
      _clearError();

      _logger.info('Started new chat session: ${_currentSession!.id}');
      notifyListeners();
    } catch (e) {
      _setError('Failed to start new chat: $e');
      _logger.error('Failed to start new chat', e);
    }
  }

  Future<void> sendMessage({
    required String content,
    required CreditsProvider creditsProvider,
  }) async {
    if (_isSending || content.trim().isEmpty || _currentSession == null) {
      return;
    }

    // Check credits first
    if (!creditsProvider.hasCredits) {
      _setError(
          'No credits remaining. Daily limit of ${creditsProvider.totalCredits} questions reached.');
      return;
    }

    _setSending(true);
    _clearError();

    try {
      // Create user message
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content.trim(),
        isUser: true,
        timestamp: DateTime.now(),
        type: ChatMessageType.text,
      );

      // Add user message to current session
      await _addMessageToCurrentSession(userMessage);

      // Consume credit
      final creditConsumed = await creditsProvider.consumeCredit();
      if (!creditConsumed) {
        throw Exception('Failed to consume credit');
      }

      // Initialize AI service if needed
      if (!_aiService.getStatus()['initialized']) {
        await _aiService.initialize();
      }

      // Get AI response
      final aiResponse = await _aiService.sendMessage(
        userMessage: content,
        conversationHistory: _currentSession!.messages
            .take(_currentSession!.messages.length - 1)
            .toList(),
      );

      // Add AI response to current session
      await _addMessageToCurrentSession(aiResponse);

      // Update session title if it's the first exchange
      if (_currentSession!.messages.length == 2) {
        await _updateSessionTitle(_generateTitle(content));
      }

      // Auto-save if enabled
      if (_autoSaveEnabled) {
        await _saveCurrentSession();
      }

      _logger.info('Message exchange completed successfully');
    } catch (e) {
      final errorMessage = e is AIChatException
          ? e.message
          : 'Failed to send message. Please try again.';

      _setError(errorMessage);
      _logger.error('Failed to send chat message', e);

      // Add error message to chat for user feedback
      final errorChatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            'Sorry, I encountered an error: $errorMessage\n\nPlease try again or rephrase your question.',
        isUser: false,
        timestamp: DateTime.now(),
        type: ChatMessageType.error,
      );
      await _addMessageToCurrentSession(errorChatMessage);
    } finally {
      _setSending(false);
    }
  }

  Future<void> _addMessageToCurrentSession(ChatMessage message) async {
    if (_currentSession != null) {
      final updatedMessages = List<ChatMessage>.from(_currentSession!.messages)
        ..add(message);

      _currentSession = _currentSession!.copyWith(
        messages: updatedMessages,
        lastModified: DateTime.now(),
      );

      notifyListeners();
    }
  }

  String _generateTitle(String firstMessage) {
    // Generate a meaningful title from the first message
    final cleanMessage = firstMessage.trim();

    // Extract key Islamic terms for better titles
    final islamicTerms = [
      'sunnah',
      'quran',
      'prayer',
      'allah',
      'prophet',
      'islamic'
    ];
    final words = cleanMessage.toLowerCase().split(' ');

    String title = '';
    for (final term in islamicTerms) {
      if (words.any((word) => word.contains(term))) {
        title = cleanMessage.split(' ').take(4).join(' ');
        break;
      }
    }

    if (title.isEmpty) {
      title = cleanMessage.split(' ').take(3).join(' ');
    }

    if (title.length > 30) {
      title = '${title.substring(0, 27)}...';
    }

    return title.isNotEmpty ? title : 'Islamic Question';
  }

  Future<void> _updateSessionTitle(String title) async {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(title: title);
      await _saveCurrentSession();
      notifyListeners();
    }
  }

  Future<void> _saveCurrentSession() async {
    if (_currentSession == null) return;

    try {
      // Update or add session to sessions list
      final existingIndex =
          _sessions.indexWhere((s) => s.id == _currentSession!.id);
      if (existingIndex >= 0) {
        _sessions[existingIndex] = _currentSession!;
      } else {
        _sessions.insert(0, _currentSession!);
      }

      // Save sessions and current session ID
      await Future.wait([
        _saveSessions(),
        _saveCurrentSessionId(),
      ]);
    } catch (e) {
      _logger.error('Failed to save current session', e);
    }
  }

  Future<void> _saveSessions() async {
    final sessionsData = {
      'sessions': _sessions.map((s) => s.toJson()).toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await _storageService.setObject(_chatSessionsKey, sessionsData);
  }

  Future<void> _saveCurrentSessionId() async {
    if (_currentSession != null) {
      final sessionData = {
        'sessionId': _currentSession!.id,
        'lastAccessed': DateTime.now().toIso8601String(),
      };
      await _storageService.setObject(_currentSessionKey, sessionData);
    }
  }

  Future<void> switchToSession(String sessionId) async {
    try {
      final session = _sessions.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => throw Exception('Session not found'),
      );

      _currentSession = session;
      await _saveCurrentSessionId();
      _clearError();

      _logger.info('Switched to session: $sessionId');
      notifyListeners();
    } catch (e) {
      _setError('Failed to switch session: $e');
      _logger.error('Failed to switch session', e);
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      _sessions.removeWhere((s) => s.id == sessionId);

      // If current session was deleted, switch to another or create new
      if (_currentSession?.id == sessionId) {
        _currentSession =
            _sessions.isNotEmpty ? _sessions.first : _createNewSession();
        await _saveCurrentSessionId();
      }

      await _saveSessions();
      _clearError();

      _logger.info('Deleted session: $sessionId');
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete session: $e');
      _logger.error('Failed to delete session', e);
    }
  }

  Future<void> deleteAllSessions() async {
    try {
      _sessions.clear();
      _currentSession = _createNewSession();

      await Future.wait([
        _saveSessions(),
        _saveCurrentSessionId(),
      ]);

      _clearError();
      _logger.info('Deleted all chat sessions');
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete all sessions: $e');
      _logger.error('Failed to delete all sessions', e);
    }
  }

  // Settings management
  Future<void> updateSettings({
    bool? autoSaveEnabled,
    int? maxSessionsToKeep,
  }) async {
    try {
      if (autoSaveEnabled != null) _autoSaveEnabled = autoSaveEnabled;
      if (maxSessionsToKeep != null) {
        _maxSessionsToKeep = maxSessionsToKeep;
      }

      await _saveChatSettings();

      // Clean sessions if limit changed
      if (maxSessionsToKeep != null && maxSessionsToKeep < _sessions.length) {
        await _cleanOldSessions();
      }

      _logger.info('Chat settings updated');
      notifyListeners();
    } catch (e) {
      _setError('Failed to update settings: $e');
      _logger.error('Failed to update chat settings', e);
    }
  }

  // Analytics and stats
  Map<String, dynamic> getChatStats() {
    final totalMessages = _sessions.fold<int>(
      0,
      (sum, session) => sum + session.messages.length,
    );

    final userMessages = _sessions.fold<int>(
      0,
      (sum, session) => sum + session.messages.where((m) => m.isUser).length,
    );

    final aiMessages = totalMessages - userMessages;

    return {
      'totalSessions': _sessions.length,
      'totalMessages': totalMessages,
      'userMessages': userMessages,
      'aiMessages': aiMessages,
      'averageMessagesPerSession': _sessions.isNotEmpty
          ? (totalMessages / _sessions.length).toStringAsFixed(1)
          : '0.0',
      'oldestSession': _sessions.isNotEmpty
          ? _sessions.last.createdAt.toIso8601String()
          : null,
      'newestSession': _sessions.isNotEmpty
          ? _sessions.first.createdAt.toIso8601String()
          : null,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSending(bool sending) {
    _isSending = sending;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _sessions.clear();
    _currentSession = null;
    super.dispose();
  }
}
