import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/session_manager.dart';
import '../../auth/models/user_model.dart';
import '../models/notice_model.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.currentUser;
    final isMember = user?.role == UserRole.member;

    final publishedNotices = MockData.notices
        .where((n) => n.status == 'Published')
        .toList();
    final draftNotices = MockData.notices
        .where((n) => n.status == 'Draft')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Society Notices'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: isMember
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  const Tab(text: 'Published'),
                  Tab(text: 'Drafts (${draftNotices.length})'),
                ],
              ),
      ),
      body: isMember
          ? _buildNoticeList(publishedNotices, isDraft: false)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNoticeList(publishedNotices, isDraft: false),
                _buildNoticeList(draftNotices, isDraft: true),
              ],
            ),
      floatingActionButton: isMember
          ? null
          : FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/create-notice'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildNoticeList(
    List<NoticeModel> notices, {
    required bool isDraft,
  }) {
    if (notices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDraft ? Icons.note_add_outlined : Icons.campaign_outlined,
              size: 64,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isDraft ? 'No draft notices found' : 'No notices published yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notices.length,
      itemBuilder: (context, index) {
        final notice = notices[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDraft ? AppColors.warning : AppColors.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDraft ? Icons.edit_note_rounded : Icons.campaign_rounded,
                color: isDraft ? AppColors.warning : AppColors.primary,
              ),
            ),
            title: Text(
              notice.title,
              style: AppTextStyles.labelLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                // Since I can't import DateFormat easily here without adding an import, wait, notice_list_screen doesn't import intl. Let me just use naive string.
                Text('${notice.date.day}/${notice.date.month}/${notice.date.year}', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Notice',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
            ),
            onTap: () => Navigator.pushNamed(
              context,
              '/notice-detail',
              arguments: notice.toMap(), 
            ),
          ),
        );
      },
    );
  }
}
