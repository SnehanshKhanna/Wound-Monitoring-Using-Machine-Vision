import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme.dart';
import '../models/wound_data.dart';
import '../widgets/pipeline_stepper.dart';
import '../widgets/animated_arc_gauge.dart';

class ScanTab extends StatefulWidget {
  const ScanTab({super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  bool _imageSelected = false;
  int _pipelineStep = -1;
  bool _showResults = false;

  void _simulateScan() async {
    setState(() {
      _imageSelected = true;
      _pipelineStep = 0;
      _showResults = false;
    });

    // Simulate pipeline steps
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _pipelineStep = i + 1;
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _showResults = true;
      });
    }
  }

  void _reset() {
    setState(() {
      _imageSelected = false;
      _pipelineStep = -1;
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Analyze'),
        actions: [
          if (_imageSelected)
            IconButton(
              icon: const Icon(CupertinoIcons.refresh),
              onPressed: _reset,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_imageSelected) _buildImagePickerArea() else _buildPreviewArea(),
            if (_pipelineStep >= 0 && !_showResults) ...[
              const SizedBox(height: 32),
              const Text(
                'Processing Image...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              PipelineStepper(currentStep: _pipelineStep),
            ],
            if (_showResults) _buildResultsArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerArea() {
    return GestureDetector(
      onTap: _simulateScan,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.camera_viewfinder,
                size: 48,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap to capture or upload image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Placeholder for real image
          const Icon(CupertinoIcons.photo_fill, size: 80, color: Colors.white24),
          if (_showResults)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.accentModerateRisk.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('Segmentation Overlay'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsArea() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Analysis Results',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(CupertinoIcons.sparkles, size: 14, color: AppTheme.primaryBlue),
              const SizedBox(width: 4),
              Text(
                'Analyzed by Claude Vision API',
                style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue.withOpacity(0.8)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Center(
                  child: AnimatedArcGauge(
                    riskLevel: RiskLevel.moderate,
                    value: 0.65, // 65% Risk representation
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ResultChip(label: 'Area', value: '12.4 cm²'),
                    _ResultChip(label: 'Tissue', value: 'Granulation'),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                const Text(
                  'Clinical Notes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Wound shows healthy progression with predominantly granulation tissue. Moderate risk attributed to depth and location. Continue current care protocol.',
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Result', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String label;
  final String value;

  const _ResultChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
