import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/network/api_response.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../main/views/main_navigation_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;
  final String phone;
  final String? email;
  final bool isEmail;
  final String? reqId;
  final bool isMsg91;

  final String? verificationId;
  final int pinLength;

  const OtpVerificationScreen({
    super.key,
    required this.themeModeNotifier,
    this.phone = '',
    this.email,
    this.verificationId,
    this.isEmail = false,
    this.reqId,
    this.isMsg91 = false,
    this.pinLength = 6,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final int _pinLength;
  late final List<TextEditingController> _pinControllers;
  late final List<FocusNode> _focusNodes;

  bool _loading = false;
  int _seconds = 30;
  Timer? _timer;
  String? _currentReqId;

  @override
  void initState() {
    super.initState();
    _currentReqId = widget.reqId;
    _pinLength = widget.pinLength;
    _pinControllers = List.generate(_pinLength, (_) => TextEditingController());
    _focusNodes = List.generate(_pinLength, (_) => FocusNode());
    _startTimer();
  }

  void _startTimer() {
    _seconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        if (mounted) {
          setState(() => _seconds--);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _pinControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _pinControllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otpCode.length != _pinLength) {
      _showSnack('Please enter full $_pinLength-digit OTP code');
      return;
    }

    setState(() => _loading = true);

    try {
      if (widget.isEmail) {
        final email = widget.email ?? '';
        final res = await AuthService.instance.verifyEmailOtp(email: email, otp: _otpCode);
        if (!mounted) return;
        setState(() => _loading = false);

        if (res.success) {
          AppStateScope.read(context).refreshProfile();
          AppStateScope.read(context).refreshBookings();
          _navigateToHome();
        } else {
          _showSnack(res.errors.isNotEmpty ? res.errors.first : (res.message.isNotEmpty ? res.message : 'Invalid OTP code.'));
        }
      } else if (widget.isMsg91 && _currentReqId != null && _currentReqId!.isNotEmpty) {
        // MSG91 OTP verification & backend token exchange
        final res = await AuthService.instance.loginWithMsg91Otp(
          reqId: _currentReqId!,
          otp: _otpCode,
          createIfNotExists: true,
        );
        if (!mounted) return;
        setState(() => _loading = false);

        if (res.success) {
          AppStateScope.read(context).refreshProfile();
          AppStateScope.read(context).refreshBookings();
          _navigateToHome();
        } else {
          _showSnack(res.errors.isNotEmpty ? res.errors.first : (res.message.isNotEmpty ? res.message : 'Invalid OTP code.'));
        }
      } else if (widget.verificationId != null) {
        final phone = widget.phone;
        final res = await AuthService.instance.firebasePhoneLogin(
          phone: phone,
          verificationId: widget.verificationId!,
          otp: _otpCode,
        );
        if (!mounted) return;
        setState(() => _loading = false);

        if (res.success) {
          AppStateScope.read(context).refreshProfile();
          AppStateScope.read(context).refreshBookings();
          _navigateToHome();
        } else {
          _showSnack(res.errors.isNotEmpty ? res.errors.first : (res.message.isNotEmpty ? res.message : 'Invalid OTP code.'));
        }
      } else {
        final phone = widget.phone;
        final res = await AuthService.instance.verifyPhoneOtp(phone, _otpCode);
        if (!mounted) return;
        setState(() => _loading = false);

        if (res.success) {
          AppStateScope.read(context).refreshProfile();
          AppStateScope.read(context).refreshBookings();
          _navigateToHome();
        } else {
          _showSnack(res.errors.isNotEmpty ? res.errors.first : (res.message.isNotEmpty ? res.message : 'Invalid OTP code.'));
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Verification failed. Please try again.');
    }
  }

  Future<void> _handleResend() async {
    if (_seconds > 0) return;
    for (final c in _pinControllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes.first.requestFocus();
    }
    _startTimer();

    try {
      if (widget.isEmail) {
        _showSnack('New OTP code sent to your email.');
      } else if (widget.isMsg91) {
        ApiResponse<String> res;
        if (_currentReqId != null && _currentReqId!.isNotEmpty) {
          res = await AuthService.instance.retryMsg91Otp(reqId: _currentReqId!);
          if (!res.success) {
            res = await AuthService.instance.sendMsg91Otp(widget.phone);
            if (res.success && res.data != null && res.data!.isNotEmpty) {
              _currentReqId = res.data;
            }
          }
        } else {
          res = await AuthService.instance.sendMsg91Otp(widget.phone);
          if (res.success && res.data != null && res.data!.isNotEmpty) {
            _currentReqId = res.data;
          }
        }
        if (mounted) {
          _showSnack(res.message.isNotEmpty ? res.message : 'OTP resent successfully!');
        }
      } else {
        final res = await AuthService.instance.sendPhoneOtp(widget.phone);
        if (mounted) {
          _showSnack(res.message.isNotEmpty ? res.message : 'OTP resent successfully!');
        }
      }
    } catch (_) {
      if (mounted) {
        _showSnack('Failed to resend OTP.');
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(themeModeNotifier: widget.themeModeNotifier),
      ),
      (route) => false,
    );
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
    final target = widget.isEmail ? (widget.email ?? '') : widget.phone;

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
              const SizedBox(height: 20),

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

              const SizedBox(height: 28),

              Text(
                'OTP Verification',
                style: AppTypography.heading(context).copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isEmail
                    ? 'Check your email! Please enter $_pinLength-digit OTP sent to\n$target'
                    : 'Please enter $_pinLength-digit code sent to\n$target',
                textAlign: TextAlign.center,
                style: AppTypography.description(context, isSecondary: true),
              ),

              const SizedBox(height: 36),

              // PIN Input Boxes Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = _pinLength == 6 ? 8.0 : 12.0;
                  final totalSpacing = spacing * (_pinLength - 1);
                  final boxWidth = ((constraints.maxWidth - totalSpacing) / _pinLength).clamp(36.0, 52.0);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pinLength, (index) {
                      return Container(
                        margin: EdgeInsets.only(right: index < _pinLength - 1 ? spacing : 0),
                        width: boxWidth,
                        height: 60,
                        child: Focus(
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.backspace) {
                              if (_pinControllers[index].text.isEmpty && index > 0) {
                                _pinControllers[index - 1].clear();
                                _focusNodes[index - 1].requestFocus();
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextField(
                            controller: _pinControllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGold,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              if (value.length > 1) {
                                final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                                if (digits.length >= 4) {
                                  // Pasted OTP code
                                  final startIndex = digits.length >= _pinLength ? 0 : index;
                                  for (int i = 0; i < digits.length && (startIndex + i) < _pinLength; i++) {
                                    _pinControllers[startIndex + i].text = digits[i];
                                  }
                                  final lastFilled = (startIndex + digits.length - 1).clamp(0, _pinLength - 1);
                                  if (_otpCode.length == _pinLength) {
                                    FocusScope.of(context).unfocus();
                                    _verifyOtp();
                                  } else if (lastFilled < _pinLength - 1) {
                                    _focusNodes[lastFilled + 1].requestFocus();
                                  }
                                  return;
                                } else if (digits.isNotEmpty) {
                                  // User replaced digit in already-filled box
                                  final lastChar = digits.substring(digits.length - 1);
                                  _pinControllers[index].text = lastChar;
                                  _pinControllers[index].selection =
                                      TextSelection.collapsed(offset: lastChar.length);
                                  if (index < _pinLength - 1) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                  if (_otpCode.length == _pinLength) {
                                    _verifyOtp();
                                  }
                                  return;
                                }
                              }

                              if (value.isNotEmpty) {
                                if (index < _pinLength - 1) {
                                  _focusNodes[index + 1].requestFocus();
                                } else {
                                  FocusScope.of(context).unfocus();
                                }
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }

                              if (_otpCode.length == _pinLength) {
                                _verifyOtp();
                              }
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? AppColors.darkCardBg : AppColors.warmIvory,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.accentGold, width: 2.0),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Resend OTP & Countdown Timer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _seconds == 0 ? _handleResend : null,
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: _seconds == 0 ? AppColors.accentGold : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '00:${_seconds.toString().padLeft(2, '0')}',
                    style: AppTypography.subtitle(context).copyWith(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Primary CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verifyOtp,
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
                          'VERIFY OTP',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0),
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
