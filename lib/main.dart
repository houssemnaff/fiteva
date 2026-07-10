import 'package:fiteva/services/storage_service.dart';
import 'package:fiteva/services/supabase_config.dart';
import 'package:fiteva/services/stripe_config.dart';
import 'package:fiteva/services/push_notification_service.dart';
import 'package:fiteva/services/local_reminder_service.dart';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'providers/theme_provider.dart';
import 'firebase_options.dart';
// locale_provider is used via l10nProvider in individual screens

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await SupabaseConfig.initialize();

  // ── Rappels locaux (eau, repas, séance) ────────────────────────────────────
  if (!kIsWeb) {
    try {
      await LocalReminderService.init();
    } catch (e) {
      debugPrint('[Reminders] init error: $e');
    }
  }

  // ── Stripe (abonnements) ───────────────────────────────────────────────────
  try {
    await StripeConfig.initialize();
  } catch (e) {
    debugPrint('[Stripe] init error: $e');
  }

  // ── Firebase push notifications (Android / iOS uniquement) ────────────────
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await PushNotificationService.init();
    } catch (e) {
      debugPrint('[Firebase] init error: $e');
    }
  }
  // ──────────────────────────────────────────────────────────────────────────

  runApp(const ProviderScope(child: FitevaApp()));
}

class FitevaApp extends ConsumerStatefulWidget {
  const FitevaApp({super.key});

  @override
  ConsumerState<FitevaApp> createState() => _FitevaAppState();
}

class _FitevaAppState extends ConsumerState<FitevaApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestMotionPermission();
      // Push : demande la permission au premier lancement (une seule fois)
      if (!kIsWeb) {
        Future.delayed(const Duration(seconds: 3),
            PushNotificationService.requestPermissionIfNeeded);
        Future.delayed(const Duration(seconds: 4), () async {
          if (!LocalReminderService.remindersEnabled) return;
          final granted = await LocalReminderService.requestPermission();
          if (granted) await LocalReminderService.scheduleAllDefaults();
        });
      }
    });
  }

  Future<void> _requestMotionPermission() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      await Permission.activityRecognition.request();
    } else if (Platform.isIOS) {
      await Permission.sensors.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'FITEVA',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}