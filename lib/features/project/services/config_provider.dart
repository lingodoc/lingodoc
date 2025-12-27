import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config_service.dart';

/// Provider for the ConfigService singleton.
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});
