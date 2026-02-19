import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/document_model.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _fileNameController = TextEditingController(); // Mock file picker

  String _selectedCategory = 'Circulars';
  bool _isMemberVisible = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'Annual Reports',
    'Audit Reports',
    'Receipts',
    'Circulars',
    'AGM Minutes',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final doc = DocumentModel(
        id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        category: _selectedCategory,
        fileName: _fileNameController.text,
        uploadedBy: SessionManager.currentUser?.name ?? 'Admin',
        uploadedAt: DateTime.now(),
        visibility: _isMemberVisible ? 'member' : 'admin',
      );

      MockData.addDocument(doc);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading document: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Document'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Document Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload society reports, circulars, or minutes for members to access.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _titleController,
                label: 'Document Title',
                hint: 'e.g., Audit Report FY 2023-24',
                prefixIcon: Icons.title_outlined,
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 24),

              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 24),

              // Mock File Picker
              CustomTextField(
                controller: _fileNameController,
                label: 'File Name (Mock Upload)',
                hint: 'e.g., circular_01.pdf',
                prefixIcon: Icons.file_present_outlined,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.attach_file, color: AppColors.primary),
                  onPressed: () {
                    // In a real app, this would open a file picker.
                    // Here we'll just pre-fill a mock filename.
                    if (_fileNameController.text.isEmpty) {
                      _fileNameController.text =
                          'society_doc_${DateTime.now().minute}.pdf';
                    }
                  },
                ),
                validator: (v) => v!.isEmpty ? 'File name is required' : null,
              ),
              const SizedBox(height: 24),

              // Visibility Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visible to Members',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Allow regular members to view this document',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isMemberVisible,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) =>
                          setState(() => _isMemberVisible = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              CustomButton(
                text: 'Upload Document',
                isLoading: _isLoading,
                icon: Icons.cloud_upload_outlined,
                onPressed: _handleUpload,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
