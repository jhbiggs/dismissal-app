import 'package:flutter_bus/flutter_objects/bus.dart';
import 'package:flutter_bus/flutter_objects/teacher.dart';

class BusesAndTeachers {
  List<Bus> buses;
  List<Teacher> teachers;

  BusesAndTeachers({required this.buses, required this.teachers});

  // BusesAndTeachers.fromJson(Map<String, dynamic> json) {
  //   if (json['buses'] != null) {
  //     buses = <Bus>[];
  //     json['buses'].forEach((v) {
  //       buses.add(Bus.fromJson(v));
  //     });
  //   }
  //   if (json['teachers'] != null) {
  //     teachers = <Teacher>[];
  //     json['teachers'].forEach((v) {
  //       teachers.add(Teacher.fromJson(v));
  //     });
  //   }
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (buses.isNotEmpty) {
      data['buses'] = buses.map((v) => v.toJson()).toList();
    }
    if (teachers.isNotEmpty) {
      data['teachers'] = teachers.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
