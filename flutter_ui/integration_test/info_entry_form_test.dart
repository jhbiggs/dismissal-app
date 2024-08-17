import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui/flutter_settings/settings_controller.dart';
import 'package:flutter_ui/flutter_settings/settings_service.dart';
import 'package:flutter_ui/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Enter a teacher name',
        (tester) async {
      // Load app widget.
      await tester.pumpWidget(App(settingsController: SettingsController(SettingsService())));

      // Verify the counter starts at 0.
      expect(find.text(''), findsOneWidget);

      // Finds the floating action button to tap on.
      final fab = find.byKey(const ValueKey('teacherName'));

      // Emulate a tap on the floating action button.
      await tester.enterText(find.byKey(const ValueKey('teacherName')), "TeacherTest");

      // Trigger a frame.
      await tester.pumpAndSettle();

      // Verify the counter increments by 1.
      expect(find.text('TeacherTest'), findsOneWidget);
    });
  });
}