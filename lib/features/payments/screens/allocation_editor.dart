import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/app_mode.dart';

class AllocationEditorScreen extends StatefulWidget {
  const AllocationEditorScreen({super.key});

  @override
  State<AllocationEditorScreen> createState() => _AllocationEditorScreenState();
}

class _AllocationEditorScreenState extends State<AllocationEditorScreen> {
  late Map<String, double> _ratios;

  @override
  void initState() {
    super.initState();
    _ratios = Map.from(MockData.allocationRatios);
  }

  void _save() {
    final total = _ratios.values.reduce((a, b) => a + b);
    if ((total - 1.0).abs() > 0.001) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total allocation must be 100%')),
      );
      return;
    }

    MockData.allocationRatios = Map.from(_ratios);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Allocation ratios saved successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Maintenance Allocation Editor'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure Fund Ratios',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Define how maintenance payments are split between society funds.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            _buildRatioSlider('Maintenance', 'Maintenance'),
            const SizedBox(height: 24),
            _buildRatioSlider('Sinking Fund', 'Sinking Fund'),
            const SizedBox(height: 24),
            _buildRatioSlider('Repairs Fund', 'Repairs Fund'),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Allocation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '${(_ratios.values.reduce((a, b) => a + b) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          (_ratios.values.reduce((a, b) => a + b) - 1.0).abs() <
                              0.001
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: AppConfig.isReadOnly ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.isReadOnly
                      ? Colors.grey
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppConfig.isReadOnly
                      ? 'Read-Only Mode Active'
                      : 'Save Configuration',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatioSlider(String label, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${(_ratios[key]! * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: _ratios[key]!,
          onChanged: AppConfig.isReadOnly
              ? null
              : (val) {
                  setState(() => _ratios[key] = val);
                },
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
        ),
      ],
    );
  }
}
