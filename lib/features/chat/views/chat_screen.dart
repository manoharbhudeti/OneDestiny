import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_search_bar.dart';

class ChatConversation {
  final String id;
  final String vendorName;
  final String vendorCategory;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String avatarUrl;

  const ChatConversation({
    required this.id,
    required this.vendorName,
    required this.vendorCategory,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.avatarUrl,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<ChatConversation> _conversations = const [
    ChatConversation(
      id: 'c_1',
      vendorName: 'Lens & Light Studio',
      vendorCategory: 'Photography',
      lastMessage: 'Sure Manohar! We have Oct 24th available for your wedding shoot.',
      time: '10:42 AM',
      unreadCount: 2,
      avatarUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=200&q=80',
    ),
    ChatConversation(
      id: 'c_2',
      vendorName: 'Destiny Grand Wedding',
      vendorCategory: 'Wedding Planning',
      lastMessage: 'The stage floral decor layout proposal has been sent to your email.',
      time: 'Yesterday',
      unreadCount: 1,
      avatarUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=200&q=80',
    ),
    ChatConversation(
      id: 'c_3',
      vendorName: 'Royal Culinary Caterers',
      vendorCategory: 'Catering',
      lastMessage: 'We can arrange a menu tasting session this Saturday at 4 PM.',
      time: 'Aug 1',
      unreadCount: 0,
      avatarUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=200&q=80',
    ),
    ChatConversation(
      id: 'c_4',
      vendorName: 'Sonic Bass DJ & Sound',
      vendorCategory: 'DJ Services',
      lastMessage: 'Thanks for booking! Playlist preferences received.',
      time: 'Jul 28',
      unreadCount: 0,
      avatarUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=200&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: CustomSearchBar(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _conversations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _conversations[index];
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Chat with ${item.vendorName}', style: AppTypography.description(context)),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  item.avatarUrl,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
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
                                            style: AppTypography.subtitle(context).copyWith(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          item.time,
                                          style: AppTypography.description(context, isSecondary: true).copyWith(
                                            fontSize: 11,
                                          ),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
