import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

String baseUrl = 'http://172.16.1.89:3000/device';

class History {
  String id;
  final double x;
  final double y;
  final DateTime createdAt;

  History({
    this.id = "",
    required this.x,
    required this.y,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

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
  String id;
  String name;
  List<dynamic> histories;
  DateTime createdAt;
  int deviceType;
  DateTime updatedAt;
  String status;
  String location;
  String img;
  Timer? statusTimer;

  Device({
    required this.id,
    required this.name,
    required this.histories,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceType,
    this.status = "Not Active",
    this.location = "#NA",
    this.img = "uwb.png",
  });

  factory Device.jsonToDevice(Map<String, dynamic> json) {
    try {
      var historiesFromJson = json['histories'] as List;

      List<History> historyList =
          historiesFromJson.map((i) => History.fromJson(i)).toList();

      Device device = Device(
        id: json['_id'],
        name: json['name'],
        histories: historyList,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        deviceType: json['device_type'],
      );

      if (device.histories.isNotEmpty) {
        DateTime lastTime = device.histories.first.createdAt;
        Duration difference = DateTime.now().difference(lastTime);
        if (difference.inSeconds <= 30) {
          device.status = "Active";
        }
      }

      return device;
    } catch (e) {
      print('Error parsing device JSON: $e');
      rethrow;
    }
  }

  void resetStatus() {
    status = "Not Active";
    location = "#NA";
    print('Device status reset to Not Active');
  }

  void updateDeviceStatus(dynamic data) {
    print('Updating device status with data: $data');

    if (data == null ||
        !data.containsKey('name') ||
        !data.containsKey('deviceType') ||
        !data.containsKey('location')) {
      print('Invalid data: $data');
      return;
    }

    double x = data['x'];
    double y = data['y'];

    History history = History(x: x, y: y);
    histories.insert(0, history);

    name = data['name'];
    deviceType = data['deviceType'];
    status = "Active";
    location = data['location'];

    statusTimer?.cancel();
    statusTimer = Timer(const Duration(seconds: 15), () {
      resetStatus();
    });
  }

  void dispose() {
    statusTimer?.cancel();
  }
}

class DeviceService {
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
