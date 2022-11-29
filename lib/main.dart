import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<RootData> fetchAlbum() async {
  final response = await http.get(Uri.parse(
      'https://raw.githubusercontent.com/vincguttmann/pt-dashb-frontend/master/assets/station.json'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return RootData.fromString(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
}

class RootData {
  final List<Station> stations;

  const RootData({
    required this.stations,
  });

  factory RootData.fromString(String jsonstring) {
    Map<String, dynamic> stations = jsonDecode(jsonstring)['stations'];
    List<Station> stationList = [];
    for (var stationKey in stations.keys) {
      stationList.add(Station.fromJson(stations[stationKey], stationKey));
    }
    return RootData(
      stations: stationList,
    );
  }

  @override
  String toString() {
    String string = 'rootData:\n';
    for (Station station in stations) {
      string += station.toString();
    }
    return string;
  }
}

class Station {
  final String name;
  final List<Departure> departures;

  const Station({
    required this.name,
    required this.departures,
  });

  factory Station.fromJson(Map<String, dynamic> json, String name) {
    List<Departure> departures = [];
    for (Map<String, dynamic> departure in (json['departures'] as List)) {
      List<int> times = [];
      Map<int, bool> onTime = {};
      for (var departureTime in (departure['times'] as List)) {
        times.add(departureTime['minutesTillDeparture']);
        onTime[departureTime['minutesTillDeparture']] = departureTime['onTime'];
      }
      departures.add(Departure(
          destination: departure['destination'],
          label: departure['label'],
          times: times,
          onTime: onTime,
          transportType: departure['transportType']));
    }
    return Station(name: name, departures: departures);
  }

  @override
  String toString() {
    String string = '  $name: \n';
    for (Departure departure in departures) {
      string += (departure as Departure).toString();
    }
    return string;
  }
}

class Departure {
  final String destination;
  final String? label;
  final String transportType;
  final List<int> times;
  final Map<int, bool> onTime;

  const Departure({
    required this.destination,
    this.label,
    required this.transportType,
    required this.times,
    required this.onTime,
  });

  @override
  String toString() {
    String string = '    $label $destination ($transportType):\n';
    for (int time in times) {
      string += '      $time: ${onTime[time]}\n';
    }
    return string;
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<RootData> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<RootData>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.toString());
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
