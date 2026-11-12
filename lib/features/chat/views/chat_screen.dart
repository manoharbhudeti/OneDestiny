import 'dart:async';

import '../../../core/ui_states/ui_states.dart';
import 'package:flutter/material.dart';

import '../../../core/models/chat_model.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_search_bar.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const ChatScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with AutomaticKeepAliveClientMixin {
  Timer? _poll;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppStateScope.read(context).refreshConversations();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && _poll == null) {
      _poll = Timer.periodic(const Duration(seconds: 8), (_) {
        if (!mounted) return;
        AppStateScope.read(context).refreshConversations(silent: true);
      });
    } else if (!visible) {
      _poll?.cancel();
      _poll = null;
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appState = AppStateScope.of(context);
    final conversations = appState.filteredConversations;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Vendor Messages', style: AppTypography.heading(context)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: CustomSearchBar(onChanged: appState.updateChatSearch),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accentGold,
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                onRefresh: () => appState.refreshConversations(),
                child: Builder(
                  builder: (context) {
                    if ((appState.isLoadingChat || appState.isLoadingInitial) && conversations.isEmpty) {
                      return SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: SkeletonLoaderCard.conversationList(count: 5),
                      );
                    }
                    if (appState.chatError != null) {
                      return ErrorStateWidget(
                        customMessage: appState.chatError,
                        onRetry: () => appState.refreshConversations(),
                      );
                    }
                    if (conversations.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                          EmptyStateWidget.noConversations(
                            onFindVendors: () {
                              widget.onNavigateToTab?.call(1);
                            },
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: conversations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _ConversationTile(item: conversations[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  final String url;
  final double size;

  const _ChatAvatar({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: AppColors.accentGold.withValues(alpha: 0.2),
      child: Icon(Icons.storefront_rounded, size: size * 0.46, color: AppColors.accentGold),
    );
    if (url.isEmpty) {
      return SizedBox(width: size, height: size, child: fallback);
    }
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size, child: fallback),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversationModel item;

  const _ConversationTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final hasUnread = item.unreadCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(conversationId: item.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _ChatAvatar(url: item.avatarUrl, size: 52),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.vendorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.subtitle(context).copyWith(fontSize: 15),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.time,
                            style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.description(
                                context,
                                isSecondary: !hasUnread,
                              ).copyWith(
                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${item.unreadCount}',
                                style: AppTypography.buttonText(context).copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
