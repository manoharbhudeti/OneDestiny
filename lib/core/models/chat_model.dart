class ChatConversationModel {
  final String id;
  final String vendorId;
  final String vendorName;
  final String vendorCategory;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String avatarUrl;

  const ChatConversationModel({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.vendorCategory,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.avatarUrl,
  });

  ChatConversationModel copyWith({
    String? id,
    String? vendorId,
    String? vendorName,
    String? vendorCategory,
    String? lastMessage,
    String? time,
    int? unreadCount,
    String? avatarUrl,
  }) {
    return ChatConversationModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      vendorCategory: vendorCategory ?? this.vendorCategory,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      unreadCount: unreadCount ?? this.unreadCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String text;
  final String time;
  final bool isMine;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.time,
    required this.isMine,
  });
}
