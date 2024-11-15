import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    // Initialize with some points
    points['A'] = Point(id: 'A', x: 1, y: 1, color: Colors.red);
    points['B'] = Point(id: 'B', x: -2, y: 3, color: Colors.blue);
  }

  @override
  Widget build(BuildContext context) {
    return PositionScatterChart(points: points);
  }
}
