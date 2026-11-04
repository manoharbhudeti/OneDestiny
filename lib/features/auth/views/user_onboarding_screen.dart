import 'package:flutter/material.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/ui_states/ui_states.dart';
import '../../main/views/main_navigation_screen.dart';

class UserOnboardingScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;
  final String? initialName;
  final String? initialEmail;
  final String? phone;

  const UserOnboardingScreen({
    super.key,
    required this.themeModeNotifier,
    this.initialName,
    this.initialEmail,
    this.phone,
  });

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  String? _nameError;
  String? _emailError;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitOnboarding() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    final nameErr = FormFieldFeedback.validateRequired(name, 'Full name');
    final emailErr = FormFieldFeedback.validateEmail(email);

    if (nameErr != null || emailErr != null) {
      setState(() {
        _nameError = nameErr;
        _emailError = emailErr;
      });
      return;
    }

    setState(() {
      _nameError = null;
      _emailError = null;
      _loading = true;
    });

    try {
      final res = await AppStateScope.read(context).updateProfile(
        name: name,
        email: email,
        mobile: widget.phone,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (res.success) {
        await AuthStorageService.instance.setOnboarded(true);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.darkPrimaryBurgundy,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Text('Welcome to OneDestiny! Profile created successfully.'),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainNavigationScreen(themeModeNotifier: widget.themeModeNotifier),
          ),
          (route) => false,
        );
      } else {
        final errorMsg = res.errors.isNotEmpty
            ? res.errors.first
            : (res.message.isNotEmpty ? res.message : 'Failed to update profile. Please try again.');
        _showSnack(errorMsg);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Something went wrong. Please check your connection.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryBurgundy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoWidth = (MediaQuery.of(context).size.width * 0.50).clamp(160.0, 240.0);
    final bgSurface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Brand Emblem Logo Header
              Image.asset(
                'assets/images/one_destiny_logo_transparent.png',
                width: logoWidth,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/one_destiny_logo.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 24),

              // Badge indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, size: 16, color: AppColors.accentGold),
                    SizedBox(width: 6),
                    Text(
                      'ALMOST THERE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Title & Description
              Text(
                'Complete Your Profile',
                style: AppTypography.heading(context).copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your full name and email address to get started with OneDestiny.',
                textAlign: TextAlign.center,
                style: AppTypography.description(context, isSecondary: true),
              ),

              const SizedBox(height: 32),

              // Full Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Name',
                    style: AppTypography.caption(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: bgSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _nameError != null ? Colors.redAccent : borderColor,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, color: AppColors.accentGold, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'Enter your full name',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onChanged: (_) {
                              if (_nameError != null) setState(() => _nameError = null);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_nameError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _nameError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 18),

              // Email Address Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email Address',
                    style: AppTypography.caption(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: bgSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _emailError != null ? Colors.redAccent : borderColor,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined, color: AppColors.accentGold, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              hintText: 'Enter your email address',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onChanged: (_) {
                              if (_emailError != null) setState(() => _emailError = null);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_emailError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _emailError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 36),

              // Continue Button
              InlineLoadingButton(
                label: 'CONTINUE',
                isLoading: _loading,
                backgroundColor: AppColors.primaryBurgundy,
                foregroundColor: Colors.white,
                height: 52,
                borderRadius: 14,
                onPressed: _submitOnboarding,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
