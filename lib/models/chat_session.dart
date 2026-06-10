import 'package:revive_sunnah_reminder/models/chat_message.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastModified;
  final List<ChatMessage> messages;
  final Map<String, dynamic>? metadata;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastModified,
    this.messages = const [],
    this.metadata,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m))
              .toList() ??
          [],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'metadata': metadata,
    };
  }

  ChatSession copyWith({
    String? title,
    DateTime? lastModified,
    List<ChatMessage>? messages,
    Map<String, dynamic>? metadata,
  }) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      lastModified: lastModified ?? this.lastModified,
      messages: messages ?? this.messages,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get the last user message
  ChatMessage? get lastUserMessage {
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].isUser) {
        return messages[i];
      }
    }
    return null;
  }

  /// Get the last AI message
  ChatMessage? get lastAIMessage {
    for (int i = messages.length - 1; i >= 0; i--) {
      if (!messages[i].isUser) {
        return messages[i];
      }
    }
    return null;
  }

  /// Get message count for specific type
  int getMessageCountByType(ChatMessageType type) {
    return messages.where((m) => m.type == type).length;
  }

  /// Check if session has any messages
  bool get hasMessages => messages.isNotEmpty;

  /// Get session summary for display
  String get summary {
    if (messages.isEmpty) return 'No messages';

    final userMessages = messages.where((m) => m.isUser).length;
    final aiMessages = messages.where((m) => !m.isUser).length;

    return '$userMessages questions, $aiMessages responses';
  }

  /// Generate a preview of the conversation
  String get preview {
    if (messages.isEmpty) return 'Empty conversation';

    final firstUserMessage = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => messages.first,
    );

    final content = firstUserMessage.content;
    if (content.length <= 50) return content;
    return '${content.substring(0, 47)}...';
  }
}
