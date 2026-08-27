class UserProfileModel {
  final String name;
  final String mobile;
  final String email;
  final String avatarUrl;
  final bool notificationsEnabled;

  const UserProfileModel({
    required this.name,
    required this.mobile,
    required this.email,
    required this.avatarUrl,
    this.notificationsEnabled = true,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['fullName']?.toString() ?? json['name']?.toString() ?? 'User',
      mobile: json['phoneNumber']?.toString() ?? json['phone']?.toString() ?? json['mobile']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['profileImageUrl']?.toString() ??
          json['avatarUrl']?.toString() ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      notificationsEnabled: json['notificationsEnabled'] as bool? ??
          json['pushNotificationsEnabled'] as bool? ??
          true,
    );
  }

  UserProfileModel copyWith({
    String? name,
    String? mobile,
    String? email,
    String? avatarUrl,
    bool? notificationsEnabled,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
