import 'dart:async';
import 'dart:convert';

import 'DataObjects.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Stream<RootData> fetchData() async* {
  while (true) {
    await Future.delayed(Duration(seconds: 30));
    String githubURL =
        'https://raw.githubusercontent.com/vincguttmann/pt-dashb-frontend/master/assets/station.json';
    final response = await http.get(Uri.parse(githubURL));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      yield RootData.fromString(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
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
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: StreamBuilder<RootData>(
            stream: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.toString());
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
