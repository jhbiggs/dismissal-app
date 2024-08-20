import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ui/flutter_db_service/flutter_db_service.dart';
import 'package:flutter_ui/flutter_objects/teacher.dart';
import 'package:flutter_ui/flutter_objects/bus.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class DismissalModel extends ChangeNotifier {
  List<Bus> _buses;
  List<Teacher> _teachers;

  DismissalModel(this._buses, this._teachers);

  List<Bus> get buses => _buses;
  List<Teacher> get teachers => _teachers;

  void addTeacher(Teacher teacher) async {
    print("Adding teacher in dismissal model: ${teacher.name}");
    // Add teacher to the database
    _teachers.add(teacher);
    // Code to add teacher to the database goes here
    var newTeacher = await addTeacherToDb(teacher);
    print("New teacher added: $newTeacher");
    _teachers = await fetchTeachers();
    notifyListeners();
  }

  void addBus(Bus bus) async {
    await addBusToDb(bus);
    _buses.add(bus);
    notifyListeners();
  }

  void resetArrivalFields() async {
    print('Resetting arrival fields');
    for (var teacher in _teachers) {
      if (teacher.arrived) {
        await toggleTeacherArrivalStatus(teacher);
      }
    }

    for (var bus in _buses) {
      if (bus.arrived) {
        await toggleBusArrivalStatus(bus);
      }
    }

    // get the buses and teachers from the database
    _teachers = await fetchTeachers();
    _buses = await fetchBuses();

    notifyListeners();
  }

  void refreshData() async {
    _teachers = await fetchTeachers();
    _buses = await fetchBuses();
    notifyListeners();
  }

  static of(BuildContext context) {
    return Provider.of<DismissalModel>(context, listen: false);
  }

  void addNewData(List<Teacher> newTeachers, List<Bus> newBuses) async {
    await getAccountCode();
        // get the buses and teachers from the database
    _teachers = await fetchTeachers();
    _buses = await fetchBuses();
    // Update the model with the new data
    if (newTeachers.isNotEmpty) {
      _teachers.addAll(newTeachers);
    }
    if (newBuses.isNotEmpty) {
      _buses.addAll(newBuses);
    }

    final body =
        jsonEncode(newTeachers.map((teacher) => teacher.toJson()).toList());

    // Add new teachers to the database
    final url = 'http://$baseUrl/$accountCode/addTeacherList';

    final headers = {'Content-Type': 'application/json'};

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      print("New teachers sent to server successfully");
      newTeachers.clear(); // Clear the list after successful submission
    } else {
      print("Failed to send new teachers to server: ${response.statusCode}");
    }

    notifyListeners();
  }
}
