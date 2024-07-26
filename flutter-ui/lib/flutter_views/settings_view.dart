import 'package:flutter/material.dart';
import 'package:flutter_bus/flutter_views/launch_view.dart';
import 'package:flutter_bus/flutter_settings/settings_service.dart';

import '../flutter_settings/settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              child: const Text("Return to Launch Screen"),
              onPressed: () async {
                final settingsController =
                    SettingsController(SettingsService());
                // Load the user's preferred theme while the splash screen is displayed.
                // This prevents a sudden theme change when the app is first displayed.
                await settingsController.loadSettings();
                // Load the buses and teachers from the JSON files
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => OnBoardingPage(
                      settingsController: settingsController,
                    ),
                  ),
                );
              },
            )
            ),
        Padding(
          padding: const EdgeInsets.all(16),
          // Glue the SettingsController to the theme selection DropdownButton.
          //
          // When a user selects a theme from the dropdown list, the
          // SettingsController is updated, which rebuilds the MaterialApp.
          child: DropdownButton<ThemeMode>(
            // Read the selected themeMode from the controller
            value: controller.themeMode,
            // Call the updateThemeMode method any time the user selects a theme.
            onChanged: controller.updateThemeMode,
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System Theme'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light Theme'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark Theme'),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
