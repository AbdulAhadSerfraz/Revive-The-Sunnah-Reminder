import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:revive_sunnah_reminder/providers/chat_provider.dart';
import 'package:revive_sunnah_reminder/providers/credits_provider.dart';
import 'package:revive_sunnah_reminder/widgets/chat_message_widget.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';

class FloatingChatWidget extends StatefulWidget {
  const FloatingChatWidget({
    super.key,
  });

  @override
  State<FloatingChatWidget> createState() => _FloatingChatWidgetState();
}

class _FloatingChatWidgetState extends State<FloatingChatWidget>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _bounceController;
  late AnimationController _expandController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeChat();
  }

  void _setupAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));

    // Start bounce animation after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bounceController.forward();
    });
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        if (!chatProvider.isInitialized) {
          chatProvider.initialize();
        }

        // Also ensure we have a current session
        if (chatProvider.isInitialized && !chatProvider.hasActiveSession) {
          chatProvider.startNewChat();
        }
      } catch (e) {
        // Handle any initialization errors gracefully
        debugPrint('FloatingChatWidget: Chat initialization error: $e');
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _bounceController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    // Ensure we have proper context and state
    if (!mounted) return;

    // Debug print to check if function is called
    debugPrint(
        'FloatingChatWidget: _toggleChat called, current _isExpanded: $_isExpanded');

    setState(() {
      _isExpanded = !_isExpanded;
    });

    debugPrint('FloatingChatWidget: _isExpanded is now: $_isExpanded');

    if (_isExpanded) {
      // Initialize chat if needed when opening
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      debugPrint(
          'FloatingChatWidget: ChatProvider hasActiveSession: ${chatProvider.hasActiveSession}');

      if (!chatProvider.hasActiveSession) {
        debugPrint('FloatingChatWidget: Starting new chat session');
        chatProvider.startNewChat();
      }

      _expandController.forward();
      _scrollToBottom();
    } else {
      _expandController.reverse();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final creditsProvider =
        Provider.of<CreditsProvider>(context, listen: false);

    _messageController.clear();

    await chatProvider.sendMessage(
      content: content,
      creditsProvider: creditsProvider,
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('FloatingChatWidget: build called, _isExpanded: $_isExpanded');
    return Consumer2<ChatProvider, CreditsProvider>(
      builder: (context, chatProvider, creditsProvider, child) {
        debugPrint('FloatingChatWidget: Consumer3 builder called');
        return Stack(
          children: [
            // Chat overlay - full screen when expanded
            if (_isExpanded)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleChat, // Tap outside to close
                  child: Container(
                    color: Colors.black.withValues(
                        alpha: 0.7), // Darker semi-transparent background
                    child: Center(
                      child: GestureDetector(
                        onTap:
                            () {}, // Prevent closing when tapping the chat window
                        child: AnimatedBuilder(
                          animation: _expandAnimation,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _expandAnimation,
                              child: Material(
                                elevation: 24,
                                borderRadius: BorderRadius.circular(24),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.92,
                                  height:
                                      MediaQuery.of(context).size.height * 0.85,
                                  child: _buildChatOverlay(
                                      chatProvider, creditsProvider),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Floating chat button - always on top
            Positioned(
              bottom: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimation.value,
                    child: _buildFloatingButton(creditsProvider),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingButton(CreditsProvider creditsProvider) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: () {
            debugPrint('FloatingChatWidget: Floating button tapped!');
            try {
              HapticFeedback.lightImpact();
            } catch (e) {
              // Ignore haptic feedback errors on devices that don't support it
            }
            _toggleChat();
          },
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // Main button content
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isExpanded ? Icons.close_rounded : Icons.chat_rounded,
                    key: ValueKey(_isExpanded),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

              // Credits indicator badge
              if (creditsProvider.hasCredits)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: creditsProvider.getCreditsColor(),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      creditsProvider.remainingCredits.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // No credits indicator
              if (!creditsProvider.hasCredits)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.block,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatOverlay(
      ChatProvider chatProvider, CreditsProvider creditsProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dominantSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            _buildChatHeader(creditsProvider),
            Expanded(child: _buildMessagesList(chatProvider)),
            _buildInputArea(chatProvider, creditsProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader(CreditsProvider creditsProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Islamic AI Assistant',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to help with Islamic guidance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Close button
          Material(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _toggleChat,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider chatProvider) {
    if (chatProvider.isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (chatProvider.error != null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Chat Service Error',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                chatProvider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final messages = chatProvider.messages;

    if (messages.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: AppColors.secondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Ask about Islamic teachings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try: "What is the importance of Salah?"',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ChatMessageWidget(
            message: messages[index],
          );
        },
      ),
    );
  }

  Widget _buildInputArea(
      ChatProvider chatProvider, CreditsProvider creditsProvider) {
    final hasCredits = creditsProvider.hasCredits;
    final isSending = chatProvider.isSending;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.dominantSurface,
        border: Border(
          top: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Credits indicator at top of input area
          if (!hasCredits || creditsProvider.isApproachingLimit)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: hasCredits
                    ? AppColors.warning.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasCredits
                      ? AppColors.warning.withValues(alpha: 0.3)
                      : AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasCredits ? Icons.warning_rounded : Icons.info_rounded,
                    color: hasCredits ? AppColors.warning : AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasCredits
                          ? 'Only ${creditsProvider.remainingCredits} questions remaining today'
                          : 'Daily limit reached (${creditsProvider.totalCredits} questions). Resets tomorrow.',
                      style: TextStyle(
                        color: hasCredits ? AppColors.warning : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Input field and send button
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.dominant,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    enabled: hasCredits && !isSending,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: hasCredits
                          ? 'Ask about Islamic teachings...'
                          : 'No credits remaining',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    onSubmitted: hasCredits && !isSending
                        ? (value) => _sendMessage(value)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Send button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: hasCredits && !isSending
                      ? LinearGradient(
                          colors: [
                            AppColors.secondary,
                            AppColors.secondaryLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            AppColors.textDisabled,
                            AppColors.textDisabled,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: hasCredits && !isSending
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: hasCredits && !isSending
                        ? () => _sendMessage(_messageController.text)
                        : null,
                    borderRadius: BorderRadius.circular(24),
                    child: Center(
                      child: isSending
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
