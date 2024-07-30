import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bus/flutter_db_service/flutter_db_service.dart';
import 'package:flutter_bus/flutter_model/dismissal_model.dart';
import 'package:flutter_bus/flutter_objects/event.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../flutter_objects/teacher.dart';

class TeacherListView extends StatefulWidget {
  static const routeName = '/teacher_list_view';

  const TeacherListView({super.key});

  @override
  State<TeacherListView> createState() => _TeacherListViewState();
}

class _TeacherListViewState extends State<TeacherListView> {
  // create a blank list of teachers and a list of selected items
  List<Teacher> items = [];

  // final _channel = WebSocketChannel.connect(
  //     Uri.parse('ws://dismissalapp.org:8080/notification-stream'));
  final _channel = WebSocketChannel.connect(Uri.parse("ws://$baseUrl:80/ws"));

  @override
  void initState() {
    super.initState();
    items = DismissalModel.of(context).teachers;
  }

  void _toggleTeacherArrival(Teacher teacher) {
    setState(() {
      teacher.arrived = !teacher.arrived;
      // Send the updated teacher data to the server
      _channel.sink.add(jsonEncode(Event("teacher-change", teacher.toJson())));
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Widget _buildTeacherList(AsyncSnapshot snapshot) {
    // Check for connection state and data availability first
    if (snapshot.connectionState == ConnectionState.none ||
        snapshot.connectionState == ConnectionState.waiting ||
        snapshot.connectionState == ConnectionState.active) {
      final parsed = jsonDecode(snapshot.data.toString());
      try {
        // if the parsed data is not null, then create an event object
        // parsed value will be null on first load because there is no
        // data to parse
        if (parsed != null) {
          final event = Event.fromJson(parsed);
          if (event.messageType == 'teacher-change') {
            final teacher = Teacher.fromJson(event.message);
            // Update the items with the new arrival status
            items.firstWhere((element) => element.id == teacher.id).arrived =
                teacher.arrived;
          }
        }
      } on FormatException catch (e) {
        // TODO
        print('Error parsing JSON data: $e');
      } on TypeError catch (e) {
        // TODO
        print('Type Error parsing JSON data: $e');
      }
      return Consumer<DismissalModel>(
          builder: (context, model, child) =>
              ListView(
                padding: const EdgeInsets.all(16), 
                children: [
                for (var index = 0; index < model.teachers.length; index++) ...[
                  ListTile(
                    title: Text('Teacher ${model.teachers[index].name}'),
                    leading: const CircleAvatar(
                      // backgroundColor: Color.fromARGB(153, 133, 128, 128),
                      child: Icon(Icons.person),
                    ),
                    tileColor: model.teachers[index].arrived
                        ? Theme.of(context).highlightColor
                        : Theme.of(context).cardColor,
                    onTap: () => _toggleTeacherArrival(model.teachers[index]),
                  )
                ]
              ]));
    }
    return const Text('No data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // To work with lists that may contain a large number of items, it’s best
        // to use the ListView.builder constructor.
        //
        // In contrast to the default ListView constructor, which requires
        // building all Widgets up front, the ListView.builder constructor lazily
        // builds Widgets as they’re scrolled into view.
        body: StreamBuilder(
      stream: _channel.stream,
      builder: (context, snapshot) {
        return _buildTeacherList(snapshot);
      },
    ));
  }
}
