import 'package:intl/intl.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ChatMessageType type;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = ChatMessageType.text,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      type: ChatMessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ChatMessageType.text,
      ),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'metadata': metadata,
    };
  }

  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate.isAtSameMomentAs(today)) {
      return DateFormat('HH:mm').format(timestamp);
    } else {
      return DateFormat('MMM dd, HH:mm').format(timestamp);
    }
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    ChatMessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum ChatMessageType {
  text,
  explanation,
  error,
  system,
  loading,
}

extension ChatMessageTypeExtension on ChatMessageType {
  String get displayName {
    switch (this) {
      case ChatMessageType.text:
        return 'Text';
      case ChatMessageType.explanation:
        return 'Explanation';
      case ChatMessageType.error:
        return 'Error';
      case ChatMessageType.system:
        return 'System';
      case ChatMessageType.loading:
        return 'Loading';
    }
  }

  bool get isFromUser {
    return this == ChatMessageType.text;
  }

  bool get isFromAI {
    return this == ChatMessageType.explanation || this == ChatMessageType.text;
  }
}
