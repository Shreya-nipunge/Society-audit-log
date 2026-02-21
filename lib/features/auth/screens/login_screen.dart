import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/auth_background.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/session_manager.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _sessionManager = SessionManager();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      debugPrint(
        'LOGIN_ATTEMPT: Email: "${_emailController.text.trim()}", PWD: "${_passwordController.text.trim()}"',
      );

      final user = MockData.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        _sessionManager.login(user);

        if (!mounted) return;

        if (user.role == UserRole.member) {
          Navigator.pushReplacementNamed(context, '/member-dashboard');
        } else if (user.role == UserRole.chairman) {
          Navigator.pushReplacementNamed(context, '/chairman-dashboard');
        } else if (user.role == UserRole.treasurer) {
          Navigator.pushReplacementNamed(context, '/treasurer-dashboard');
        } else {
          // Secretary goes to admin-dashboard (operations hub)
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      title: 'Welcome Back',
      subtitle: 'Sign in to confirm your identity',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // ── Email Field ───────────────────────────────────────────
              CustomTextField(
                controller: _emailController,
                label: AppStrings.email,
                hint: 'name@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),

              const SizedBox(height: 20),

              // ── Password Field ────────────────────────────────────────
              CustomTextField(
                controller: _passwordController,
                label: AppStrings.password,
                hint: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
                validator: Validators.password,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              // ── Forgot Password ───────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: const Text(
                    AppStrings.forgotPassword,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Login Button ──────────────────────────────────────────
              CustomButton(
                text: AppStrings.login,
                isLoading: _isLoading,
                icon: Icons.arrow_forward_rounded, // Improved icon
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 48),

              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Private Society System',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Login with society-issued credentials only.\nContact your society admin for access.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
