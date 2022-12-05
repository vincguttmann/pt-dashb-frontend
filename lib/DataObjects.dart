import 'dart:convert';

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

  factory Station.fromJson(List json, String name) {
    List<Departure> departures = [];
    print(json);
    for (Map<String, dynamic> departure in (json as List)) {
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
      string += departure.toString();
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