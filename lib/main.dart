import 'dart:async';
import 'package:http/http.dart';

import 'DataObjects.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Stream<RootData> fetchData() async* {
  while (true) {
    String githubURL =
        'https://raw.githubusercontent.com/vincguttmann/pt-dashb-frontend/master/assets/station.json';
    Response response = await http.get(Uri.parse(githubURL));

    if (response.statusCode == 200) {
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
    return MediaQuery(
      data: const MediaQueryData(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 3 * 2 - 1,
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3 - 4,
                    child: StationWidget(station: rootdata.stations[0])),
                const VerticalDivider(
                  indent: 0,
                  endIndent: 0,
                  width: 2,
                  thickness: 2,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3 - 4,
                  child: StationWidget(station: rootdata.stations[1]),
                ),
                const VerticalDivider(
                  indent: 0,
                  endIndent: 0,
                  width: 2,
                  thickness: 2,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3 - 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 3 * 1.58 / 2,
                          width: MediaQuery.of(context).size.width / 3 - 4,
                          child: StationWidget(station: rootdata.stations[2])),
                      const Divider(
                        endIndent: 0,
                        indent: 0,
                        color: Colors.grey,
                        thickness: 2,
                        height: 2,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 3 * 1.75 / 2,
                          width: MediaQuery.of(context).size.width / 3 - 4,
                          child: StationWidget(station: rootdata.stations[3])),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Divider(
            endIndent: 0,
            indent: 0,
            color: Colors.grey,
            thickness: 2,
            height: 2,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3 * 1 - 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3 - 4,
                    child: StationWidget(station: rootdata.stations[4])),
                const VerticalDivider(
                  indent: 0,
                  endIndent: 0,
                  width: 2,
                  thickness: 2,
                  color: Colors.grey,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3 - 4,
                    child: StationWidget(station: rootdata.stations[5])),
                const VerticalDivider(
                  indent: 0,
                  endIndent: 0,
                  width: 2,
                  thickness: 2,
                  color: Colors.grey,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3 - 4,
                    child: StationWidget(station: rootdata.stations[6])),
              ],
            ),
          ),
        ],
      ),
    );
  }
  return const Text('Ein Fehler ist aufgetreten!');
}

class StationWidget extends StatelessWidget {
  const StationWidget({super.key, required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      dataRowHeight: 65.0,
      headingRowHeight: 70,
      columns: <DataColumn>[
        DataColumn(
          label: Center(
            child: Text(
              '   ',
              style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),
            ),
          ),
        ),
        DataColumn(
          label: Center(
            child: Text(
              station.name,
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'in ... min',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headline5!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // label: Align(
          //   alignment: Alignment.centerRight,

          // ),
        ),
      ],
      rows: getList(context, station),
    );
  }
}

List<DataRow> getList(BuildContext context, Station station) {
  List<DataRow> data = List<DataRow>.generate(
    station.departures.length,
    (int index) => DataRow(
      color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        // Even rows will have a grey color.
        if (index.isEven) {
          return Colors.lightBlue.withOpacity(0.3);
        }
        return null; // Use default value for other states and odd rows.
      }),
      cells: <DataCell>[
        DataCell(
          // Image.asset()
          Text(
            station.departures[index].label ?? "",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black),
          ),
        ),
        DataCell(Text(
          station.departures[index].destination,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black),
        )),
        DataCell(DepartureTimeWidget(
            times: station.departures[index].times, onTime: station.departures[index].onTime))
      ],
    ),
  );
  data.add(
      const DataRow(cells: <DataCell>[DataCell(Text("")), DataCell(Text("")), DataCell(Text(""))]));
  return data;
}

class DepartureTimeWidget extends StatelessWidget {
  const DepartureTimeWidget({super.key, required this.times, required this.onTime});

  final List<int> times;
  final Map<int, bool> onTime;

  @override
  Widget build(BuildContext context) {
    List<Widget> timeWidgets = [];
    for (int time in times) {
      timeWidgets.add(Text(
        time.toString(),
        style: Theme.of(context)
            .textTheme
            .headlineMedium!
            .copyWith(color: ((onTime[time] ?? true) ? Colors.black : Colors.red)),
      ));
    }
    for (int i = 1; i < timeWidgets.length; i += 2) {
      timeWidgets.insert(
          i,
          Text(
            ' | ',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black),
          ));
    }
    return Row(
      children: timeWidgets,
    );
  }
}
