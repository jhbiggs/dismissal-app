import 'package:flutter/material.dart';
import 'package:flutter_bus/flutter_db_service/flutter_db_service.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;

class InfoEntryForm extends StatefulWidget {
  const InfoEntryForm({super.key});

  @override
  State<InfoEntryForm> createState() => _InfoEntryFormState();
}

class _InfoEntryFormState extends State<InfoEntryForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _gradeFieldKey = GlobalKey<FormBuilderFieldState>();

  void _initiateNewSchema() async {
    
        await http.get(Uri.parse('http://$baseUrl:80/initiate-new-account'));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            FormBuilderTextField(
              name: 'teacherName',
              decoration: const InputDecoration(labelText: 'Teacher Name'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 10),
            FormBuilderTextField(
              key: _gradeFieldKey,
              name: 'grade',
              decoration: const InputDecoration(labelText: 'Grade'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.alphabetical()
              ]),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                MaterialButton(
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      //TODO: validate the form data

                      //TODO: save the form data
                    }
                    debugPrint(_formKey.currentState?.value.toString());
                  },
                  child: const Text('Save and Create Another',
                      style: TextStyle(color: Colors.white)),
                ),
                const Spacer(),
                MaterialButton(
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    _initiateNewSchema();
                    debugPrint(_formKey.currentState?.value.toString());
                  },
                  child:
                      const Text('Done', style: TextStyle(color: Colors.white)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
