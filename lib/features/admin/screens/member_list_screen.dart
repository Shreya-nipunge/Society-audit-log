import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/permission_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/admin_drawer.dart';
import 'edit_member_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  late List<UserModel> _members;

  @override
  void initState() {
    super.initState();
    _refreshMembers();
  }

  void _refreshMembers() {
    setState(() {
      _members = MockData.getMembers();
    });
  }

  void _deleteMember(UserModel member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              MockData.deleteUser(member.id);
              Navigator.pop(context);
              _refreshMembers();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Member deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (SessionManager.currentUser == null) {
      return const _AccessDeniedScreen();
    }

    final bool canEdit = PermissionManager.canEditMembers();
    final bool canDelete = PermissionManager.isChairman();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Society Members'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              onPressed: () async {
                await Navigator.pushNamed(context, '/add-member');
                _refreshMembers();
              },
            ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: _members.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No members found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _members.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final member = _members[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          member.name.isNotEmpty
                              ? member.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              member.email,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditMemberScreen(member: member),
                            ),
                          );
                          if (result == true) {
                            _refreshMembers();
                          }
                        },
                      ),
                      if (canDelete)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteMember(member),
                        ),
                    ],
                  ),
                );
              },
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
            const Text('You do not have permission to view this page.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
