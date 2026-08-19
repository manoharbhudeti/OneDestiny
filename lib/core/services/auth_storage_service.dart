import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

class AuthStorageService {
  AuthStorageService._();
  static final AuthStorageService instance = AuthStorageService._();

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserAvatar = 'user_avatar';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyFavorites = 'favorite_vendor_ids';
  static const String _keyActiveLocation = 'active_location';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _getPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveAuthData({
    required String token,
    required int userId,
    required String name,
    required String email,
    String? phone,
    String role = 'User',
    String? avatarUrl,
  }) async {
    final prefs = await _getPrefs;
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserEmail, email);
    if (phone != null) await prefs.setString(_keyUserPhone, phone);
    await prefs.setString(_keyUserRole, role);
    if (avatarUrl != null) await prefs.setString(_keyUserAvatar, avatarUrl);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<String?> getToken() async {
    final prefs = await _getPrefs;
    return prefs.getString(_keyToken);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _getPrefs;
    return (prefs.getBool(_keyIsLoggedIn) ?? false) && (prefs.getString(_keyToken) != null);
  }

  Future<UserProfileModel?> getSavedProfile() async {
    final prefs = await _getPrefs;
    final name = prefs.getString(_keyUserName);
    if (name == null) return null;

    return UserProfileModel(
      name: name,
      email: prefs.getString(_keyUserEmail) ?? '',
      mobile: prefs.getString(_keyUserPhone) ?? '',
      avatarUrl: prefs.getString(_keyUserAvatar) ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      notificationsEnabled: prefs.getBool(_keyNotificationsEnabled) ?? true,
    );
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? mobile,
    String? avatarUrl,
    bool? notificationsEnabled,
  }) async {
    final prefs = await _getPrefs;
    if (name != null) await prefs.setString(_keyUserName, name);
    if (email != null) await prefs.setString(_keyUserEmail, email);
    if (mobile != null) await prefs.setString(_keyUserPhone, mobile);
    if (avatarUrl != null) await prefs.setString(_keyUserAvatar, avatarUrl);
    if (notificationsEnabled != null) {
      await prefs.setBool(_keyNotificationsEnabled, notificationsEnabled);
    }
  }

  Future<int?> getUserId() async {
    final prefs = await _getPrefs;
    return prefs.getInt(_keyUserId);
  }

  Future<Set<String>> getFavoriteVendorIds() async {
    final prefs = await _getPrefs;
    final list = prefs.getStringList(_keyFavorites) ?? [];
    return list.toSet();
  }

  Future<void> saveFavoriteVendorIds(Set<String> ids) async {
    final prefs = await _getPrefs;
    await prefs.setStringList(_keyFavorites, ids.toList());
  }

  Future<String?> getSavedLocation() async {
    final prefs = await _getPrefs;
    return prefs.getString(_keyActiveLocation);
  }

  Future<void> saveLocation(String location) async {
    final prefs = await _getPrefs;
    await prefs.setString(_keyActiveLocation, location);
  }

  Future<void> clearAuth() async {
    final prefs = await _getPrefs;
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserRole);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
