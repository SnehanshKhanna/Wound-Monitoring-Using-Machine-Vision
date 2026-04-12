import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme.dart';
import '../widgets/animated_metric_ring.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Metrics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Model Performance (CNN)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Wrap(
              spacing: 30,
              runSpacing: 30,
              alignment: WrapAlignment.center,
              children: [
                AnimatedMetricRing(label: 'Accuracy', value: 0.94, color: AppTheme.primaryBlue),
                AnimatedMetricRing(label: 'Precision', value: 0.91, color: AppTheme.accentSafe),
                AnimatedMetricRing(label: 'Recall', value: 0.89, color: AppTheme.accentModerateRisk),
                AnimatedMetricRing(label: 'DSC', value: 0.88, color: Colors.purpleAccent),
                AnimatedMetricRing(label: 'IoU', value: 0.82, color: Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 48),
            const Text(
              'Dataset Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  _DataRowItem(label: 'Dataset Name', value: 'AZH Wound Database v2'),
                  Divider(color: Colors.white12, height: 24),
                  _DataRowItem(label: 'Images Used', value: '4,285'),
                  Divider(color: Colors.white12, height: 24),
                  _DataRowItem(label: 'Annotation Type', value: 'Polygon Segmentation'),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Target Model'),
                    subtitle: const Text('CNN (ResNet-50)'),
                    trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  ListTile(
                    title: const Text('Color Space'),
                    subtitle: const Text('RGB'),
                    trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.doc_text_fill),
              label: const Text('Export PDF Report', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceLight,
                foregroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.5)),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _DataRowItem extends StatelessWidget {
  final String label;
  final String value;

  const _DataRowItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
