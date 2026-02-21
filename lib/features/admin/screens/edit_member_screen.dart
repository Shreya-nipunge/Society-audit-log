import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/permission_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../audit/services/audit_service.dart';

class EditMemberScreen extends StatefulWidget {
  final UserModel member;
  const EditMemberScreen({super.key, required this.member});

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _flatController;
  final _newPasswordController = TextEditingController();
  late UserRole _selectedRole;
  late bool _isActive;
  bool _isLoading = false;
  bool _showPasswordReset = false;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _mobileController = TextEditingController(text: widget.member.mobile);
    _emailController = TextEditingController(text: widget.member.email);
    _flatController = TextEditingController(text: widget.member.flatNumber);
    _selectedRole = widget.member.role;
    _isActive = widget.member.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _flatController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_showPasswordReset && _newPasswordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 6 characters'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Build change log for audit
      final changes = <String>[];
      if (_nameController.text.trim() != widget.member.name) {
        changes.add(
          'Name: ${widget.member.name} → ${_nameController.text.trim()}',
        );
      }
      if (_mobileController.text.trim() != widget.member.mobile) {
        changes.add('Mobile updated');
      }
      if (_flatController.text.trim() != widget.member.flatNumber) {
        changes.add(
          'Flat: ${widget.member.flatNumber} → ${_flatController.text.trim()}',
        );
      }
      if (_selectedRole != widget.member.role) {
        changes.add(
          'Role: ${widget.member.role.label} → ${_selectedRole.label}',
        );
      }
      if (_isActive != widget.member.isActive) {
        changes.add(_isActive ? 'Reactivated' : 'Deactivated');
      }
      if (_showPasswordReset && _newPasswordController.text.trim().isNotEmpty) {
        changes.add('Password reset');
      }

      final updatedUser = widget.member.copyWith(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        flatNumber: _flatController.text.trim(),
        role: _selectedRole,
        isActive: _isActive,
        password:
            _showPasswordReset && _newPasswordController.text.trim().isNotEmpty
            ? _newPasswordController.text.trim()
            : null,
      );

      MockData.updateUser(updatedUser);

      if (changes.isNotEmpty) {
        AuditService.logAction(
          actionType: 'EDIT_USER_ACCOUNT',
          targetEntity: widget.member.name,
          oldValue:
              'Flat: ${widget.member.flatNumber}, Role: ${widget.member.role.label}',
          newValue: changes.join('; '),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update member: $e'),
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
    final bool isChairman = PermissionManager.isChairman();
    final bool canEdit = PermissionManager.canEditMembers();

    if (!canEdit) {
      return const _AccessDeniedScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Member'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildSectionHeader(
                Icons.person_outline_rounded,
                'Update Information',
                'Modify member details. All changes are audit-logged.',
              ),
              const SizedBox(height: 24),

              // Section: Basic Info
              _buildLabel('PERSONAL DETAILS'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Name',
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _flatController,
                      label: 'Flat Number',
                      hint: 'e.g. A-101',
                      prefixIcon: Icons.home_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _mobileController,
                      label: 'Mobile',
                      hint: '10 digits',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Society Email',
                hint: 'email@society.com',
                prefixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),

              const SizedBox(height: 28),

              // Section: Password Reset
              _buildLabel('CREDENTIAL MANAGEMENT'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Issue a new password for this member',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _showPasswordReset,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _showPasswordReset = v),
                    ),
                    if (_showPasswordReset) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomTextField(
                          controller: _newPasswordController,
                          label: 'New Password',
                          hint: 'Min 6 characters',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureNewPassword,
                          validator: (v) {
                            if (_showPasswordReset &&
                                (v == null || v.length < 6)) {
                              return 'Min 6 characters';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Section: Role (Chairman only)
              if (isChairman) ...[
                _buildLabel('ROLE & ACCESS'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserRole>(
                      value: _selectedRole,
                      isExpanded: true,
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Row(
                            children: [
                              Icon(
                                _roleIcon(role),
                                size: 18,
                                color: _roleColor(role),
                              ),
                              const SizedBox(width: 10),
                              Text(role.label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRole = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Account Status Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isActive
                          ? AppColors.border
                          : Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      _isActive ? 'Account Active' : 'Account Deactivated',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _isActive ? AppColors.success : Colors.orange,
                      ),
                    ),
                    subtitle: Text(
                      _isActive
                          ? 'User can log in and access the system'
                          : 'User cannot log in. Data is preserved.',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _isActive,
                    activeThumbColor: AppColors.success,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // Save Button
              CustomButton(
                text: 'Save Changes',
                isLoading: _isLoading,
                icon: Icons.save_outlined,
                onPressed: _handleUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h4),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
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
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.chairman:
        return Icons.gavel_rounded;
      case UserRole.secretary:
        return Icons.description_outlined;
      case UserRole.treasurer:
        return Icons.account_balance_wallet_outlined;
      case UserRole.member:
        return Icons.person_outline_rounded;
    }
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.chairman:
        return const Color(0xFFEF4444);
      case UserRole.secretary:
        return AppColors.secondary;
      case UserRole.treasurer:
        return const Color(0xFF6366F1);
      case UserRole.member:
        return AppColors.primary;
    }
  }
}

class _AccessDeniedScreen extends StatelessWidget {
  const _AccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Access Denied', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            const Text('You do not have permission to edit members.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
