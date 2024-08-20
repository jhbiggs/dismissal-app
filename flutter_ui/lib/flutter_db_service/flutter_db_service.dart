import 'dart:async';
import 'dart:convert';

import 'package:flutter_ui/flutter_objects/bus.dart';
import 'package:flutter_ui/flutter_objects/teacher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// const String baseUrl = 'http://ec2-52-201-69-55.compute-1.amazonaws.com:443';
// const String baseUrl = 'dismissalapp.org';
const String baseUrl = 'localhost';
// const String baseUrl = '10.44.0.48';
String accountCode = "";

Future<void> getAccountCode() async {
  await SharedPreferences.getInstance().then((prefs) {
    accountCode = prefs.getString('accountCode') ?? '';
  });
}

Future<List<Bus>> fetchBuses() async {
  await getAccountCode();

  try {
    final response =
        await http.get(Uri.parse('http://$baseUrl:80/$accountCode/buses'));
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
        return [Bus(0, 'noNumber', 'noAnimal', false)];
      }
    }
  } catch (e) {
    print("Connection error in fetchBuses(): $e");
  }
  return [Bus(0, 'noNumber', 'noAnimal', false)];
}

Future<List<Teacher>> fetchTeachers() async {
  await getAccountCode();
  try {
    final response =
        await http.get(Uri.parse('http://$baseUrl/$accountCode/teachers'));

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
        return [Teacher(0, "noTeacherButResponseOk", "noGrade", false)];
      }
    } else {
      // If the server returns an error response,
      // then throw an exception.
      return [Teacher(0, 'noTeacherButResponseOk', 'noGrade', false)];
    }
  } catch (e) {
    print("Error in loading teachers: $e");
  }
  return [Teacher(0, 'noTeacher', 'noGrade', false)];
}

Future<http.Response> toggleBusArrivalStatus(Bus bus) async {
  await getAccountCode();
  // print("Bus ID in updateBus is: ${bus.id}");
  final response = await http.put(
    Uri.parse(
        'http://$baseUrl/$accountCode/buses/${bus.id}/toggleBusArrivalStatus'),
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
  await getAccountCode();
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

Future<void> initiateNewSchema() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // check if the new schema isn't already set for this app instance
  if (prefs.getBool('isNewSchema') ?? true) {
    // if it isn't, then set the new schema
    
        await http.get(Uri.parse('http://$baseUrl:80/initiate-new-account'))
        .then((value)
          {
    try {
      final decodedJson = jsonDecode(value.body);
      final newAccountCode = decodedJson['accountCode'];
      prefs.setString('accountCode', newAccountCode);
      print("new schema initiated: $newAccountCode");

      // final newAccountCode = response.body
      prefs.setBool('isNewSchema', false);
    } catch (e) {
      print('Error decoding JSON: $e');
      return;
    }
          }
        );

  } else {
    print('Schema already initiated');
  }
}

Future<http.Response> addBusToDb(Bus newBus) async {
  await getAccountCode();
  if (accountCode == '') {
    initiateNewSchema();
  }
  return http.post(
    Uri.parse('http://$baseUrl/$accountCode/addBus'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{'bus': newBus}),
  );
}

FutureOr<http.Response> addTeacherToDb(Teacher newTeacher) async {
  await getAccountCode();
  if (accountCode == '') {
    return await initiateNewSchema().then((value) async {
      print("Adding teacher to db with name ${newTeacher.name}");
      await getAccountCode();
      // print("newTeacher object is: $newTeacher");
      final jsonValue = newTeacher.toJson();
      return http.post(
        Uri.parse('http://$baseUrl/$accountCode/addTeacher'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonValue),
      );
    });
  } else {
    final jsonValue = newTeacher.toJson();
    print("Adding teacher to db with name ${newTeacher.name}.  Already created account code.");

    return http.post(
      Uri.parse('http://$baseUrl/$accountCode/addTeacher'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(jsonValue),
    );
  }
}
