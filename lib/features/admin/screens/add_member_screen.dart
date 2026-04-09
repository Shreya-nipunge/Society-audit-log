import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/app_mode.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/permission_manager.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../audit/services/audit_service.dart';
import 'dart:math';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  // Section 1: Identity
  final _nameController = TextEditingController();
  final _flatController = TextEditingController();
  final _wingController = TextEditingController();
  final _floorController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emergencyController = TextEditingController();

  // Section 2: Credentials
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Section 3: Role
  UserRole _selectedRole = UserRole.member;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _currentStep = 0;
  bool _credentialsCopied = false;

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    _wingController.dispose();
    _floorController.dispose();
    _mobileController.dispose();
    _emergencyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _autoGenerateEmail() {
    final flat = _flatController.text.trim().toLowerCase().replaceAll('-', '');
    if (flat.isNotEmpty) {
      _emailController.text = '$flat@society.com';
    }
  }

  String _generatePassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
    const specials = '@#\$!';
    final rng = Random.secure();
    final pwd = List.generate(
      8,
      (_) => chars[rng.nextInt(chars.length)],
    ).join();
    return '$pwd${specials[rng.nextInt(specials.length)]}';
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Identity
        if (_nameController.text.trim().isEmpty) {
          _showError('Full name is required');
          return false;
        }
        if (_flatController.text.trim().isEmpty) {
          _showError('Flat number is required');
          return false;
        }
        if (_mobileController.text.trim().isEmpty ||
            _mobileController.text.trim().length != 10) {
          _showError('Valid 10-digit mobile number is required');
          return false;
        }
        return true;
      case 1: // Credentials
        if (_emailController.text.trim().isEmpty) {
          _showError('Society email is required');
          return false;
        }
        if (_passwordController.text.trim().length < 3) {
          _showError('Password must be at least 3 characters');
          return false;
        }
        if (_passwordController.text != _confirmPasswordController.text) {
          _showError('Passwords do not match');
          return false;
        }
        // Check email uniqueness
        final emailExists = MockData.users.any(
          (u) =>
              u.email.toLowerCase() ==
              _emailController.text.trim().toLowerCase(),
        );
        if (emailExists) {
          _showError('This email is already assigned to another member');
          return false;
        }
        return true;
      case 2: // Role
        return true;
      default:
        return true;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    setState(() => _currentStep--);
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = SessionManager.currentUser;

      final newUser = UserModel(
        uid: 'mem_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _mobileController.text.trim(),
        flatNumber: _flatController.text.trim(),
        role: _selectedRole,
        societyId: 'society_123',
        createdBy: currentUser?.uid ?? 'unknown',
      );

      MockData.addUser(newUser);

      AuditService.logAction(
        actionType: 'CREATE_USER_ACCOUNT',
        targetEntity: newUser.name,
        newValue:
            'Flat: ${newUser.flatNumber}, Role: ${newUser.role.label}, Email: ${newUser.email}',
      );

      if (!mounted) return;
      setState(() => _currentStep = 3); // Go to confirmation
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to create account: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyCredentials() {
    final text =
        'Society Login Credentials\n'
        '━━━━━━━━━━━━━━━━━━━━━\n'
        'Name: ${_nameController.text.trim()}\n'
        'Flat: ${_flatController.text.trim()}\n'
        'Email: ${_emailController.text.trim()}\n'
        'Password: ${_passwordController.text.trim()}\n'
        '━━━━━━━━━━━━━━━━━━━━━\n'
        'Role: ${_selectedRole.label}';

    Clipboard.setData(ClipboardData(text: text));
    setState(() => _credentialsCopied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Credentials copied to clipboard!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!PermissionManager.canEditMembers() &&
        !PermissionManager.isTreasurer()) {
      return const _AccessDeniedScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Issue Society Credentials'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Step Indicator
            _buildStepIndicator(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: _buildCurrentStep(),
              ),
            ),

            // Navigation Buttons
            if (_currentStep < 3) _buildNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Identity', 'Credentials', 'Role', 'Confirm'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isCompleted = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.success
                        : isActive
                        ? AppColors.primary
                        : AppColors.border.withValues(alpha: 0.3),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    steps[i],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (i < steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildIdentityStep();
      case 1:
        return _buildCredentialsStep();
      case 2:
        return _buildRoleStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return const SizedBox();
    }
  }

  // ─── Step 1: Member Identity ────────────────────────────
  Widget _buildIdentityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.person_outline_rounded,
          'Member Identity',
          'Enter the personal details of the society member.',
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _nameController,
          label: 'Full Name *',
          hint: 'e.g. Rahul Sharma',
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
                label: 'Flat Number *',
                hint: 'e.g. A-101',
                prefixIcon: Icons.home_outlined,
                validator: (v) => Validators.required(v, 'Flat number'),
                onChanged: (_) => _autoGenerateEmail(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _wingController,
                label: 'Wing',
                hint: 'A',
                prefixIcon: Icons.apartment_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _floorController,
          label: 'Floor',
          hint: 'e.g. 1st Floor',
          prefixIcon: Icons.layers_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _mobileController,
          label: 'Mobile Number *',
          hint: '10-digit number',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emergencyController,
          label: 'Emergency Contact',
          hint: 'Optional',
          prefixIcon: Icons.emergency_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  // ─── Step 2: Society Credentials ────────────────────────
  Widget _buildCredentialsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.lock_outline_rounded,
          'Society Credentials',
          'Set the login credentials for this member. These are the ONLY credentials they can use to access the system.',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Only these credentials can access the system. No other email or password will work.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _emailController,
          label: 'Society Email ID *',
          hint: 'e.g. a101@society.com',
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _autoGenerateEmail,
            icon: const Icon(Icons.auto_fix_high, size: 16),
            label: const Text(
              'Auto-generate from flat',
              style: TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _passwordController,
          label: 'Password *',
          hint: 'Min 3 characters',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
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
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              final pwd = _generatePassword();
              _passwordController.text = pwd;
              _confirmPasswordController.text = pwd;
              setState(() {
                _obscurePassword = false;
                _obscureConfirm = false;
              });
            },
            icon: const Icon(Icons.vpn_key_rounded, size: 16),
            label: const Text(
              'Generate Secure Password',
              style: TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password *',
          hint: 'Re-enter password',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureConfirm,
          validator: (v) =>
              Validators.confirmPassword(v, _passwordController.text),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
      ],
    );
  }

  // ─── Step 3: Role & Access ──────────────────────────────
  Widget _buildRoleStep() {
    final canAssignAdminRoles = PermissionManager.isChairman();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.shield_outlined,
          'Role & Access Control',
          'Assign the appropriate role. Members have view-only access.',
        ),
        const SizedBox(height: 24),
        _buildRoleCard(
          UserRole.member,
          'Society Member',
          'View bills, payments, notices, documents. No admin or financial editing rights.',
          Icons.person_outline_rounded,
          AppColors.primary,
          true,
        ),
        const SizedBox(height: 12),
        if (canAssignAdminRoles) ...[
          _buildRoleCard(
            UserRole.secretary,
            'Secretary',
            'Member operations, payments, billing, expenses, vendor management, documents.',
            Icons.description_outlined,
            AppColors.secondary,
            true,
          ),
          const SizedBox(height: 12),
          _buildRoleCard(
            UserRole.treasurer,
            'Treasurer',
            'Financial verification, approvals, fund control, reconciliation, budgeting.',
            Icons.account_balance_wallet_outlined,
            const Color(0xFF6366F1),
            true,
          ),
          const SizedBox(height: 12),
          _buildRoleCard(
            UserRole.chairman,
            'Chairman',
            'Full governance authority — user management, approvals, oversight, compliance.',
            Icons.gavel_rounded,
            const Color(0xFFEF4444),
            true,
          ),
        ],
        if (!canAssignAdminRoles)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Only the Chairman can assign admin roles. You can create member accounts.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRoleCard(
    UserRole role,
    String title,
    String description,
    IconData icon,
    Color color,
    bool enabled,
  ) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: enabled ? () => setState(() => _selectedRole = role) : null,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24)
            else
              Icon(
                Icons.radio_button_unchecked,
                color: AppColors.border,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  // ─── Step 4: Confirmation ───────────────────────────────
  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF10B981)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Account Created Successfully',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Society credentials have been issued.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Credential Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.badge_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LOGIN CREDENTIALS',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _credentialRow('Name', _nameController.text.trim()),
              _credentialRow('Flat', _flatController.text.trim()),
              _credentialRow('Role', _selectedRole.label),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _credentialRow('Email', _emailController.text.trim()),
                    _credentialRow('Password', _passwordController.text.trim()),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Copy Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _copyCredentials,
            icon: Icon(
              _credentialsCopied ? Icons.check_circle : Icons.copy_rounded,
              size: 18,
            ),
            label: Text(
              _credentialsCopied
                  ? 'Credentials Copied!'
                  : 'Copy Credentials to Clipboard',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _credentialsCopied
                  ? AppColors.success
                  : AppColors.primary,
              side: BorderSide(
                color: _credentialsCopied
                    ? AppColors.success
                    : AppColors.primary,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Done Button
        CustomButton(
          text: 'Done — Return to Dashboard',
          icon: Icons.check_rounded,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _credentialRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Navigation Bar ─────────────────────────────────────
  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CustomButton(
              text: _currentStep == 2
                  ? (AppConfig.isReadOnly ? 'Read-Only Mode' : 'Create Account')
                  : 'Continue',
              isLoading: _isLoading,
              icon: _currentStep == 2
                  ? Icons.person_add_rounded
                  : Icons.arrow_forward_rounded,
              onPressed: AppConfig.isReadOnly && _currentStep == 2
                  ? null
                  : (_currentStep == 2 ? _handleCreate : _nextStep),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared Helpers ─────────────────────────────────────
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
            const Text('You do not have permission to create accounts.'),
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
