import 'package:fiteva/services/storage_service.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init(); // Initialize local persistence immediately
  runApp(const ProviderScope(child: FitevaApp()));
}

class FitevaApp extends StatefulWidget {
  const FitevaApp({super.key});

  @override
  State<FitevaApp> createState() => _FitevaAppState();
}

class _FitevaAppState extends State<FitevaApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestMotionPermission();
    });
  }

  Future<void> _requestMotionPermission() async {
    if (Platform.isAndroid) {
      await Permission.activityRecognition.request();
    } else if (Platform.isIOS) {
      await Permission.sensors.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FITEVA',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
