import 'package:flutter/material.dart';
import 'package:uwb_app/network/mqtt.dart';
import 'package:uwb_app/views/scatter_chart.dart';

class ViewMap extends StatefulWidget {
  final String? id;
  const ViewMap({super.key, this.id});

  @override
  State<ViewMap> createState() => _ViewMap();
}

class _ViewMap extends State<ViewMap> {
  final Map<String, Point> points = {};
  void updatePointPosition(String id, double newX, double newY) {
    if (points.containsKey(id)) {
      setState(() {
        points[id] = points[id]!.copyWithNewPosition(newX, newY);
      });
    }
  }

  // Add a new point
  void addPoint(String id, double x, double y, {Color? color}) {
    setState(() {
      points[id] = Point(
        id: id,
        x: x,
        y: y,
        color: color ?? Colors.red,
      );
    });
  }

  void removePoint(String id) {
    setState(() {
      points.remove(id);
    });
  }

  void onDetectionUpdate(String id, double x, double y) {
    setState(() {
      if (points.containsKey(id)) {
        points[id] = points[id]!.copyWithNewPosition(x, y);
      } else {
        points[id] = Point(
          id: id,
          x: x,
          y: y,
          color: Colors.primaries[points.length % Colors.primaries.length],
        );
      }
    });
  }

  void parseMessage(Map<String, String> message) {
    final String extractString = message.values.first;
    final regex = RegExp(
        r'Name: (\w+); Coordinate X: ([\d.]+) Y: ([\d.]+); Time: ([\d:]+)');
    final match = regex.firstMatch(extractString);
    if (match != null) {
      final String name = match.group(1)!;
      final x = double.parse(match.group(2)!);
      final y = double.parse(match.group(3)!);
      final time = match.group(4);
      addPoint(name, x, y);
    }
  }

  @override
  void initState() {
    super.initState();
    final MqttService mqttService = MqttService();
    mqttService.connect().then((_) {
      mqttService.listenFromFeeds();
      mqttService.messageStream.listen(parseMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PositionScatterChart(points: points);
  }
}
