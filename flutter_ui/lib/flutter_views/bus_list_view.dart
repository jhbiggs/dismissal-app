import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bus/flutter_model/dismissal_model.dart';
import 'package:flutter_bus/flutter_objects/bus.dart';
import 'package:flutter_bus/flutter_objects/event.dart';
import 'package:flutter_bus/flutter_views/emoji_translator.dart';
import 'package:flutter_bus/flutter_db_service/flutter_db_service.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BusListView extends StatefulWidget {
  static const routeName = '/bus_list';

  const BusListView({super.key});

  @override
  State<BusListView> createState() => _BusListViewState();
}

class _BusListViewState extends State<BusListView> {
  // create a blank list of buses and a list of selected items
  List<Bus> items = [];

  // final _channel = WebSocketChannel.connect(
  //     Uri.parse('ws://dismissalapp.org:8080/notification-stream'));
  //  final _channel = WebSocketChannel.connect(
  //     Uri.parse("ws://localhost:8080/notification-stream"));
  final _channel = WebSocketChannel.connect(Uri.parse("ws://$baseUrl:80/ws"));

  @override
  void initState() {
    super.initState();
    items = DismissalModel.of(context).buses;
  }

  void _toggleBusArrival(Bus bus) {
    setState(() {
      bus.arrived = !bus.arrived;
      // Send the updated bus data to the server
      _channel.sink.add(jsonEncode(Event("bus-change", bus.toJson())));
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Widget _buildBusList(AsyncSnapshot snapshot) {
    // Check for connection state and data availability first
    if (snapshot.connectionState == ConnectionState.none ||
        snapshot.connectionState == ConnectionState.waiting ||
        snapshot.connectionState == ConnectionState.active) {
      final parsed = jsonDecode(snapshot.data.toString());
      try {
        // if the parsed data is not null, then create an event object
        // parsed value will be null on first load because there is no
        // change event to trigger the data load.
        if (parsed != null) {
          final event = Event.fromJson(parsed);
          if (event.messageType == 'bus-change') {
            final testBus = Bus.fromJson(event.message);
            // Update the bus list with the new arrival status
            items.firstWhere((element) => element.id == testBus.id).arrived =
                testBus.arrived;
          }
        }
      } on FormatException catch (e) {
        // Handle JSON format exception
        print('Error parsing JSON data: $e');
        return const Text('Error parsing data');
      } on TypeError catch (e) {
        // TODO
        print('Type Error parsing JSON data: $e');
      }
    }

    // Render ListView if data is available or connection state is none/waiting/active
    return Consumer<DismissalModel>(
        builder: (context, model, child) => 
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
              for (var index = 0; index < model.buses.length; index++)
                ...[
                  ListTile(
                    title: Text(
                      'Bus ${model.buses[index].busNumber}',
                      style:  const TextStyle(
                        // color: Theme.of(context).primaryColor,
                        fontSize: 20
                        )
                      ),
                    leading: CircleAvatar(
                     
                      child: Text(model.buses[index].animal.toEnum().emoji,
                          textScaler: const TextScaler.linear(2.0),
                          ),
                      
                    ),
                    tileColor:
                        model.buses[index].arrived ? Theme.of(context).highlightColor : Theme.of(context).cardColor,
                    onTap: () => _toggleBusArrival(model.buses[index]),
                  ),
                ]
            ]));
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
            return _buildBusList(snapshot);
          }),
    );
  }
}
