import 'package:flutter/material.dart';
import '../screens/paywall/paywall_screen.dart';

Future<void> showPaywallSheet(
  BuildContext context, {
  required String feature,
  required String description,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: true,
      pageBuilder: (_, __, ___) => const PaywallScreen(showSkip: true),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 400),
    ),
  );
}
