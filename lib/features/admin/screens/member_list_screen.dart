import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/permission_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/admin_drawer.dart';
import '../../audit/services/audit_service.dart';
import 'edit_member_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen>
    with SingleTickerProviderStateMixin {
  late List<UserModel> _allUsers;
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _refreshMembers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshMembers() {
    setState(() {
      _allUsers = List.from(MockData.users);
    });
  }

  List<UserModel> get _filteredUsers {
    var users = _allUsers;

    // Tab filter
    switch (_tabController.index) {
      case 1: // Members only
        users = users.where((u) => u.role == UserRole.member).toList();
        break;
      case 2: // Admins only
        users = users
            .where(
              (u) =>
                  u.role == UserRole.chairman ||
                  u.role == UserRole.secretary ||
                  u.role == UserRole.treasurer,
            )
            .toList();
        break;
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      users = users.where((u) {
        return u.name.toLowerCase().contains(q) ||
            u.flatNumber.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.mobile.contains(q);
      }).toList();
    }

    return users;
  }

  void _deactivateMember(UserModel member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            const Text('Deactivate Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deactivate the account for ${member.name}?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'This will prevent login but preserves all data and audit history. This action can be reversed.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = member.copyWith(isActive: false);
              MockData.updateUser(updated);
              AuditService.logAction(
                actionType: 'DEACTIVATE_USER',
                targetEntity: member.name,
                oldValue: 'Active',
                newValue: 'Deactivated — Flat: ${member.flatNumber}',
              );
              Navigator.pop(ctx);
              _refreshMembers();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${member.name} has been deactivated'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _reactivateMember(UserModel member) {
    final updated = member.copyWith(isActive: true);
    MockData.updateUser(updated);
    AuditService.logAction(
      actionType: 'REACTIVATE_USER',
      targetEntity: member.name,
      oldValue: 'Deactivated',
      newValue: 'Active — Flat: ${member.flatNumber}',
    );
    _refreshMembers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.name} has been reactivated'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    if (SessionManager.currentUser == null) {
      return const _AccessDeniedScreen();
    }

    final bool canEdit = PermissionManager.canEditMembers();
    final bool isChairman = PermissionManager.isChairman();
    final filtered = _filteredUsers;

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
              tooltip: 'Issue Credentials',
              onPressed: () async {
                await Navigator.pushNamed(context, '/add-member');
                _refreshMembers();
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'All (${_allUsers.length})'),
            Tab(
              text:
                  'Members (${_allUsers.where((u) => u.role == UserRole.member).length})',
            ),
            Tab(
              text:
                  'Admins (${_allUsers.where((u) => u.role != UserRole.member).length})',
            ),
          ],
        ),
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by name, flat, email, or mobile...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${filtered.length} user${filtered.length != 1 ? 's' : ''} found',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Member List
          Expanded(
            child: filtered.isEmpty
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final member = filtered[index];
                      return _buildMemberCard(member, canEdit, isChairman);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(UserModel member, bool canEdit, bool isChairman) {
    final color = _roleColor(member.role);
    final isInactive = !member.isActive;

    return Opacity(
      opacity: isInactive ? 0.55 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isInactive
                ? Colors.orange.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Avatar with role color
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          member.role.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      if (isInactive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Inactive',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (member.flatNumber.isNotEmpty) ...[
                        Icon(
                          Icons.home_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          member.flatNumber,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          member.mobile,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.email,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Actions
            if (canEdit)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (action) async {
                  switch (action) {
                    case 'edit':
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditMemberScreen(member: member),
                        ),
                      );
                      if (result == true) _refreshMembers();
                      break;
                    case 'deactivate':
                      _deactivateMember(member);
                      break;
                    case 'reactivate':
                      _reactivateMember(member);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text('Edit Details'),
                      ],
                    ),
                  ),
                  if (isChairman && member.isActive)
                    const PopupMenuItem(
                      value: 'deactivate',
                      child: Row(
                        children: [
                          Icon(
                            Icons.block_outlined,
                            size: 18,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Deactivate',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  if (isChairman && !member.isActive)
                    const PopupMenuItem(
                      value: 'reactivate',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Reactivate',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
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
