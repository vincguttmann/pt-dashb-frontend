import 'dart:async';
import 'package:http/http.dart';

import 'DataObjects.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Stream<RootData> fetchData() async* {
  while (true) {
    String githubURL =
        'https://raw.githubusercontent.com/vincguttmann/pt-dashb-frontend/master/assets/station.json';
    print('getting URL now');
    Response response = await http.get(Uri.parse(githubURL));

    if (response.statusCode == 200) {
      print('response 200!');
      // If the server did return a 200 OK response,
      // then parse the JSON.
      yield RootData.fromString(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
    await Future.delayed(const Duration(seconds: 45));
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        body: StreamBuilder<RootData>(
          stream: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print('new build triggered!');
              print(snapshot.data!.stations[0].departures[0].destination);
              return buildLayout(context, snapshot.data!);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

Widget buildLayout(BuildContext context, RootData rootdata) {
  if (rootdata.stations.length == 7) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: StationWidget(station: rootdata.stations[0])),
                const VerticalDivider(
                  indent: 0,
                  endIndent: 0,
                  width: 2,
                  thickness: 2,
                  color: Colors.grey,
                ),
                Flexible(child: StationWidget(station: rootdata.stations[1])),
                const VerticalDivider(
                  indent: 0,
                  endIndent: 0,
                  width: 2,
                  thickness: 2,
                  color: Colors.grey,
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StationWidget(station: rootdata.stations[2]),
                      const Divider(
                        endIndent: 0,
                        indent: 0,
                        color: Colors.grey,
                        thickness: 2,
                        height: 2,
                      ),
                      StationWidget(station: rootdata.stations[3]),
                      Container(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        const Divider(
          endIndent: 0,
          indent: 0,
          color: Colors.grey,
          thickness: 2,
          height: 2,
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: StationWidget(station: rootdata.stations[4])),
              const VerticalDivider(
                indent: 0,
                endIndent: 0,
                width: 2,
                thickness: 2,
                color: Colors.grey,
              ),
              Flexible(child: StationWidget(station: rootdata.stations[5])),
              const VerticalDivider(
                indent: 0,
                endIndent: 0,
                width: 2,
                thickness: 2,
                color: Colors.grey,
              ),
              Flexible(child: StationWidget(station: rootdata.stations[6])),
            ],
          ),
        ),
      ],
    );
  }
  return Text('Ein Fehler ist aufgetreten!');
}

class StationWidget extends StatelessWidget {
  const StationWidget({super.key, required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: <DataColumn>[
        const DataColumn(
          label: Center(
            child: Text(''
            ),
          ),
        ),        DataColumn(
          label: Center(
            child: Text(
              station.name,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
        ),        DataColumn(
          label: Center(
            child: Text(
              'min',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
      ],
      rows: List<DataRow>.generate(
        station.departures.length,
        (int index) => DataRow(
          /// color: MaterialStateProperty.resolveWith<Color?>(
          ///         (Set<MaterialState> states) {
          ///       // All rows will have the same selected color.
          ///       if (states.contains(MaterialState.selected)) {
          ///         return Theme.of(context).colorScheme.primary.withOpacity(0.08);
          ///       }
          ///       // Even rows will have a grey color.
          ///       if (index.isEven) {
          ///         return Colors.grey.withOpacity(0.3);
          ///       }
          ///       return null; // Use default value for other states and odd rows.
          ///     }),
          cells: <DataCell>[DataCell(Text(station.departures[index].label ?? "")),DataCell(Text(station.departures[index].destination)),DataCell(Text(station.departures[index].times.toString()))],
        ),
      ),
    );
  }
}
