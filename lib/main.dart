import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FitevaApp(),
    ),
  );
}

class FitevaApp extends StatelessWidget {
  const FitevaApp({super.key});

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
