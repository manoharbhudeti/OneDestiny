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

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    final rawTime = json['lastMessageTime']?.toString() ?? json['updatedAt']?.toString();
    String displayTime = 'Now';
    if (rawTime != null) {
      try {
        final dt = DateTime.parse(rawTime).toLocal();
        final now = DateTime.now();
        if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
          final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
          final ampm = dt.hour >= 12 ? 'PM' : 'AM';
          final min = dt.minute.toString().padLeft(2, '0');
          displayTime = '$hour:$min $ampm';
        } else if (now.difference(dt).inDays < 2 && dt.day == now.day - 1) {
          displayTime = 'Yesterday';
        } else {
          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          displayTime = '${months[dt.month - 1]} ${dt.day}';
        }
      } catch (_) {
        displayTime = 'Recent';
      }
    }

    final avatar = json['vendorAvatarUrl']?.toString() ??
        json['avatarUrl']?.toString() ??
        json['coverImageUrl']?.toString() ??
        '';

    return ChatConversationModel(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendorProfileId']?.toString() ?? json['vendorId']?.toString() ?? '',
      vendorName: json['vendorBusinessName']?.toString() ?? json['vendorName']?.toString() ?? 'Vendor',
      vendorCategory: json['categoryName']?.toString() ?? json['vendorCategory']?.toString() ?? 'Wedding Services',
      lastMessage: json['lastMessage']?.toString() ?? 'Start conversation...',
      time: displayTime,
      unreadCount: json['unreadCount'] as int? ?? 0,
      avatarUrl: avatar.isNotEmpty
          ? avatar
          : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    );
  }

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

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {int? currentUserId}) {
    final rawTime = json['sentAt']?.toString() ?? json['createdAt']?.toString();
    String displayTime = 'Now';
    if (rawTime != null) {
      try {
        final dt = DateTime.parse(rawTime).toLocal();
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        final min = dt.minute.toString().padLeft(2, '0');
        displayTime = '$hour:$min $ampm';
      } catch (_) {
        displayTime = 'Now';
      }
    }

    final isMine = json['isMine'] as bool? ??
        (currentUserId != null && json['senderId'] == currentUserId);

    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      text: json['text']?.toString() ?? json['content']?.toString() ?? '',
      time: displayTime,
      isMine: isMine,
    );
  }
}
