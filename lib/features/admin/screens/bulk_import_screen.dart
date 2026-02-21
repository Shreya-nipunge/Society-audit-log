import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mock_data.dart';
import '../../auth/models/user_model.dart';
import '../../audit/services/audit_service.dart';
import '../../../core/utils/app_mode.dart';

class BulkImportScreen extends StatefulWidget {
  const BulkImportScreen({super.key});

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  final _csvController = TextEditingController();
  bool _isProcessing = false;
  String? _error;

  void _processImport() {
    if (_csvController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter CSV data');
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final lines = _csvController.text.trim().split('\n');
      int count = 0;

      for (var line in lines) {
        final parts = line.split(',');
        if (parts.length < 3) continue;

        final flatNo = parts.length > 3 ? parts[3].trim() : '';
        final user = UserModel(
          id: 'mem_${DateTime.now().millisecondsSinceEpoch}_$count',
          name: parts[0].trim(),
          email: parts[1].trim(),
          password: 'Society@123',
          mobile: parts[2].trim(),
          flatNumber: flatNo,
          role: UserRole.member,
          societyId: 'society_123',
        );

        MockData.addUser(user);
        count++;
      }

      AuditService.logAction(
        actionType: 'BULK_MEMBER_IMPORT',
        targetEntity: 'Members',
        newValue: 'Imported $count members via CSV',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully imported $count members')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to parse CSV: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bulk Member Import'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import Members via CSV',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Paste your CSV data below. Format: Name, Email, Mobile',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _csvController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText:
                    'John Doe, john@example.com, 9876543210\nJane Smith, jane@example.com, 9123456780',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (_isProcessing || AppConfig.isReadOnly)
                    ? null
                    : _processImport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.isReadOnly
                      ? Colors.grey
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  _isProcessing
                      ? 'Processing...'
                      : (AppConfig.isReadOnly
                            ? 'Read-Only Mode Active'
                            : 'Start Import'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
