import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/session_manager.dart';
import '../../auth/models/user_model.dart';
import '../models/document_model.dart';
import '../../admin/widgets/admin_drawer.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Circulars',
    'AGM Minutes',
    'Annual Reports',
    'Audit Reports',
    'Receipts',
  ];

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.currentUser;
    final allDocs = MockData.getDocuments(user?.role ?? UserRole.member);

    final filteredDocs = _selectedCategory == 'All'
        ? allDocs
        : allDocs.where((doc) => doc.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Society Documents'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: user?.role != UserRole.member ? const AdminDrawer() : null,
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Document List
          Expanded(
            child: filteredDocs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      return _buildDocumentCard(doc);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: user?.role != UserRole.member
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/upload-document'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No documents in $_selectedCategory',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentModel doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getCategoryColor(doc.category).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(doc.category),
            color: _getCategoryColor(doc.category),
          ),
        ),
        title: Text(
          doc.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${doc.category} • ${DateFormat('dd MMM yyyy').format(doc.uploadedAt)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (doc.visibility == 'admin')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 12,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Admin Only',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.error.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.file_download_outlined,
            color: AppColors.primary,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Downloading ${doc.fileName}... (Mock)')),
            );
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Circulars':
        return Icons.campaign_outlined;
      case 'AGM Minutes':
        return Icons.groups_outlined;
      case 'Annual Reports':
        return Icons.assessment_outlined;
      case 'Receipts':
        return Icons.receipt_long_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Circulars':
        return Colors.blue;
      case 'AGM Minutes':
        return Colors.orange;
      case 'Annual Reports':
        return Colors.teal;
      case 'Receipts':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }
}
