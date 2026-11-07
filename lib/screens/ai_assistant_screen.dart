import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/xmum_animations.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hi! I\'m the XMUM AI Assistant. How can I help you navigate the campus today?',
      isUser: false,
    ),
  ];
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text,
        isUser: true,
      ));
      _isTyping = true;
    });

    _messageController.clear();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: _generateResponse(_messages[_messages.length - 2].text),
            isUser: false,
          ));
          _isTyping = false;
        });
      }
    });
  }

  String _generateResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('library')) {
      return 'The XMUM Library is located in A3 Block. It\'s open from 8 AM to 10 PM on weekdays and 9 AM to 6 PM on weekends.';
    } else if (lowerMessage.contains('canteen') || lowerMessage.contains('food')) {
      return 'There are several dining options on campus: LY3 Block (main canteen at 1st and 2nd floor), D6 Canteen (ground, 1st, 2nd floor), and LakeFront Café at Music Island.';
    } else if (lowerMessage.contains('parking')) {
      return 'Parking is available at the Southern Gate and Eastern Gate entrances.';
    } else if (lowerMessage.contains('block') || lowerMessage.contains('building')) {
      return 'The campus has several blocks: A1-A5 (lecture buildings), LY1-LY9 (student dorms), and D1-D5 (student dorms). Each block is clearly marked on the campus map.';
    } else if (lowerMessage.contains('map') || lowerMessage.contains('navigate')) {
      return 'You can use the campus map feature in the Navigation tab to find your way around. The map shows all buildings, facilities, and walking routes.';
    } else if (lowerMessage.contains('wifi') || lowerMessage.contains('internet')) {
      return 'Free WiFi is available throughout the campus. Connect to "XMUM-Student" network using your student credentials.';
    } else if (lowerMessage.contains('bus') || lowerMessage.contains('transport')) {
      return 'Campus shuttle buses run between the main gate and various blocks. The schedule is available at the main gate and student center.';
    } else {
      return 'I can help you with information about campus locations, facilities, parking, dining, and more. Try asking about the library, canteens, parking, or specific blocks!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: Text('XMUM AI Assistant', style: xmumFont(fontWeight: FontWeight.w700)),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: xmumPremiumGradient)),
        foregroundColor: kWhite,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessageBubble(_messages[index]);
                } else {
                  return _buildTypingIndicator();
                }
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: kAnimMedium,
      curve: kAnimCurve,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: xmumPremiumGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.smart_toy_rounded, size: 20, color: kWhite),
              ),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: message.isUser ? kPrimary : (isDark ? kDarkCard : kWhite),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                    bottomRight: Radius.circular(message.isUser ? 4 : 20),
                  ),
                  boxShadow: message.isUser ? null : const [kSoftShadow],
                ),
                child: Text(
                  message.text,
                  style: xmumFont(
                    color: message.isUser ? kWhite : (isDark ? kDarkText : kTextDark),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (message.isUser) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person_rounded, size: 20, color: kPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: xmumPremiumGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.smart_toy_rounded, size: 20, color: kWhite),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? kDarkCard : kWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [kSoftShadow],
            ),
            child: Row(
              children: [
                const XmumTypingDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? kDarkCard : kWhite,
        border: Border(
          top: BorderSide(color: isDark ? kDarkDivider : kDivider),
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: xmumFont(color: isDark ? kDarkText : kTextDark),
              decoration: InputDecoration(
                hintText: 'Ask about campus...',
                hintStyle: xmumFont(color: kTextMuted),
                filled: true,
                fillColor: isDark ? kDarkSurface : kGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: xmumPremiumGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send_rounded, color: kWhite),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
