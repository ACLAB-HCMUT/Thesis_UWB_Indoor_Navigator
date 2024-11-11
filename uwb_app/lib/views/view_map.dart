import 'dart:async';

import 'package:flutter/material.dart';


class ViewMap extends StatefulWidget {
  final String? deviceId;
  const ViewMap({super.key, this.deviceId});

  @override
  State<ViewMap> createState() => _ViewMap();
}
class MovingPointsWidget extends StatefulWidget {
  @override
  _MovingPointsWidgetState createState() => _MovingPointsWidgetState();
}

class _MovingPointsWidgetState extends State<MovingPointsWidget> {
  List<Offset> points = [];

  @override
  void initState() {
    super.initState();

    points = [
      Offset(100, 100),
      Offset(150, 150),
      Offset(200, 200),
    ];

    // Sử dụng Timer để cập nhật tọa độ điểm trong danh sách
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        points = points.map((point) {
          double newX = point.dx + 2;
          double newY = point.dy + 1;

          if (newX > 300) newX = 100;
          if (newY > 300) newY = 100;

          return Offset(newX, newY);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, double.infinity),
      painter: IndoorMapPainter(points),
    );
  }
}

class IndoorMapPainter extends CustomPainter {
  final List<Offset> points;

  IndoorMapPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    double gridSpacing = 20.0;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 0.5;

    // Vẽ lưới
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final pointPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;

    // Vẽ từng điểm trong danh sách
    for (var point in points) {
      canvas.drawCircle(point, 5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(100, 100)
      ..lineTo(200, 0)
      ..lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _ViewMap extends State<ViewMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MovingPointsWidget(),
      ),
    );
  }
}