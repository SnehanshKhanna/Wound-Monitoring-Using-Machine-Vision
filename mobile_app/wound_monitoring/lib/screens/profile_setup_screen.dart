import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../providers/profile_provider.dart';
import '../providers/imgbb_service.dart';
import 'main_navigation_screen.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final images = await _picker.pickMultiImage(limit: 3);
    setState(() {
      _selectedImages.addAll(images.map((img) => File(img.path)));
      if (_selectedImages.length > 3) {
        _selectedImages.removeRange(3, _selectedImages.length);
      }
    });
  }

  Future<void> _completeSetup() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    
    // 1. Save profile locally
    await ref.read(profileProvider.notifier).createProfile(_nameController.text.trim());
    final user = ref.read(profileProvider);

    if (user != null) {
      // 2. Create Firestore User Document
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(user.id).set({
        'name': user.name,
        'createdAt': user.createdAt.toIso8601String(),
      });

      // 3. Upload initial images to ImgBB and save to Firestore
      for (var imgFile in _selectedImages) {
        final url = await ImgBBApiService.uploadImage(imgFile);
        if (url != null) {
          await firestore.collection('users').doc(user.id).collection('history').add({
            'imageUrl': url,
            'timestamp': DateTime.now().toIso8601String(),
            'notes': 'Baseline Image Upload',
            'area': 0, // Mock initial state
            'risk_level': 'Unknown',
            'healing_trend': 'Stable',
          });
        }
      }
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(CupertinoIcons.person_crop_circle_fill_badge_plus, size: 80, color: AppTheme.primaryBlue),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Smart Wound Monitor',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up your patient profile to securely track wound healing metrics in the cloud.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Patient Name',
                  filled: true,
                  fillColor: AppTheme.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Baseline Images (Optional)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(CupertinoIcons.camera_fill, color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _selectedImages.map((img) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(img, width: 80, height: 80, fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedImages.remove(img));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(CupertinoIcons.clear_thick, size: 16, color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  )
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSaving ? null : _completeSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Complete Setup', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
