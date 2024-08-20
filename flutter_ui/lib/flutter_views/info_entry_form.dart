import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ui/flutter_db_service/flutter_db_service.dart';
import 'package:flutter_ui/flutter_model/dismissal_model.dart';
import 'package:flutter_ui/flutter_objects/bus.dart';
import 'package:flutter_ui/flutter_objects/teacher.dart';
import 'package:flutter_ui/flutter_views/main_view.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InfoEntryForm extends StatefulWidget {
  const InfoEntryForm({super.key});
  static const routeName = '/info_entry_form';

  @override
  State<InfoEntryForm> createState() => _InfoEntryFormState();
}

class _InfoEntryFormState extends State<InfoEntryForm> {
  final _gotCodeFieldKey = GlobalKey<FormBuilderFieldState>();
  // store the new entries in an array
  List<Teacher> _newTeachers = [];
  List<Bus> _newBuses = [];
  late int busIdCounter;
  late String accountCode;
  late SharedPreferences prefs;
  final _busFormKey = GlobalKey<FormBuilderState>();
  final _teacherFormKey = GlobalKey<FormBuilderState>();

  Future<bool> _validateCode(String? testCode) async {
    var response =
        await http.get(Uri.parse('http://$baseUrl:80/$testCode/check-schemas'));

    final decodedResponse = jsonDecode(response.body);
    if (decodedResponse['error'] != null) {
      return false;
    } else {
      prefs.setString("accountCode", decodedResponse["accountCode"]);

      return true;
    }
  }

  void _getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    busIdCounter = prefs.getInt('busIdCounter') ?? 0;
    accountCode = prefs.getString('accountCode') ?? 'no code set';
  }

  void _updateBusesAndTeachers() async {
    print('flutter update buses called  ');
    await DismissalModel.of(context).addNewData(_newTeachers, _newBuses);
  }

  @override
  void initState() {
    super.initState();
    _getSharedPrefs();
    _newBuses = DismissalModel.of(context).buses;
    _newTeachers = DismissalModel.of(context).teachers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Enter Teacher and Bus Information'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                FormBuilder(
                    key: _teacherFormKey,
                    child: Column(
                      children: [
                        Card(
                          child: FormBuilderTextField(
                            key: const ValueKey('teacherName'),
                            focusNode: FocusNode(),
                            name: 'teacherName',
                            decoration: const InputDecoration(
                                labelText: 'Teacher Name'),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: FormBuilderTextField(
                            key: const ValueKey('grade'),
                            name: 'grade',
                            decoration:
                                const InputDecoration(labelText: 'Grade'),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.alphabetical()
                            ]),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            MaterialButton(
                              key: const ValueKey('submitTeacher'),
                              color: Theme.of(context).colorScheme.secondary,
                              onPressed: () {
                                if (_teacherFormKey.currentState
                                        ?.saveAndValidate() ??
                                    true) {
                                  final teacherName = _teacherFormKey
                                      .currentState?.value['teacherName'];
                                  final grade = _teacherFormKey
                                      .currentState?.value['grade'];
                                  final newTeacher =
                                      Teacher(0, teacherName, grade, false);
                                  _newTeachers.add(newTeacher);
                                  _teacherFormKey.currentState?.reset();
                                  FocusScope.of(context).requestFocus(
                                      _teacherFormKey
                                          .currentState
                                          ?.fields['teacherName']
                                          ?.effectiveFocusNode);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Teacher $teacherName added to grade $grade'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please correct the errors'),
                                    ),
                                  );
                                }
                                debugPrint(_teacherFormKey.currentState?.value
                                    .toString());
                              },
                              child: const Text('Submit Teacher',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    )),
                FormBuilder(
                  key: _busFormKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        key: const Key('busNumber'),
                        focusNode: FocusNode(),
                        name: 'busNumber',
                        decoration:
                            const InputDecoration(labelText: 'Bus Number'),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        key: const Key('animal'),
                        name: 'animal',
                        decoration:
                            const InputDecoration(labelText: 'Bus Icon/Animal'),
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
                              if (_busFormKey.currentState?.saveAndValidate() ??
                                  true) {
                                final busNumber = _busFormKey
                                    .currentState?.value['busNumber'];
                                final busAnimal =
                                    _busFormKey.currentState?.value['animal'];
                                // auto increment the busId
                                final busId = busIdCounter++;
                                // store the new busIdCounter in shared prefs
                                prefs.setInt('busIdCounter', busIdCounter);
                                final newBus =
                                    Bus(busId, busNumber, busAnimal, false);
                                _newBuses.add(newBus);
                                _busFormKey.currentState?.reset();
                                FocusScope.of(context).requestFocus(_busFormKey
                                    .currentState
                                    ?.fields['busNumber']
                                    ?.effectiveFocusNode);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Bus #$busNumber added to the fleet with icon $busAnimal'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please correct the errors'),
                                  ),
                                );
                              }
                              debugPrint(
                                  _busFormKey.currentState?.value.toString());
                            },
                            child: const Text('Save and Create Another',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // save the new teachers and buses to the database

                            initiateNewSchema();
                            _updateBusesAndTeachers();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Teachers and Buses saved to the database'),
                              ),
                            );

                            //launch the app
                            Navigator.pushNamed(context, MainView.routeName);
                          },
                          child: const Text('Save All and Go'),
                        )
                      ],
                    ),
                    const Spacer(),
                    ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            prefs.clear();
                            print(
                                'New schema initiated: ${prefs.getBool('newSchema')}');
                          },
                          child: const Text('Reset'),
                        )
                      ],
                    ),
                  ],
                ),
                FormBuilderTextField(
                  key: _gotCodeFieldKey,
                  name: 'gotCode',
                  decoration: const InputDecoration(labelText: 'Have a Code?'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.alphabetical(),
                    // get all the schemas from the database and compare to
                    // the code entered
                  ]),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // check if the code entered is correct

                    await _validateCode(_gotCodeFieldKey.currentState?.value)
                        .then((isValidCode) {
                      if (isValidCode) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Found a code!'),
                          ),
                        );
                        prefs.setString('accountCode',
                            _gotCodeFieldKey.currentState?.value);
                        prefs.setBool('isNewSchema', false);
                        DismissalModel.of(context).refreshData();

                        //launch the app
                        Navigator.pushNamed(context, MainView.routeName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No code found'),
                          ),
                        );
                      }
                    });
                  },
                  child: const Text('Add Code and Go'),
                )
              ],
            )));
  }
}
