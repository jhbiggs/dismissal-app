import 'package:flutter/material.dart';
import 'package:flutter_bus/flutter_views/form_views/code_page.dart';
import 'package:flutter_bus/flutter_views/info_entry_form.dart';

class InitialEntryView extends StatefulWidget {
  const InitialEntryView({super.key});

  @override
  State<InitialEntryView> createState() => _InitialEntryViewState();
}

class _InitialEntryViewState extends State<InitialEntryView> {
  @override
  Widget build(BuildContext context) {
    return const CodePage(
      title: 'Teacher and Bus Entry',
      child: InfoEntryForm(),
    );
  }
}
