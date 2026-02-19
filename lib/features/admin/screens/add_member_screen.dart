import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/app_mode.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/permission_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../audit/services/audit_service.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _flatController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String mobile = _mobileController.text.trim();
      final String mockEmail = '$mobile@society.com';

      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple mock ID
        name: _nameController.text.trim(),
        email: mockEmail,
        mobile: mobile,
        role: UserRole.member,
        societyId: 'society_123',
        isActive: true,
      );

      MockData.addUser(newUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member added successfully! Login: $mockEmail'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Trigger Audit Log
      AuditService.logAction(
        actionType: 'ADD_MEMBER',
        targetEntity: newUser.name,
        newValue: 'Flat: ${_flatController.text}, Role: Member',
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add member: $e'),
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
    if (!PermissionManager.canEditMembers()) {
      return const _AccessDeniedScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Member'),
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
              const Text(
                'Member Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the details below to create a member account. Login credentials will be generated automatically.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'e.g. Rahul Sharma',
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _flatController,
                label: 'Flat Number',
                hint: 'e.g. A-101',
                prefixIcon: Icons.home_outlined,
                validator: (v) => Validators.required(v, 'Flat number'),
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
                label: 'Personal Email (Optional)',
                hint: 'e.g. rahul@gmail.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v != null && v.isNotEmpty ? Validators.email(v) : null,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: AppConfig.isReadOnly
                    ? 'Read-Only Mode Active'
                    : 'Create Member Account',
                isLoading: _isLoading,
                icon: Icons.person_add_outlined,
                onPressed: AppConfig.isReadOnly ? null : _handleSave,
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
            const Text('You do not have permission to add members.'),
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
