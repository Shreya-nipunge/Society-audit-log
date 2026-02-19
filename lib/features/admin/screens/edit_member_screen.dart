import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/permission_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';

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
  late UserRole _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _mobileController = TextEditingController(text: widget.member.mobile);
    _emailController = TextEditingController(text: widget.member.email);
    _selectedRole = widget.member.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = widget.member.copyWith(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
      );

      MockData.updateUser(updatedUser);

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
    final bool isSecretary = PermissionManager.isSecretary();

    // Permission check
    if (!isChairman && !isSecretary) {
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
              Text('Update Information', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              const Text(
                'Secretary can edit basic info. Chairman can also change roles.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Name',
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _mobileController,
                label: 'Mobile Number',
                hint: '10-digit number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'email@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 24),

              // Role Selection (Chairman only)
              if (isChairman) ...[
                const Text(
                  'Assign Role',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserRole>(
                      value: _selectedRole,
                      isExpanded: true,
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRole = val);
                      },
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 48),
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
