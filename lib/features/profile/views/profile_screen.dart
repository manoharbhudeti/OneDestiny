import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/booking_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/image_editor_screen.dart';
import '../../../core/widgets/location_picker_sheet.dart';
import '../../auth/views/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const ProfileScreen({
    super.key,
    required this.themeModeNotifier,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appState = AppStateScope.of(context);
    final profile = appState.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Profile & Settings', style: AppTypography.heading(context)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _sectionDecoration(cardBg, borderColor, isDark),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar with Edit Image Camera Badge
                      Stack(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.accentGold, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _buildProfileAvatarImage(profile.avatarUrl),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () => _openImageEditor(context, profile.avatarUrl),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBurgundy,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.accentGold, width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black38, blurRadius: 4),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 13,
                                  color: AppColors.accentGoldLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 16),

                      // Profile Info: Name, Mobile (Read-Only)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: AppTypography.subtitle(context).copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 13, color: AppColors.accentGold),
                                const SizedBox(width: 4),
                                Text(
                                  profile.mobile,
                                  style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.email_outlined, size: 13, color: AppColors.accentGold),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    profile.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Edit Profile Details Button
                      OutlinedButton(
                        onPressed: () => _showEditProfileModal(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accentGold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        child: const Text('Edit', style: TextStyle(fontSize: 12, color: AppColors.accentGold)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Divider(color: borderColor, height: 1),
                  const SizedBox(height: 12),

                  // Location Field & Edit Location Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: AppColors.accentGold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: AppTypography.description(context, isSecondary: true).copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    appState.activeLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.subtitle(context).copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _openLocationPicker(context, appState.activeLocation),
                        icon: const Icon(Icons.edit_location_alt_rounded, size: 14, color: AppColors.accentGold),
                        label: const Text(
                          'Edit Location',
                          style: TextStyle(fontSize: 12, color: AppColors.accentGold, fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('My Account', style: AppTypography.subtitle(context).copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              decoration: _sectionDecoration(cardBg, borderColor, isDark),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long_rounded, color: AppColors.accentGold),
                    title: Text('Booking & Order History', style: AppTypography.subtitle(context).copyWith(fontSize: 14)),
                    subtitle: Text('View past and upcoming reservations', style: AppTypography.description(context, isSecondary: true)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showBookingHistoryModal(context),
                  ),
                  Divider(height: 1, color: borderColor),
                  SwitchListTile(
                    secondary: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    title: Text('Push Notifications', style: AppTypography.subtitle(context).copyWith(fontSize: 14)),
                    subtitle: Text('Event reminders & booking alerts', style: AppTypography.description(context, isSecondary: true)),
                    value: profile.notificationsEnabled,
                    activeTrackColor: primaryColor,
                    onChanged: AppStateScope.read(context).setNotificationsEnabled,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Preferences & Settings', style: AppTypography.subtitle(context).copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              decoration: _sectionDecoration(cardBg, borderColor, isDark),
              child: Column(
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: widget.themeModeNotifier,
                    builder: (context, currentMode, _) {
                      return SwitchListTile(
                        secondary: Icon(
                          isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                          color: primaryColor,
                        ),
                        title: Text('Dark Theme', style: AppTypography.subtitle(context).copyWith(fontSize: 14)),
                        subtitle: Text(
                          isDark ? 'Dark mode enabled' : 'Light mode enabled',
                          style: AppTypography.description(context, isSecondary: true),
                        ),
                        value: isDark,
                        activeTrackColor: primaryColor,
                        onChanged: (value) {
                          widget.themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                        },
                      );
                    },
                  ),
                  Divider(height: 1, color: borderColor),
                  ListTile(
                    leading: Icon(Icons.help_outline_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    title: Text('Help & Support', style: AppTypography.subtitle(context).copyWith(fontSize: 14)),
                    subtitle: Text('Concierge line, FAQs & Live Support', style: AppTypography.description(context, isSecondary: true)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showHelpSupportModal(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text(
                  'Log Out',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: const Text('Sign out of your OneDestiny account', style: TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.error),
                onTap: () => _showLogoutDialog(context),
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: Column(
                children: [
                  Opacity(
                    opacity: isDark ? 0.85 : 0.75,
                    child: Image.asset(
                      'assets/images/one_destiny_logo_transparent.png',
                      height: 36,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/one_destiny_logo.png',
                        height: 36,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0+1 • Premium Experience',
                    style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _sectionDecoration(Color cardBg, Color borderColor, bool isDark) {
    return BoxDecoration(
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
    );
  }
  Future<String?> _pickImageFromSource(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        return image.path;
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
    return null;
  }

  Widget _buildProfileAvatarImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, color: Colors.white),
        ),
      );
    } else if (url.startsWith('data:image/')) {
      try {
        final base64Str = url.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
        );
      } catch (_) {
        return const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, color: Colors.white),
        );
      }
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, color: Colors.white),
        ),
      );
    }
  }

  Future<void> _openImageEditor(BuildContext context, String currentAvatarUrl) async {
    final appState = AppStateScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Show Gallery / Camera / URL Selection Sheet
    final selectedSourceUrl = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgSurface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        final urlController = TextEditingController(text: currentAvatarUrl);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: 18),
              Text(
                'Choose Profile Photo Source',
                style: AppTypography.heading(context).copyWith(fontSize: 19),
              ),
              const SizedBox(height: 6),
              Text(
                'Select a photo from Gallery, Camera, or Image Link',
                style: AppTypography.description(context, isSecondary: true),
              ),
              const SizedBox(height: 20),

              // Gallery Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.accentGold),
                ),
                title: const Text('Choose from Device Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Select existing photo from phone gallery'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final path = await _pickImageFromSource(ImageSource.gallery);
                  if (path != null && context.mounted) {
                    Navigator.pop(context, path);
                  }
                },
              ),

              const Divider(height: 1),

              // Camera Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBurgundy.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.accentGold),
                ),
                title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Capture new photo with camera'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final path = await _pickImageFromSource(ImageSource.camera);
                  if (path != null && context.mounted) {
                    Navigator.pop(context, path);
                  }
                },
              ),

              const Divider(height: 1),

              // Custom URL Input Option
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: urlController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Or enter image URL link...',
                          prefixIcon: const Icon(Icons.link_rounded, color: AppColors.accentGold, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (urlController.text.trim().isNotEmpty) {
                          Navigator.pop(context, urlController.text.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBurgundy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      child: const Text('Use', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedSourceUrl == null || !mounted) return;

    // Open 1:1 Image Cropper Screen with Selected Image
    final editedImageUrl = await navigator.push<String>(
      MaterialPageRoute(
        builder: (_) => ImageEditorScreen(currentImageUrl: selectedSourceUrl),
      ),
    );

    if (editedImageUrl != null && mounted) {
      appState.updateProfileAvatar(editedImageUrl);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.darkPrimaryBurgundy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('Profile photo updated successfully!'),
        ),
      );
    }
  }

  void _openLocationPicker(BuildContext context, String currentLocation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPickerBottomSheet(
        currentSelection: currentLocation,
        onLocationSelected: (locationResult) {
          AppStateScope.read(context).updateLocation(locationResult);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.darkPrimaryBurgundy,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text('Location updated to ${locationResult.formattedAddress}'),
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileModal(BuildContext context) {
    final profile = AppStateScope.read(context).profile;
    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(text: profile.email);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgSurface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SheetHandle(),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Edit Profile Details', style: AppTypography.heading(context).copyWith(fontSize: 19)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ProfileTextField(
                    controller: nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    borderColor: borderColor,
                    validatorText: 'Please enter your name',
                  ),
                  const SizedBox(height: 14),
                  _ProfileTextField(
                    controller: emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    borderColor: borderColor,
                    keyboardType: TextInputType.emailAddress,
                    validatorText: 'Please enter email address',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          AppStateScope.read(context).updateProfile(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.darkPrimaryBurgundy,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              content: const Text('Profile details updated successfully!'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBurgundy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBookingHistoryModal(BuildContext context) {
    final bookings = AppStateScope.read(context).bookings;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgSurface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Booking & Order History', style: AppTypography.heading(context).copyWith(fontSize: 19)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: bookings.isEmpty
                    ? Center(child: Text('No bookings yet', style: AppTypography.subtitle(context)))
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: bookings.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _BookingHistoryTile(booking: bookings[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgSurface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: 18),
              Text('Help & Support Concierge', style: AppTypography.heading(context).copyWith(fontSize: 19)),
              const SizedBox(height: 8),
              Text(
                'Need assistance with your event booking? Our dedicated OneDestiny concierge team is available 24/7.',
                style: AppTypography.description(context, isSecondary: true),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.headset_mic_rounded, color: AppColors.accentGold),
                title: const Text('Live Concierge Chat'),
                subtitle: const Text('Chat with an event planning specialist'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.phone_in_talk_rounded, color: AppColors.accentGold),
                title: Text('Toll-Free Support Line'),
                subtitle: Text('+91 1800 123 4567'),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.mail_outline_rounded, color: AppColors.accentGold),
                title: Text('Email Support'),
                subtitle: Text('support@onedestiny.com'),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error),
              SizedBox(width: 10),
              Text('Log Out'),
            ],
          ),
          content: const Text('Are you sure you want to log out of your OneDestiny account?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await AuthService.instance.logout();
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(themeModeNotifier: widget.themeModeNotifier),
                  ),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.darkPrimaryBurgundy,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: const Text('Logged out successfully.'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color borderColor;
  final TextInputType? keyboardType;
  final String validatorText;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.borderColor,
    required this.validatorText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.accentGold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? validatorText : null,
    );
  }
}

class _BookingHistoryTile extends StatelessWidget {
  final BookingModel booking;

  const _BookingHistoryTile({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = booking.status == 'CONFIRMED' ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.warmIvory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBurgundy.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.accentGold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.title, style: AppTypography.subtitle(context).copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  '${booking.category} • ${booking.dateLabel}',
                  style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(booking.amount, style: AppTypography.subtitle(context).copyWith(fontSize: 14, color: AppColors.accentGold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
