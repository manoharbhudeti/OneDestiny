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
