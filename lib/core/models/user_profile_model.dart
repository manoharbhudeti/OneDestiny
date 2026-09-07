class UserProfileModel {
  final String name;
  final String mobile;
  final String email;
  final String avatarUrl;
  final String location;
  final bool notificationsEnabled;

  const UserProfileModel({
    required this.name,
    required this.mobile,
    required this.email,
    required this.avatarUrl,
    this.location = '',
    this.notificationsEnabled = true,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['businessName']?.toString() ??
        json['fullName']?.toString() ??
        json['name']?.toString() ??
        '';
    final name = rawName.trim().isNotEmpty ? rawName.trim() : 'User';

    final rawPhone = json['businessPhone']?.toString() ??
        json['phoneNumber']?.toString() ??
        json['phone']?.toString() ??
        json['mobile']?.toString() ??
        '';

    final rawEmail = json['businessEmail']?.toString() ??
        json['email']?.toString() ??
        '';

    final rawAvatar = json['photoUrl']?.toString() ??
        json['profileImageUrl']?.toString() ??
        json['coverPhotoUrl']?.toString() ??
        json['avatarUrl']?.toString() ??
        '';

    final rawLocation = json['baseLocation']?.toString() ??
        json['location']?.toString() ??
        json['baseCityName']?.toString() ??
        json['cityName']?.toString() ??
        '';

    return UserProfileModel(
      name: name,
      mobile: rawPhone,
      email: rawEmail,
      avatarUrl: rawAvatar.isNotEmpty
          ? rawAvatar
          : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      location: rawLocation,
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
    String? location,
    bool? notificationsEnabled,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
