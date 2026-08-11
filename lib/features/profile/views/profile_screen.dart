import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

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

  // Editable Profile User Data State
  String _userName = 'Manohar';
  String _userMobile = '+91 98765 43210';
  String _userEmail = 'manohar@onedestiny.com';

  bool _notificationsEnabled = true;

  void _showEditProfileModal(BuildContext context) {
    final nameController = TextEditingController(text: _userName);
    final mobileController = TextEditingController(text: _userMobile);
    final emailController = TextEditingController(text: _userEmail);
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Edit Profile Details', style: AppTypography.heading(context).copyWith(fontSize: 19)),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Full Name Field
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.accentGold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 14),

                  // Mobile Number Field
                  TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.accentGold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter mobile number' : null,
                  ),
                  const SizedBox(height: 14),

                  // Email Field
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.accentGold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter email address' : null,
                  ),
                  const SizedBox(height: 24),

                  // Save Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            _userName = nameController.text.trim();
                            _userMobile = mobileController.text.trim();
                            _userEmail = emailController.text.trim();
                          });
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgSurface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

        final mockBookings = [
          {
            'title': 'Lens & Light Studio',
            'category': 'Wedding Photography',
            'date': '15 Oct 2026',
            'amount': '₹18,000',
            'status': 'Confirmed',
          },
          {
            'title': 'Royal Culinary Caterers',
            'category': 'Buffet Catering',
            'date': '02 Dec 2026',
            'amount': '₹32,000',
            'status': 'Upcoming',
          },
          {
            'title': 'Aura Stage Decorators',
            'category': 'Flower Stage Setup',
            'date': '20 Aug 2026',
            'amount': '₹25,000',
            'status': 'Completed',
          },
        ];

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
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Booking & Order History', style: AppTypography.heading(context).copyWith(fontSize: 19)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: mockBookings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = mockBookings[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardBg : AppColors.warmIvory,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
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
                                Text(item['title']!, style: AppTypography.subtitle(context).copyWith(fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                  '${item['category']} • ${item['date']}',
                                  style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(item['amount']!, style: AppTypography.subtitle(context).copyWith(fontSize: 14, color: AppColors.accentGold)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['status']!,
                                  style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
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
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening OneDestiny Concierge Live Chat...')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone_in_talk_rounded, color: AppColors.accentGold),
                title: const Text('Toll-Free Support Line'),
                subtitle: const Text('+91 1800 123 4567'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.mail_outline_rounded, color: AppColors.accentGold),
                title: const Text('Email Support'),
                subtitle: const Text('support@onedestiny.com'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                },
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
          title: Row(
            children: const [
              Icon(Icons.logout_rounded, color: AppColors.error),
              SizedBox(width: 10),
              Text('Log Out'),
            ],
          ),
          content: const Text('Are you sure you want to log out of your OneDestiny account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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
        title: Text('Profile & Settings', style: AppTypography.heading(context)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // User Header Card with Edit Option
            Container(
              padding: const EdgeInsets.all(18),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'user-avatar',
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accentGold,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_userName, style: AppTypography.subtitle(context).copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(_userMobile, style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(_userEmail, style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12)),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showEditProfileModal(context),
                        icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.accentGold),
                        label: const Text('Edit', style: TextStyle(fontSize: 13, color: AppColors.accentGold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accentGold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account & Booking Options
            Text('My Account', style: AppTypography.subtitle(context).copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
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
                    value: _notificationsEnabled,
                    activeTrackColor: primaryColor,
                    onChanged: (val) {
                      setState(() {
                        _notificationsEnabled = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Preferences Section
            Text('Preferences & Settings', style: AppTypography.subtitle(context).copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
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
                        onChanged: (bool value) {
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

            // Logout Button Tile
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

            // Luxury Brand Footer Logo
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
}
