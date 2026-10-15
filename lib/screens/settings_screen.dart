import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Change Theme Color'),
            trailing: const Icon(Icons.color_lens),
            onTap: () {
              controller.update(Colors.teal);
            },
          ),
        ],
      ),
    );
  }
}
