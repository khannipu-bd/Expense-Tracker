import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/app_localizations.dart';
import '../features/security/presentation/screens/app_lock_screen.dart';
import 'providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class HisablyApp extends ConsumerStatefulWidget {
  const HisablyApp({super.key});

  @override
  ConsumerState<HisablyApp> createState() => _HisablyAppState();
}

class _HisablyAppState extends ConsumerState<HisablyApp> {
  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final settings = settingsAsync.value;
    final themeMode = settings?.themeMode ?? ThemeMode.system;
    final languageCode = settings?.languageCode ?? 'en';
    final isAppLockEnabled = settings?.isAppLockEnabled ?? false;

    final shouldShowLock = isAppLockEnabled && !_isAuthenticated;

    return MaterialApp.router(
      title: 'Hisably',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: Locale(languageCode),
      supportedLocales: const [Locale('en', ''), Locale('bn', '')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final clampedTextScaler = mediaQueryData.textScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.25,
        );
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: clampedTextScaler),
          child: shouldShowLock
              ? AppLockScreen(
                  onUnlocked: () {
                    setState(() {
                      _isAuthenticated = true;
                    });
                  },
                )
              : (child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
