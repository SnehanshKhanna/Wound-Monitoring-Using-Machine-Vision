import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/profile_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Assuming google-services.json is correctly positioned)
  await Firebase.initializeApp();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('chatHistory');
  
  final box = Hive.box('settings');
  final bool hasProfile = box.containsKey('userId');

  runApp(
    ProviderScope(
      child: WoundMonitoringApp(hasProfile: hasProfile),
    ),
  );
}

class WoundMonitoringApp extends StatelessWidget {
  final bool hasProfile;
  const WoundMonitoringApp({super.key, required this.hasProfile});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Wound Monitoring',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: hasProfile ? const MainNavigationScreen() : const ProfileSetupScreen(),
    );
  }
}
