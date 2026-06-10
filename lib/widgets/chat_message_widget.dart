import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:revive_sunnah_reminder/models/chat_message.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(context),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context),
                const SizedBox(height: 4),
                _buildMessageInfo(context),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            _buildUserAvatar(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.mosque_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.accent10,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.accent,
        size: 20,
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: _getMessageDecoration(),
        child: _buildMessageContent(context),
      ),
    );
  }

  BoxDecoration _getMessageDecoration() {
    if (message.isUser) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(6),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else {
      // AI message styling based on type
      Color backgroundColor;
      Color borderColor;

      switch (message.type) {
        case ChatMessageType.error:
          backgroundColor = AppColors.errorLight;
          borderColor = AppColors.error.withAlpha(51);
          break;
        case ChatMessageType.system:
          backgroundColor = AppColors.info.withAlpha(25);
          borderColor = AppColors.info.withAlpha(51);
          break;
        default:
          backgroundColor = AppColors.dominantSurface;
          borderColor = AppColors.secondary15;
      }

      return BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
  }

  Widget _buildMessageContent(BuildContext context) {
    final textColor = message.isUser ? Colors.white : _getContentTextColor();

    // Use markdown for AI responses to support formatting
    if (!message.isUser && message.content.contains('**')) {
      return MarkdownBody(
        data: message.content,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: textColor,
            fontSize: 16,
            height: 1.5,
          ),
          strong: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
          em: TextStyle(
            color: textColor,
            fontStyle: FontStyle.italic,
          ),
          blockquote: TextStyle(
            color: textColor.withAlpha(179),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Text(
      message.content,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        height: 1.5,
        fontWeight: message.isUser ? FontWeight.w500 : FontWeight.w400,
      ),
    );
  }

  Color _getContentTextColor() {
    switch (message.type) {
      case ChatMessageType.error:
        return AppColors.error;
      case ChatMessageType.system:
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildMessageInfo(BuildContext context) {
    return Row(
      mainAxisAlignment:
          message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Text(
          message.formattedTime,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
        ),
        if (message.isUser) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.check_rounded,
            size: 14,
            color: AppColors.textTertiary,
          ),
        ],
        if (!message.isUser && message.metadata?['tokens_used'] != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary05,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${message.metadata!['tokens_used']} tokens',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
