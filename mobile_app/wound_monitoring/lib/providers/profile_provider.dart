import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class UserProfile {
  final String id;
  final String name;
  final DateTime createdAt;

  UserProfile({required this.id, required this.name, required this.createdAt});
}

class ProfileNotifier extends StateNotifier<UserProfile?> {
  ProfileNotifier() : super(null) {
    _loadProfile();
  }

  void _loadProfile() {
    final box = Hive.box('settings');
    final id = box.get('userId');
    final name = box.get('userName');
    final createdAtStr = box.get('createdAt');

    if (id != null && name != null && createdAtStr != null) {
      state = UserProfile(
        id: id,
        name: name,
        createdAt: DateTime.parse(createdAtStr),
      );
    }
  }

  Future<void> createProfile(String name) async {
    final newId = const Uuid().v4();
    final now = DateTime.now();

    final box = Hive.box('settings');
    await box.put('userId', newId);
    await box.put('userName', name);
    await box.put('createdAt', now.toIso8601String());

    state = UserProfile(id: newId, name: name, createdAt: now);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  return ProfileNotifier();
});
