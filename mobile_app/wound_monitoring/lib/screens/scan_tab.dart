import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import '../theme.dart';
import '../models/wound_data.dart';
import '../widgets/pipeline_stepper.dart';
import '../widgets/animated_arc_gauge.dart';
import '../providers/imgbb_service.dart';
import '../providers/profile_provider.dart';

class ScanTab extends ConsumerStatefulWidget {
  const ScanTab({super.key});

  @override
  ConsumerState<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends ConsumerState<ScanTab> {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  final String apiUrl = 'https://snehanshkhanna-mv-backend.hf.space/analyze';

  File? _selectedImage;
  int _pipelineStep = -1;
  bool _showResults = false;
  String _errorMessage = '';
  bool _isSavingToCloud = false;

  // API Response Values
  double _area = 0;
  double _redness = 0;
  double _healingScore = 0;
  double _infectionRiskScore = 0;
  String _riskLevelStr = '';
  String _healingTrend = 'N/A';

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? uncroppedImage = await _picker.pickImage(source: source);
      if (uncroppedImage == null) return;

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: uncroppedImage.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Wound Region',
            toolbarColor: AppTheme.primaryBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Wound Region'),
        ],
      );

      if (croppedFile == null) return;

      setState(() {
        _selectedImage = File(croppedFile.path);
        _pipelineStep = 0;
        _showResults = false;
        _errorMessage = '';
      });

      // Step 1: Preprocess (UI Simulation)
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _pipelineStep = 1);

      // Step 2 & 3: Network Call (Segment & Extract)
      final localUser = ref.read(profileProvider);
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: 'wound.jpg',
        ),
        'user_id': localUser?.id ?? 'default_user',
      });

      setState(() => _pipelineStep = 2);

      // We launch BOTH requests (Flask API + ImgBB) concurrently!
      final flaskFuture = _dio.post(
        apiUrl,
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final imgbbFuture = ImgBBApiService.uploadImage(
        File(_selectedImage!.path),
      );

      // Wait for both to finish simultaneously
      final results = await Future.wait([flaskFuture, imgbbFuture]);
      final flaskResponse = results[0] as Response;
      final imgbbUrl = results[1] as String?;

      setState(() => _pipelineStep = 3);
      await Future.delayed(const Duration(milliseconds: 500)); // Classify

      if (flaskResponse.statusCode == 200 && flaskResponse.data != null) {
        final data = flaskResponse.data as Map<String, dynamic>;

        double parsedArea = (data['area'] ?? 0).toDouble();
        double parsedRedness = (data['redness'] ?? 0).toDouble();
        double parsedScore = (data['healing_score'] ?? 0).toDouble();
        double parsedInfectionRisk = (data['infection_risk_score'] ?? 0)
            .toDouble();
        String parsedRisk = data['risk_level'] ?? 'Unknown';
        String compTrend = data['healing_trend'] ?? 'N/A';

        final user = ref.read(profileProvider);

        /* 
        // FRONTEND TREND CALCULATION COMMENTED OUT - NOW HANDLED BY API
        // Fetch previous record to compute trend
        if (user != null) {
            final prevHistory = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.id)
                .collection('history')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .get();
                
            if (prevHistory.docs.isNotEmpty) {
                double prevScore = (prevHistory.docs.first.data()['healing_score'] ?? 0).toDouble();
                if (parsedScore > prevScore) {
                    compTrend = 'Healing (+)';
                } else if (parsedScore < prevScore) {
                    compTrend = 'Degrading (-)';
                } else {
                    compTrend = 'Stable';
                }
            }
        }
        */

        setState(() {
          _area = parsedArea;
          _redness = parsedRedness;
          _healingScore = parsedScore;
          _infectionRiskScore = parsedInfectionRisk;
          _riskLevelStr = parsedRisk;
          _healingTrend = compTrend;

          _pipelineStep = 4; // Assess
        });

        // Auto-Save to Firestore since we have the ImgBB Link!
        if (imgbbUrl != null && user != null) {
          final clinicalNotes =
              'Analysis calculated a $_riskLevelStr with a $_healingTrend trend compared to last reading. The overall Healing Score rests at $_healingScore/100.';

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .collection('history')
              .add({
                'imageUrl': imgbbUrl,
                'timestamp': DateTime.now().toIso8601String(),
                'notes': 'Recorded via Scan Tab.',
                'area': _area,
                'redness': _redness,
                'infection_risk_score': _infectionRiskScore,
                'healing_score': _healingScore,
                'risk_level': _riskLevelStr,
                'healing_trend': _healingTrend,
                'clinical_notes': clinicalNotes,
                'analysis_raw': data,
              });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Auto-saved to Cloud Profile!'),
              backgroundColor: AppTheme.accentSafe,
            ),
          );
        }

        await Future.delayed(const Duration(milliseconds: 400));
        setState(() => _showResults = true);
      } else {
        throw Exception("Invalid response from server");
      }
    } catch (e) {
      setState(() {
        _pipelineStep = -1;
        _errorMessage = 'Failed to process pipeline: $e';
      });
    }
  }

  void _reset() {
    setState(() {
      _selectedImage = null;
      _pipelineStep = -1;
      _showResults = false;
      _errorMessage = '';
    });
  }

  RiskLevel _parseRiskLevel(String risk) {
    if (risk.toLowerCase().contains('high')) return RiskLevel.high;
    if (risk.toLowerCase().contains('moderate')) return RiskLevel.moderate;
    return RiskLevel.low;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Analyze'),
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(CupertinoIcons.refresh),
              onPressed: _reset,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentHighRisk.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentHighRisk),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            if (_selectedImage == null)
              _buildImagePickerArea()
            else
              _buildPreviewArea(),
            if (_pipelineStep >= 0 && !_showResults) ...[
              const SizedBox(height: 32),
              const Text(
                'Analyzing Image via Local Server...',
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.camera_fill,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUploadImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.photo_fill,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUploadImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerArea() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
        image: _selectedImage != null
            ? DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_showResults)
            Container(
              decoration: BoxDecoration(
                color: _parseRiskLevel(_riskLevelStr).color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'Analysis Overlay',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsArea() {
    final riskColor = _parseRiskLevel(_riskLevelStr).color;
    final gaugeValue = (_infectionRiskScore / 100).clamp(0.0, 1.0);
    final gaugeRisk = _parseRiskLevel(_riskLevelStr);

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
              const Icon(
                CupertinoIcons.link,
                size: 14,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 4),
              Text(
                'Processed by Local Flask API',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryBlue.withOpacity(0.8),
                ),
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
                    riskLevel: gaugeRisk,
                    value: gaugeValue,
                  ),
                ),
                const SizedBox(height: 16),
                _ResultChip(
                  label: 'Risk Level',
                  value: _riskLevelStr,
                  valueColor: riskColor,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ResultChip(
                      label: 'Infection Risk',
                      value: '${_infectionRiskScore.toStringAsFixed(1)}%',
                    ),
                    _ResultChip(
                      label: 'Area',
                      value: '${_area.toStringAsFixed(1)} px',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ResultChip(
                      label: 'Healing Score',
                      value: _healingScore.toStringAsFixed(1),
                    ),
                    _ResultChip(
                      label: 'Redness',
                      value: _redness.toStringAsFixed(1),
                    ),
                    _ResultChip(label: 'Trend', value: _healingTrend),
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
                Text(
                  'Analysis calculated a $_riskLevelStr with a $_healingTrend trend compared to last reading. The overall Healing Score rests at $_healingScore/100.',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Scan Another Image',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
  final Color? valueColor;

  const _ResultChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
