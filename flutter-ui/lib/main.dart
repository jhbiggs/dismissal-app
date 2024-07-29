import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bus/flutter_views/bus_list_view.dart';
import 'package:flutter_bus/flutter_views/info_entry_form.dart';
import 'package:flutter_bus/flutter_views/main_view.dart';
import 'package:flutter_bus/flutter_views/settings_view.dart';
import 'package:flutter_bus/flutter_views/teacher_list_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      ChangeNotifierProvider(
          create: (context) => DismissalModel(buses, teachers)),
      Provider(create: (context) => settingsController),
    ],
    // run the app entitled "App" with the settings controller
    child: App(settingsController: settingsController),
  ));
}

class App extends StatelessWidget {
   App({super.key, required this.settingsController});
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
        darkTheme: ThemeData.dark(),
        themeMode: settingsController.themeMode,
        title: 'Introduction screen',
        debugShowCheckedModeBanner: false,
        theme: Theme.of(context),
        initialRoute:
            true ? OnBoardingPage.routeName : MainView.routeName,
        onGenerateRoute: (RouteSettings routeSettings) {
          return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case OnBoardingPage.routeName:
                    return const OnBoardingPage();
                  case TeacherListView.routeName:
                    return const TeacherListView();
                  case BusListView.routeName:
                    return const BusListView();
                  case InfoEntryForm.routeName:
                    return const InfoEntryForm();
                  default:
                    return MainView(settingsController: settingsController);
                }
                ;
              });
        });
  }
}
