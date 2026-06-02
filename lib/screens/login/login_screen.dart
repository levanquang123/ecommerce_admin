import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../utility/constants.dart';
import 'provider/login_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: size.width > 600 ? 430 : size.width * 0.92,
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding * 2,
                      vertical: defaultPadding * 2.4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111522).withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 36,
                          offset: const Offset(0, 24),
                        ),
                        BoxShadow(
                          color: const Color(0xFF625BFF).withValues(alpha: 0.12),
                          blurRadius: 50,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Form(
                      key: loginProvider.loginFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SecurityBadge(),
                          const Gap(defaultPadding * 1.25),
                          Text(
                            'Admin Panel',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.6,
                                ),
                          ),
                          const Gap(8),
                          Text(
                            'Sign in to access the dashboard',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.52),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const Gap(defaultPadding * 1.25),
                          Center(
                            child: Container(
                              width: 42,
                              height: 2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7C7AFF),
                                    Color(0xFFA78BFA),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Gap(defaultPadding * 1.6),
                          _FieldLabel('Email'),
                          const Gap(8),
                          TextFormField(
                            controller: loginProvider.emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: const Color(0xFF8B7CFF),
                            decoration: _inputDecoration(
                              hintText: 'Enter your email',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex =
                                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const Gap(defaultPadding * 1.1),
                          _FieldLabel('Password'),
                          const Gap(8),
                          TextFormField(
                            controller: loginProvider.passwordCtrl,
                            obscureText: !_isPasswordVisible,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: const Color(0xFF8B7CFF),
                            decoration: _inputDecoration(
                              hintText: 'Enter your password',
                              prefixIcon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white.withValues(alpha: 0.48),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const Gap(defaultPadding * 1.55),
                          _LoginButton(
                            isLoading: loginProvider.isReadOnly,
                            onPressed: loginProvider.isReadOnly
                                ? null
                                : () => loginProvider.login(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.34),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.14),
      prefixIcon: Icon(prefixIcon, color: Colors.white.withValues(alpha: 0.44)),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      errorStyle: const TextStyle(color: Color(0xFFFF9AA2)),
      border: _inputBorder(Colors.white.withValues(alpha: 0.10)),
      enabledBorder: _inputBorder(Colors.white.withValues(alpha: 0.10)),
      focusedBorder: _inputBorder(const Color(0xFF8B7CFF)),
      errorBorder: _inputBorder(const Color(0xFFFF758F)),
      focusedErrorBorder: _inputBorder(const Color(0xFFFF758F)),
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF070A12),
        gradient: RadialGradient(
          center: Alignment(0.75, -0.58),
          radius: 0.9,
          colors: [
            Color(0x332A2C72),
            Color(0x00070A12),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -120,
            bottom: -80,
            child: Container(
              width: 430,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4F46E5).withValues(alpha: 0.24),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -180,
            top: -130,
            child: Container(
              width: 440,
              height: 440,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: CustomPaint(painter: _GridPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7C7AFF).withValues(alpha: 0.24),
              const Color(0xFF4F46E5).withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(color: const Color(0xFF7C7AFF).withValues(alpha: 0.38)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C7AFF).withValues(alpha: 0.25),
              blurRadius: 24,
            ),
          ],
        ),
        child: const Icon(
          Icons.admin_panel_settings_outlined,
          color: Color(0xFF8B7CFF),
          size: 34,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.76),
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: isLoading
                  ? [const Color(0xFF4B5563), const Color(0xFF374151)]
                  : [const Color(0xFF716BFF), const Color(0xFF463FD7)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF625BFF).withValues(alpha: 0.34),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, color: Colors.white, size: 20),
                      Gap(10),
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7877FF).withValues(alpha: 0.18)
      ..strokeWidth = 1;

    const spacing = 34.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
