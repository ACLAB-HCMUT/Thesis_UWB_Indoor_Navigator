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

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['_id'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
    );
  }
}

class Device {
  final String id;
  final String name;
  final List<dynamic> histories;
  final DateTime createdAt;
  final DateTime updatedAt;
  String status;
  String location;
  final String img;

  Device({
    required this.id,
    required this.name,
    required this.histories,
    required this.createdAt,
    required this.updatedAt,
    this.status = "Not Active",
    this.location = "Out of the room",
    this.img = "uwb.png",
  });

  factory Device.jsonToDevice(Map<String, dynamic> json) {
    var historiesFromJson = json['histories'] as List;
    List<History> historyList =
        historiesFromJson.map((i) => History.fromJson(i)).toList();

    Device device = Device(
      id: json['_id'],
      name: json['name'],
      histories: historyList,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );

    DateTime lastTime = device.histories.first.createdAt;
    Duration difference = DateTime.now().difference(lastTime);
    if (difference.inSeconds <= 30) {
      device.status = "Active";
    }

    return device;
  }
}

class DeviceService {
  final String baseUrl = 'http://192.168.1.6:3000/device';

  Future<Device> getDeviceById(String deviceName) async {
    final response =
        await http.post(Uri.parse(baseUrl), body: {"name": deviceName});
    if (response.statusCode == 201) {
      final res = Device.jsonToDevice(json.decode(response.body));
      return res;
    } else {
      throw Exception('Failed to add device');
    }
  }

  Future<Device> updateDeviceById(String deviceId, double x, double y) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$deviceId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "history": {"x": x, "y": y}
      }),
    );
    if (response.statusCode == 200) {
      final res = Device.jsonToDevice(json.decode(response.body));
      return res;
    } else {
      throw Exception('Failed to update device');
    }
  }

  Future<Device> fetchDeviceById(String deviceId) async {
    final response = await http.get(Uri.parse('$baseUrl/$deviceId'));
    if (response.statusCode == 200) {
      final res = Device.jsonToDevice(json.decode(response.body));
      print(res.id);
      return res;
    } else {
      throw Exception('Failed to load device');
    }
  }

  Future<List<Device>> fetchAllDevices() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> devicesJson = json.decode(response.body);
      return devicesJson.map((json) => Device.jsonToDevice(json)).toList();
    } else {
      throw Exception('Failed to load devices');
    }
  }
}
