import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/auth_background.dart'; // New Import
import '../../../core/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _flatController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _selectedRole = 'member';
  String? _selectedAdminRole;

  final List<Map<String, dynamic>> _adminRoles = [
    {'value': 'chairman', 'label': 'Chairman', 'icon': Icons.gavel_rounded},
    {
      'value': 'secretary',
      'label': 'Secretary',
      'icon': Icons.description_outlined,
    },
    {
      'value': 'treasurer',
      'label': 'Treasurer',
      'icon': Icons.account_balance_wallet_outlined,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _flatController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'admin' && _selectedAdminRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your designation'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserRole userRole;
      if (_selectedRole == 'admin') {
        switch (_selectedAdminRole) {
          case 'chairman':
            userRole = UserRole.chairman;
            break;
          case 'secretary':
            userRole = UserRole.secretary;
            break;
          case 'treasurer':
            userRole = UserRole.treasurer;
            break;
          default:
            userRole = UserRole.member;
        }
      } else {
        userRole = UserRole.member;
      }

      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        mobile: _phoneController.text.trim(),
        role: userRole,
        societyId: 'society_123', // Default for now
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.registerSuccess),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
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
      title: 'Create Account',
      subtitle: 'Join your society platform',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role Toggle
              _buildRoleToggle(),

              // Admin Designation
              if (_selectedRole == 'admin') ...[
                const SizedBox(height: 16),
                _buildAdminDesignationPicker(),
              ],

              const SizedBox(height: 24),

              // Personal Details
              _buildSectionLabel('Personal Details'),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _nameController,
                label: AppStrings.fullName,
                hint: 'Enter full name',
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, 'Full name'),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                label: AppStrings.email,
                hint: 'Enter email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController,
                label: AppStrings.phoneNumber,
                hint: '10-digit number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: Validators.phone,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _flatController,
                label: AppStrings.flatNumber,
                hint: 'e.g., A-101',
                prefixIcon: Icons.home_outlined,
                textInputAction: TextInputAction.next,
                validator: Validators.flatNumber,
              ),

              const SizedBox(height: 24),

              // Security
              _buildSectionLabel('Security'),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _passwordController,
                label: AppStrings.password,
                hint: 'Min 6 chars',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
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

              const SizedBox(height: 16),

              CustomTextField(
                controller: _confirmPasswordController,
                label: AppStrings.confirmPassword,
                hint: 'Re-enter password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleRegister(),
                validator: (v) =>
                    Validators.confirmPassword(v, _passwordController.text),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Register Button
              CustomButton(
                text: AppStrings.register,
                isLoading: _isLoading,
                icon: Icons.check_circle_outline, // Success icon
                onPressed: _handleRegister,
              ),

              const SizedBox(height: 24),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Label ───────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  // ── Role Toggle ─────────────────────────────────────────
  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildRoleTab(
            label: "Administrator", // Full text looks better here
            icon: Icons.shield_outlined,
            isSelected: _selectedRole == 'admin',
            onTap: () => setState(() => _selectedRole = 'admin'),
          ),
          const SizedBox(width: 4),
          _buildRoleTab(
            label: "Member",
            icon: Icons.person_outline,
            isSelected: _selectedRole == 'member',
            onTap: () => setState(() {
              _selectedRole = 'member';
              _selectedAdminRole = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.transparent, // Inverted active style
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
            border: isSelected
                ? Border.all(color: AppColors.border, width: 0.5)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Admin Designation Picker ────────────────────────────
  Widget _buildAdminDesignationPicker() {
    return Column(
      children: [
        Row(
          children: _adminRoles.map((role) {
            final isSelected = _selectedAdminRole == role['value'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedAdminRole = role['value']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          role['icon'] as IconData,
                          size: 20,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
