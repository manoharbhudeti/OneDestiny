import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/chat_model.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  Timer? _poll;
  int _seenCount = -1;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync(markRead: true));
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _sync());
  }

  Future<void> _sync({bool markRead = false}) async {
    if (!mounted) return;
    final appState = AppStateScope.read(context);
    final conversation = appState.conversationById(widget.conversationId);
    final vendorId = int.tryParse(conversation?.vendorId ?? widget.conversationId);
    await appState.refreshMessages(widget.conversationId, vendorId: vendorId);
    if (!mounted) return;
    final count = appState.messagesFor(widget.conversationId).length;
    if (markRead || (count != _seenCount && _seenCount >= 0)) {
      await appState.markConversationRead(widget.conversationId, vendorId: vendorId);
    }
    _seenCount = count;
  }

  Future<void> _send() async {
    final text = _messageController.text;
    if (text.trim().isEmpty || _sending) return;
    final conversation = AppStateScope.read(context).conversationById(widget.conversationId);
    setState(() => _sending = true);
    _messageController.clear();
    final ok = await AppStateScope.read(context).sendMessage(
      widget.conversationId,
      text,
      vendorId: int.tryParse(conversation?.vendorId ?? ''),
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (!ok) {
      _messageController.text = text;
      _messageController.selection = TextSelection.collapsed(offset: text.length);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message could not be sent. Please try again.')),
      );
    } else {
      _seenCount = AppStateScope.read(context).messagesFor(widget.conversationId).length;
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final conversation = appState.conversationById(widget.conversationId);
    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(child: Text('Conversation not found')),
      );
    }
    final messages = appState.messagesFor(widget.conversationId);
    final loadingMessages = appState.isLoadingMessages(widget.conversationId) && messages.isEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _DetailAvatar(url: conversation.avatarUrl, size: 38),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.vendorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle(context).copyWith(fontSize: 15),
                  ),
                  Text(
                    conversation.vendorCategory,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: loadingMessages
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accentGold))
                  : messages.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                            Icon(Icons.chat_bubble_outline_rounded, size: 42, color: AppColors.accentGold.withValues(alpha: 0.8)),
                            const SizedBox(height: 12),
                            Text(
                              'Send a message to ${conversation.vendorName}',
                              textAlign: TextAlign.center,
                              style: AppTypography.description(context, isSecondary: true),
                            ),
                          ],
                        )
                      : ListView.separated(
                          reverse: true,
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                          itemCount: messages.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final message = messages[messages.length - 1 - index];
                            return _MessageBubble(message: message);
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      style: AppTypography.description(context),
                      decoration: InputDecoration(
                        hintText: 'Message ${conversation.vendorName}',
                        hintStyle: AppTypography.description(context, isSecondary: true),
                        filled: true,
                        fillColor: isDark ? AppColors.darkCardBg : AppColors.warmIvory,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    style: IconButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(48, 48),
                    ),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailAvatar extends StatelessWidget {
  final String url;
  final double size;

  const _DetailAvatar({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: AppColors.accentGold.withValues(alpha: 0.2),
      child: Icon(Icons.storefront_rounded, size: size * 0.5, color: AppColors.accentGold),
    );
    if (url.isEmpty) return SizedBox(width: size, height: size, child: fallback);
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size, child: fallback),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bubbleColor = message.isMine
        ? primaryColor
        : (isDark ? AppColors.darkCardBg : AppColors.warmIvory);
    final textColor = message.isMine
        ? Colors.white
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    final alignment = message.isMine ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMine ? 16 : 4),
            bottomRight: Radius.circular(message.isMine ? 4 : 16),
          ),
          border: message.isMine
              ? null
              : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: message.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTypography.description(context, customColor: textColor).copyWith(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: AppTypography.description(
                context,
                customColor: message.isMine
                    ? Colors.white.withValues(alpha: 0.75)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ).copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
