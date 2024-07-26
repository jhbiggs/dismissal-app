import 'package:flutter/material.dart';
import 'package:flutter_bus/flutter_db_service/flutter_db_service.dart';
import 'package:flutter_bus/flutter_objects/teacher.dart';
import 'package:flutter_bus/flutter_objects/bus.dart';
import 'package:provider/provider.dart';

class DismissalModel extends ChangeNotifier {
  List<Bus> _buses;
  List<Teacher> _teachers;

  DismissalModel(this._buses, this._teachers) {

    // get the buses and teachers from the database
    print("initiating dismissal model");
    
  }

  List<Bus> get buses => _buses;
  List<Teacher> get teachers => _teachers;

  void resetArrivalFields() async {
    print('Resetting arrival fields');
      for (var teacher in teachers) {
        if (teacher.arrived) {
          await updateTeacher(teacher);
        }
      }
    
      for (var bus in buses) {
        if (bus.arrived) {
          await updateBus(bus);
        }
      }
      // wait a second for the processes to complete
      // await Future.delayed(const Duration(seconds: 1));
    // get the buses and teachers from the database
    _teachers = await fetchTeachers();
    _buses = await fetchBuses();

    notifyListeners();
  }

  static of(BuildContext context) {
    return Provider.of<DismissalModel>(context, listen: false);
  }
}
