import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const SignupScreen({
    super.key,
    required this.themeModeNotifier,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _agreed = false;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _signup() {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showSnack('Please fill in all required fields');
      return;
    }

    if (_phoneCtrl.text.length != 10) {
      _showSnack('Please enter a valid 10-digit mobile number');
      return;
    }

    if (_passCtrl.text.length < 8) {
      _showSnack('Password must be at least 8 characters');
      return;
    }

    if (!_agreed) {
      _showSnack('Please agree to Privacy Policy and Terms');
      return;
    }

    setState(() => _loading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            themeModeNotifier: widget.themeModeNotifier,
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            isEmail: true,
          ),
        ),
      );
    });
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Brand Emblem Logo
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

              Text(
                'Create Account',
                style: AppTypography.heading(context).copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Join OneDestiny for premium wedding services',
                style: AppTypography.description(context, isSecondary: true),
              ),

              const SizedBox(height: 28),

              _SignupTextField(
                hint: 'Full Name (Required)',
                controller: _nameCtrl,
                icon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 14),

              _SignupTextField(
                hint: 'Email Address (Required)',
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              _SignupTextField(
                hint: 'Phone Number (Required)',
                controller: _phoneCtrl,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),

              const SizedBox(height: 14),

              _SignupTextField(
                hint: 'Password (Required)',
                controller: _passCtrl,
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.accentGold,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Minimum 8 characters',
                    style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Terms & Privacy Agreement
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreed,
                      onChanged: (v) => setState(() => _agreed = v ?? false),
                      activeColor: AppColors.primaryBurgundy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                        children: const [
                          TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
                          TextSpan(text: ' and '),
                          TextSpan(text: 'Terms', style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          'SEND OTP',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTypography.description(context, isSecondary: true),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignupTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;

  const _SignupTextField({
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      style: AppTypography.description(context),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.description(context, isSecondary: true),
        prefixIcon: Icon(icon, color: AppColors.accentGold, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark ? AppColors.darkCardBg : AppColors.warmIvory,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
        ),
      ),
    );
  }
}
