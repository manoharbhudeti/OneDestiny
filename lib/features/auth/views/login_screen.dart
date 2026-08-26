import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../main/views/main_navigation_screen.dart';
import 'otp_verification_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const LoginScreen({
    super.key,
    required this.themeModeNotifier,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _agreed = false;
  bool _loading = false;
  bool _usePassword = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_agreed) {
      _showSnack('Please agree to Privacy Policy and Terms');
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      _showSnack('Please enter a valid 10-digit mobile number');
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await AuthService.instance.sendPhoneOtp(phone);
      if (!mounted) return;
      setState(() => _loading = false);

      if (res.success) {
        _showSnack(res.message.isNotEmpty ? res.message : 'OTP sent successfully!');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              themeModeNotifier: widget.themeModeNotifier,
              phone: phone,
              isEmail: false,
            ),
          ),
        );
      } else {
        _showSnack(res.errors.isNotEmpty ? res.errors.first : (res.message.isNotEmpty ? res.message : 'Failed to send OTP. Please try again.'));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('An error occurred. Please try again.');
    }
  }

  Future<void> _loginWithPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please enter your email and password');
      return;
    }

    if (!_agreed) {
      _showSnack('Please agree to Privacy Policy and Terms');
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await AuthService.instance.login(email: email, password: password);
      if (!mounted) return;
      setState(() => _loading = false);

      if (res.success) {
        // Refresh app state with user profile
        AppStateScope.read(context).refreshProfile();
        AppStateScope.read(context).refreshBookings();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainNavigationScreen(themeModeNotifier: widget.themeModeNotifier),
          ),
          (route) => false,
        );
      } else {
        _showSnack(res.errors.isNotEmpty ? res.errors.first : (res.message.isNotEmpty ? res.message : 'Invalid credentials. Please try again.'));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Login failed. Please check your connection.');
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
    final logoWidth = (MediaQuery.of(context).size.width * 0.55).clamp(180.0, 260.0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 36),

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

              const SizedBox(height: 28),

              // Screen Title
              Text(
                'Welcome Back',
                style: AppTypography.heading(context).copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please login to your OneDestiny account',
                style: AppTypography.description(context, isSecondary: true),
              ),

              const SizedBox(height: 28),

              // OTP / Password Segmented Tab Toggle
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFF0E4DE),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _ToggleTab(
                      label: 'OTP Login',
                      selected: !_usePassword,
                      onTap: () => setState(() => _usePassword = false),
                    ),
                    _ToggleTab(
                      label: 'Password',
                      selected: _usePassword,
                      onTap: () => setState(() => _usePassword = true),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Input Fields
              if (!_usePassword) ...[
                _AuthTextField(
                  hint: 'Enter your Mobile Number',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ] else ...[
                _AuthTextField(
                  hint: 'Enter your Email Address',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _AuthTextField(
                  hint: 'Enter your Password',
                  controller: _passwordController,
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
              ],

              const SizedBox(height: 18),

              // Terms & Privacy Checkbox
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                        children: const [
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Primary Login / Send OTP CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : (_usePassword ? _loginWithPassword : _sendOtp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          _usePassword ? 'LOGIN' : 'SEND OTP',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 28),

              // Signup Navigation Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTypography.description(context, isSecondary: true),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignupScreen(themeModeNotifier: widget.themeModeNotifier),
                        ),
                      );
                    },
                    child: const Text(
                      'Signup',
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Skip & Browse as Guest Option
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainNavigationScreen(themeModeNotifier: widget.themeModeNotifier),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Continue as Guest →',
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBurgundy : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;

  const _AuthTextField({
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
