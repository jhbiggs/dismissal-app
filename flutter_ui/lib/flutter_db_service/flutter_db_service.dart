import 'dart:convert';

import 'package:flutter_bus/flutter_objects/bus.dart';
import 'package:flutter_bus/flutter_objects/buses_and_teachers.dart';
import 'package:flutter_bus/flutter_objects/teacher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// const String baseUrl = 'http://ec2-52-201-69-55.compute-1.amazonaws.com:443';
const String baseUrl = 'dismissalapp.org';
// const String baseUrl = 'localhost';
// const String baseUrl = '10.44.0.48';
String accountCode = 'dismissal_schema';

void getAccountCode() async {
  accountCode = await SharedPreferences.getInstance()
      .then((prefs) => prefs.getString('accountCode') ?? 'dismissal_schema');
}

Future<List<Bus>> fetchBuses() async {
  final response = await http.get(Uri.parse('https://$baseUrl/buses'));

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> list = json.decode(response.body);
    if (list['buses'] != null) {
      List<Bus> buses =
          list['buses'].map<Bus>((bus) => Bus.fromJson(bus)).toList();
      buses.sort((a, b) => a.busNumber.compareTo(b.busNumber));
      return buses;
    } else {
      return [];
    }
  } else {
    // If the server returns an error response,
    // then throw an exception.
    throw Exception('Failed to load buses');
  }
}

Future<List<Teacher>> fetchTeachers() async {
  final response = await http.get(Uri.parse('http://$baseUrl/teachers'));

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    // print("fetch Teachers response is: "+response.body);
    Map<String, dynamic> list = json.decode(response.body);
    if (list['teachers'] != null) {
      List<Teacher> teachers = list['teachers']
          .map<Teacher>((teacher) => Teacher.fromJson(teacher))
          .toList();
      teachers.sort((a, b) => a.name.compareTo(b.name));
      return teachers;
    } else {
      return [];
    }
  } else {
    // If the server returns an error response,
    // then throw an exception.
    throw Exception('Failed to load teachers');
  }
}

Future<http.Response> updateBus(Bus bus) async {
  // print("Bus ID in updateBus is: ${bus.id}");
  final response = await http.put(
    Uri.parse('http://$baseUrl/buses/${bus.id}/toggleBusArrivalStatus'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, bool>{'arrived': bus.arrived}),
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    return response;
  } else {
    // If the server returns an error response,
    // then throw an exception.
    throw Exception('Failed to update bus, error code: ${response.statusCode}');
  }
}

Future<http.Response> toggleTeacherArrivalStatus(Teacher teacher) async {
  // print("Teacher ID in updateTeacher is: ${teacher.name}\n and id is: ${teacher.id}");
  getAccountCode();
  final response = await http.put(
    Uri.parse(
        'http://$baseUrl/$accountCode/teachers/${teacher.id}/toggleTeacherArrivalStatus'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, bool>{'arrived': teacher.arrived}),
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    return response;
  } else {
    // If the server returns an error response,
    // then throw an exception.
    throw Exception(
        'Failed to update teacher, error code: ${response.statusCode}');
  }
}

Future<http.Response> sendListOfTeachers(
    BusesAndTeachers busesAndTeachers) async {
  final response = await http.put(
      Uri.parse('http://$baseUrl/addListofTeachers'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, BusesAndTeachers>{'buses-and-teachers': busesAndTeachers}));

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    return response;
  } else {
    // If the server returns an error response,
    // then throw an exception.
    throw Exception(
        'Failed to add teacher list, error code: ${response.statusCode}');
  }
}