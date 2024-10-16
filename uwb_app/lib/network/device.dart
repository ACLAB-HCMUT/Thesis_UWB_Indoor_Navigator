import 'dart:convert';
import 'package:http/http.dart' as http;

class History {
  final String id;
  final double x;
  final double y;
  final DateTime createdAt;

  History({
    required this.id,
    required this.x,
    required this.y,
    required this.createdAt,
  });

  // Factory method to create History from JSON
  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['_id'], // Mapping '_id' from JSON to 'id' in Dart
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Device {
  final String id;
  final String name;
  final List<History> histories;
  final DateTime createdAt;
  final DateTime updatedAt;

  Device({
    required this.id,
    required this.name,
    required this.histories,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create Device from JSON
  factory Device.fromJson(Map<String, dynamic> json) {
    var historiesFromJson = json['histories'] as List;
    List<History> historyList = historiesFromJson.map((i) => History.fromJson(i)).toList();

    return Device(
      id: json['_id'], // Mapping '_id' from JSON to 'id' in Dart
      name: json['name'],
      histories: historyList,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class DeviceService {
  final String baseUrl = 'http://localhost:3000/device';

  // Method to fetch device by ID
  Future<Device> fetchDevice(String deviceId) async {
    final response = await http.get(Uri.parse('$baseUrl/$deviceId'));

    if (response.statusCode == 200) {
      // If the server returns a successful response, parse the JSON
      final res = Device.fromJson(json.decode(response.body));
      print(res.id);
      return res;
    } else {
      // If the server returns an error, throw an exception
      throw Exception('Failed to load device');
    }
  }
}
