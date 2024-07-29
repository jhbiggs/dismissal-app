import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bus/flutter_db_service/flutter_db_service.dart';
import 'package:flutter_bus/flutter_model/dismissal_model.dart';
import 'package:flutter_bus/flutter_objects/bus.dart';
import 'package:flutter_bus/flutter_objects/teacher.dart';
import 'package:flutter_bus/flutter_views/main_view.dart';
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
  final _teacherFormKey = GlobalKey<FormBuilderState>();
  final _busFormKey = GlobalKey<FormBuilderState>();
  final _gradeFieldKey = GlobalKey<FormBuilderFieldState>();
  final _busNumberFieldKey = GlobalKey<FormBuilderFieldState>();
  // store the new entries in an array
  final List<Teacher> _newTeachers = [];
  final List<Bus> _newBuses = [];
  late int teacherIdCounter;
  late int busIdCounter;
  late SharedPreferences prefs;

  void _initiateNewSchema() async {
    // check if the new schema isn't already set for this app instance
    if (prefs.getBool('isNewSchema') ?? true) {
      // if it isn't, then set the new schema
      final response =
          await http.get(Uri.parse('http://$baseUrl:80/initiate-new-account'));
      final decodedJson = jsonDecode(response.body);
      print(response.body);
      final newAccountCode = decodedJson['accountCode'];
      // prefs.setString('newAccountCode', newAccountCode);
      print("new schema initiated: $newAccountCode");

      // final newAccountCode = response.body
      prefs.setBool('isNewSchema', false);
    } else {
      print('Schema already initiated');
    }
  }

  void _getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    teacherIdCounter = prefs.getInt('teacherIdCounter') ?? 0;
    busIdCounter = prefs.getInt('busIdCounter') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Enter Teacher and Bus Information'),
        ),
      body: 
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FormBuilder(
                  key: _teacherFormKey,
                  child:  Column(
                    children: [
                
                      Card(
                        child: FormBuilderTextField(
                          focusNode: FocusNode(),
                          name: 'teacherName',
                          decoration:
                              const InputDecoration(labelText: 'Teacher Name'),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: FormBuilderTextField(
                          key: _gradeFieldKey,
                          name: 'grade',
                          decoration: const InputDecoration(labelText: 'Grade'),
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
                                    color: Theme.of(context).colorScheme.secondary,
                                    onPressed: () {
                                      if (_teacherFormKey.currentState?.saveAndValidate() ??
                                          true) {
                                        final teacherName = _teacherFormKey
                                            .currentState?.value['teacherName'];
                                        final grade =
                                            _teacherFormKey.currentState?.value['grade'];
                                        final teacherId = teacherIdCounter++;
                                        prefs.setInt('teacherIdCounter', teacherIdCounter);
                                        final newTeacher =
                                            Teacher(teacherId, teacherName, grade, false);
                                        _newTeachers.add(newTeacher);
                                        _teacherFormKey.currentState?.reset();
                                        FocusScope.of(context).requestFocus(_teacherFormKey
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
                                            content: Text('Please correct the errors'),
                                          ),
                                        );
                                      }
                                      debugPrint(
                                          _teacherFormKey.currentState?.value.toString());
                                    },
                                    child: const Text('Save and Create Another',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  const Spacer(),
                                  MaterialButton(
                                    color: Theme.of(context).colorScheme.secondary,
                                    onPressed: () {
                                      _initiateNewSchema();
                                      debugPrint(
                                          _teacherFormKey.currentState?.value.toString());
                                    },
                                    child: const Text('Done with Teachers',
                                        style: TextStyle(color: Colors.white)),
                                  )
                                ],
                              ),
                            ],
                          )),
                      FormBuilder(
                        key: _busFormKey,
                        child: Column(
                          children: [
                            FormBuilderTextField(
                              focusNode: FocusNode(),
                              name: 'busNumber',
                              decoration: const InputDecoration(labelText: 'Bus Number'),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                            const SizedBox(height: 10),
                            FormBuilderTextField(
                              key: _busNumberFieldKey,
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
                                      final busNumber =
                                          _busFormKey.currentState?.value['busNumber'];
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
                                    debugPrint(_busFormKey.currentState?.value.toString());
                                  },
                                  child: const Text('Save and Create Another',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                const Spacer(),
                                MaterialButton(
                                  color: Theme.of(context).colorScheme.secondary,
                                  onPressed: () {
                                    _initiateNewSchema();
                                    debugPrint(_busFormKey.currentState?.value.toString());
                                  },
                                  child: const Text('Done with Buses',
                                      style: TextStyle(color: Colors.white)),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // save the new teachers and buses to the database
                              DismissalModel.of(context).addNewData(_newTeachers, _newBuses);
                      
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Teachers and Buses saved to the database'),
                                ),
                              );
                              //launch the app
                              Navigator.pushNamed(context, MainView.routeName);
                            },
                            child: const Text('Save All'),
                          )
                        ],
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              prefs.clear();
                              print('New schema initiated: ${prefs.getBool('newSchema')}');
                            },
                            child: const Text('Reset'),
                  )
                ],
              ),
                
          
        ],
    )));
      
  }
  }

