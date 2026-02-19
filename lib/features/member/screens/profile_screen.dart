import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  bool _isEditingMobile = false;
  final _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mobileController.text = SessionManager.currentUser?.mobile ?? '';
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.name, style: AppTextStyles.h2),
            Text(
              user.role.name.toUpperCase(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Divider(height: 48),

            // Profile Details
            _buildDetailTile(
              Icons.home_outlined,
              'Flat Number',
              'A-101 (Mock)',
            ),
            _buildDetailTile(Icons.email_outlined, 'Email Address', user.email),

            // Mobile Detail (with edit)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mobile Number',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        if (_isEditingMobile)
                          TextField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(isDense: true),
                          )
                        else
                          Text(
                            user.mobile,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isEditingMobile ? Icons.check : Icons.edit_outlined,
                    ),
                    onPressed: () {
                      setState(() => _isEditingMobile = !_isEditingMobile);
                      if (!_isEditingMobile) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mobile updated (Local Mock)'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            _buildDetailTile(
              Icons.calendar_today_outlined,
              'Joining Date',
              DateFormat(
                'dd MMM yyyy',
              ).format(DateTime.now().subtract(const Duration(days: 365))),
            ),

            const SizedBox(height: 32),
            CustomButton(
              text: 'Change Password',
              icon: Icons.lock_reset_outlined,
              onPressed: () {
                _showPasswordDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              decoration: InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed (Mock)')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
