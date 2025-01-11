import 'dart:convert';
import 'package:http/http.dart' as http;

String baseUrl = 'http://172.21.64.1:3000/device';

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

class BaseStation {
  String id;
  String name;
  double x;
  double y;
  BaseStation({
    this.id = "",
    this.name = "",
    this.x = 0,
    this.y = 0,
  });

  factory BaseStation.jsonToBase(Map<String, dynamic> json) {
    var historiesFromJson = json['histories'] as List;

    dynamic recentHistory;
    if (historiesFromJson.isNotEmpty) {
      recentHistory = History.fromJson(historiesFromJson.first);
    }
    return BaseStation(
      id: json['_id'],
      name: json['name'],
      x: recentHistory != null ? recentHistory.x : 0,
      y: recentHistory != null ? recentHistory.y : 0,
    );
  }
}

class BaseStationService {
  Future<BaseStation> addBaseByName(String baseName) async {
    final response =
        await http.post(Uri.parse(baseUrl), body: {"name": baseName});
    if (response.statusCode == 201) {
      return BaseStation.jsonToBase(json.decode(response.body));
    } else {
      throw Exception('Failed to add device');
    }
  }

  Future<BaseStation> updateBaseById(String baseId, double x, double y) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$baseId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "history": {"x": x, "y": y},
      }),
    );
    if (response.statusCode == 200) {
      return BaseStation.jsonToBase(json.decode(response.body));
    } else {
      throw Exception('Failed to update device');
    }
  }

  Future<List<BaseStation>> fetchAllBaseStations() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> devicesJson = json.decode(response.body);
      return devicesJson
          .where((json) =>
              json['name'] == 'B1' ||
              json['name'] == 'B2' ||
              json['name'] == 'B3')
          .map((json) => BaseStation.jsonToBase(json))
          .toList();
    } else {
      throw Exception('Failed to load devices');
    }
  }
}

class Device {
  String id;
  String name;
  List<dynamic> histories;
  DateTime createdAt;
  DateTime updatedAt;
  String status;
  String location;
  String img;

  Device({
    required this.id,
    required this.name,
    required this.histories,
    required this.createdAt,
    required this.updatedAt,
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

  void defineLocation(List<BaseStation> baseStations) {
    if (baseStations.isEmpty || histories.isEmpty) {
      location = "No Base setted up";
      return;
    }

    double x = histories.first.x;
    double y = histories.first.y;
    BaseStation b2 = baseStations.firstWhere((element) => element.name == 'B2');
    BaseStation b3 = baseStations.firstWhere((element) => element.name == 'B3');
    if (x > 0 && x < b3.x && y > 0 && y < b2.y) {
      location = "In room";
      return;
    }
    location = "Out of room";
  }
}

class DeviceService {
  Future<Device> addDeviceByName(String deviceName) async {
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
      return devicesJson
          .where((json) =>
              json['name'] != 'B1' &&
              json['name'] != 'B2' &&
              json['name'] != 'B3')
          .map((json) => Device.jsonToDevice(json))
          .toList();
    } else {
      throw Exception('Failed to load devices');
    }
  }
}
