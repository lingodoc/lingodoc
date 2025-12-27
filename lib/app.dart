import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'shared/widgets/app_startup.dart';

class LingoDocApp extends ConsumerWidget {
  const LingoDocApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'LingoDoc',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // TODO: Make configurable in Step 15
      debugShowCheckedModeBanner: false,
      home: const AppStartup(),
    );
  }
}
