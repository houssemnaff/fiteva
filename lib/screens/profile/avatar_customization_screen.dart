import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';

class AvatarCustomizationScreen extends StatelessWidget {
  const AvatarCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Avatar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          FluttermojiCircleAvatar(radius: 60, backgroundColor: Colors.grey[200]),
          const SizedBox(height: 24),
          Expanded(
            child: FluttermojiCustomizer(
              scaffoldWidth: MediaQuery.of(context).size.width,
              scaffoldHeight: MediaQuery.of(context).size.height * 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
