import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_preferences.dart';

/// Service for loading and saving user preferences to SharedPreferences.
class SettingsService {
  static const String _prefsKey = 'user_preferences';

  /// Load user preferences from SharedPreferences.
  ///
  /// Returns default UserPreferences if none are saved.
  Future<UserPreferences> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);

      if (jsonString == null) {
        return const UserPreferences();
      }

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return UserPreferences.fromJson(jsonMap);
    } catch (e) {
      // If loading fails, return defaults
      return const UserPreferences();
    }
  }

  /// Save user preferences to SharedPreferences.
  Future<void> save(UserPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonMap = preferences.toJson();
      final jsonString = json.encode(jsonMap);
      await prefs.setString(_prefsKey, jsonString);
    } catch (e) {
      // Failed to save preferences - non-critical, ignore silently
    }
  }

  /// Reset preferences to defaults by removing saved data.
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (e) {
      // Failed to reset preferences - ignore silently
    }
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

/// Provider for the settings service.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// Notifier for managing user preferences state.
class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  @override
  Future<UserPreferences> build() async {
    final service = ref.read(settingsServiceProvider);
    return await service.load();
  }

  /// Update preferences and persist to storage.
  Future<void> updatePreferences(UserPreferences prefs) async {
    final service = ref.read(settingsServiceProvider);
    await service.save(prefs);
    state = AsyncValue.data(prefs);
  }

  /// Reset preferences to defaults.
  Future<void> resetToDefaults() async {
    final service = ref.read(settingsServiceProvider);
    await service.reset();
    state = const AsyncValue.data(UserPreferences());
  }
}

/// Provider for user preferences with async loading.
final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences>(
      UserPreferencesNotifier.new,
    );
