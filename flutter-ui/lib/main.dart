import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'flutter_db_service/flutter_db_service.dart';
import 'flutter_model/dismissal_model.dart';
import 'flutter_settings/settings_controller.dart';
import 'flutter_settings/settings_service.dart';
import 'flutter_views/launch_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  final buses = await fetchBuses();
  final teachers = await fetchTeachers();

 // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());
  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  // Load the buses and teachers from the JSON files

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create:(context) => DismissalModel(buses, teachers)),
      Provider(create: (context) => settingsController),
      ],
      // run the app entitled "App" with the settings controller
    child:  App(settingsController: settingsController),
  ));
}

class App extends StatelessWidget {
  
  const App({super.key, required this.settingsController});
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'Introduction screen',
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context),
      home:  OnBoardingPage(settingsController: settingsController),
    );
  }
}


