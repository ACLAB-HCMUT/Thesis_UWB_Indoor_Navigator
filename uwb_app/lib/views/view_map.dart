import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uwb_app/views/scatter_chart.dart';
import 'package:uwb_app/network/mqtt.dart';
import 'package:uwb_app/network/device.dart';

class ViewMap extends StatefulWidget {
  final String? id;
  const ViewMap({super.key, this.id});

  @override
  State<ViewMap> createState() => _ViewMap();
}

class _ViewMap extends State<ViewMap> {
  List<Device> devices = [];
  final DeviceService deviceService = DeviceService();
  final MqttService mqttService = MqttService();
  final Map<String, Point> points = {};

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
  }

  void startPeriodFetch() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      refreshPage();
    });
  }

  Future<void> refreshPage() async {
    //   baseStations = await baseStationService.fetchAllBaseStations();
    //   if (widget.id != null) {
    //     devices.clear();
    //     Device newDevice = await deviceService.fetchDeviceById(widget.id!);
    //     devices.add(newDevice);
    //   } else {
    //     devices = await deviceService.fetchAllDevices();
    //   }

    //   for (var base in baseStations) {
    //     if (points.containsKey(base.id)) {
    //       updatePointPosition(base.id, base.name, base.x, base.y,
    //           color: Colors.blue);
    //     } else {
    //       addPoint(base.id, base.name, base.x, base.y, color: Colors.blue);
    //     }
    //   }
    //   for (var device in devices) {
    //     if (points.containsKey(device.id)) {
    //       if (device.status == "Active") {
    //         updatePointPosition(device.id, device.name, device.histories.first.x,
    //             device.histories.first.y,
    //             color: Colors.green);
    //       } else {
    //         updatePointPosition(device.id, device.name, device.histories.first.x,
    //             device.histories.first.y,
    //             color: Colors.grey);
    //       }
    //     } else {
    //       addPoint(device.id, device.name, device.histories.first.x,
    //           device.histories.first.y);
    //     }
    //   }
  }

  Future<void> initialize() async {
    devices = [];
    points.clear();
    refreshPage();
    mqttService.messageStream.listen((message) {
      refreshPage();
    });
  }

  // Add a new point
  void addPoint(String id, String name, double x, double y, {Color? color}) {
    setState(() {
      points[id] = Point(
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
    if (points.containsKey(id)) {
      setState(() {
        if (color != null) {
          points[id] = points[id]!
              .copyWithNewPosition(name, newX, newY, newColor: color);
        } else {
          points[id] = points[id]!.copyWithNewPosition(name, newX, newY);
        }
      });
    }
  }

  void removePoint(String id) {
    setState(() {
      points.remove(id);
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
          // print('Refreshing');
          initialize();
        },
        child: Scaffold(
          body: PositionScatterChart(
            points: points,
            // maxX: (baseStations.isEmpty) ? 10 : baseStations[2].x,
            // maxY: (baseStations.isEmpty) ? 10 : baseStations[1].y,
          ),
        ),
      ),
    );
  }
}
