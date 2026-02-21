import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({super.key});

  @override
  State<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isDraft = false;

  final List<String> _categories = [
    'General',
    'Maintenance',
    'Security',
    'Event',
    'Billing',
    'Emergency',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final newNotice = {
      'id': 'n_${DateTime.now().millisecondsSinceEpoch}',
      'title': _titleController.text,
      'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
      'category': _selectedCategory,
      'status': _isDraft ? 'Draft' : 'Published',
      'content': _contentController.text,
    };

    MockData.addNotice(newNotice);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isDraft ? 'Notice saved as draft' : 'Notice published successfully',
        ),
        backgroundColor: _isDraft ? AppColors.warning : AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Notice'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notice Details', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              const Text(
                'Draft or publish a priority announcement for the society.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _titleController,
                label: 'Notice Title',
                hint: 'e.g., Lift Maintenance - Block A',
                prefixIcon: Icons.title_rounded,
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 24),

              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
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

              CustomTextField(
                controller: _contentController,
                label: 'Notice Content',
                hint: 'Type the full notice details here...',
                prefixIcon: Icons.description_rounded,
                maxLines: 6,
                validator: (v) => v!.isEmpty ? 'Content is required' : null,
              ),
              const SizedBox(height: 24),

              // Draft Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Save as Draft',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Keep as draft for later review',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isDraft,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isDraft = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              CustomButton(
                text: _isDraft ? 'Save Draft' : 'Publish Notice',
                icon: _isDraft ? Icons.save_rounded : Icons.send_rounded,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
