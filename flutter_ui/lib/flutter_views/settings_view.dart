import 'package:flutter/material.dart';
import 'package:flutter_bus/flutter_views/launch_view.dart';
import 'package:flutter_bus/flutter_settings/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../flutter_settings/settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
   const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const routeName = '/settings';

  final SettingsController controller;

    @override
  State<StatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        prefs = prefs;
      });
    });
  }

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

                // Load the buses and teachers from the JSON files
                Navigator.pushNamed(context, OnBoardingPage.routeName
                );
              },
            )),
        Padding(
          padding: const EdgeInsets.all(16),
          // Glue the SettingsController to the theme selection DropdownButton.
          //
          // When a user selects a theme from the dropdown list, the
          // SettingsController is updated, which rebuilds the MaterialApp.
          child: DropdownButton<ThemeMode>(
            // Read the selected themeMode from the controller
            value: widget.controller.themeMode,
            // Call the updateThemeMode method any time the user selects a theme.
            onChanged: widget.controller.updateThemeMode,
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: ListTile(
            title: Text(prefs?.getString('accountCode') ??
                'Account Code will Appear Here'),
          ),
        ),
      ]),
    );
  }
  

}