import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uwb_app/views/scatter_chart.dart';
import 'package:uwb_app/network/mqtt.dart';
import 'package:uwb_app/network/device.dart';
import 'package:provider/provider.dart';

class ViewMap extends StatefulWidget {
  final String? id;
  const ViewMap({super.key, this.id});

  @override
  State<ViewMap> createState() => _ViewMap();
}

class _ViewMap extends State<ViewMap> {
  final DeviceService deviceService = DeviceService();
  late ValueNotifier<List<Device>> deviceList;
  late MqttService mqttService = MqttService();
  late ValueNotifier<Map<String, Point>> points =
      ValueNotifier<Map<String, Point>>({});

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initialize();
    startPeriodFetch();
  }

  @override
  void didUpdateWidget(covariant ViewMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      initialize();
      startPeriodFetch();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void startPeriodFetch() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {});
  }

  Future<void> loadData() async {
    //clear all points
    points.value.clear();

    // Fetch data from the database
    deviceList.value = await deviceService.fetchAllDevices();
  }

  Future<void> initialize() async {
    // Assign the provider to the variable
    mqttService = Provider.of<MqttService>(context, listen: false);
    deviceList =
        Provider.of<ValueNotifier<List<Device>>>(context, listen: false);
    loadData();
  }

  // Add a new point
  void addPoint(String id, String name, double x, double y, {Color? color}) {
    setState(() {
      points.value[id] = Point(
        id: id,
        name: name,
        x: x,
        y: y,
        color: color ?? Colors.grey,
      );
    });
  }

  void updatePointPosition(String id, String name, double newX, double newY,
      {Color? color}) {
    if (points.value.containsKey(id)) {
      setState(() {
        if (color != null) {
          points.value[id] = points.value[id]!
              .copyWithNewPosition(name, newX, newY, newColor: color);
        } else {
          points.value[id] =
              points.value[id]!.copyWithNewPosition(name, newX, newY);
        }
      });
    }
  }

  void updatePointsPosition (List<Device> deviceList) {
        // Init
    List<Device> tagDevices = [];
    List<Device> baseDevices = [];

    // Add points to the map
    for (var base in baseDevices) {
      if (points.value.containsKey(base.id)) {
        updatePointPosition(
            base.id, base.name, base.histories[0].x, base.histories[0].y,
            color: Colors.blue);
      } else {
        addPoint(base.id, base.name, base.histories[0].x, base.histories[0].y,
            color: Colors.blue);
      }
    }

    for (var device in tagDevices) {
      if (points.value.containsKey(device.id)) {
        if (device.status == "Active") {
          updatePointPosition(device.id, device.name, device.histories.first.x,
              device.histories.first.y,
              color: Colors.green);
        } else {
          updatePointPosition(device.id, device.name, device.histories.first.x,
              device.histories.first.y,
              color: Colors.grey);
        }
      } else {
        addPoint(device.id, device.name, device.histories.first.x,
            device.histories.first.y);
      }
    }
  }

  void removePoint(String id) {
    setState(() {
      points.value.remove(id);
    });
  }

  // void onDetectionUpdate(String id, double x, double y) {
  //   setState(() {
  //     if (points.containsKey(id)) {
  //       points[id] = points[id]!.copyWithNewPosition(x, y);
  //     } else {
  //       points[id] = Point(
  //         id: id,
  //         x: x,
  //         y: y,
  //         color: Colors.primaries[points.length % Colors.primaries.length],
  //       );
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map',
      home: RefreshIndicator(
        onRefresh: () async {
          initialize();
        },
        child: Scaffold(
          body: ValueListenableBuilder<Map<String, Point>>(
            valueListenable: points, // Listen to changes in points
            builder: (context, pointsValue, _) {
              return PositionScatterChart(
                points: pointsValue, // Pass the updated points to the chart
              );
            },
          ),
        ),
      ),
    );
  }
}
