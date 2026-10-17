import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'shared/widgets/app_startup.dart';
import 'shared/providers/app_providers.dart';

class LingoDocApp extends ConsumerWidget {
  const LingoDocApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPreferencesProvider);

    return prefsAsync.when(
      data: (prefs) => MaterialApp(
        title: 'LingoDoc',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: prefs.themeMode,
        debugShowCheckedModeBanner: false,
        home: const AppStartup(),
      ),
      loading: () => MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, s) => MaterialApp(
        theme: AppTheme.darkTheme,
        home: const AppStartup(), // Fallback to defaults on error
      ),
    );
  }
}
