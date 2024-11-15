import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PositionScatterChart extends StatelessWidget {
  final Map<String, Point> points;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  const PositionScatterChart({
    super.key,
    required this.points,
    this.minX = -10,
    this.maxX = 10,
    this.minY = -10,
    this.maxY = 10,
  });

  @override
  Widget build(BuildContext context) {
  return SizedBox(
      width: 300,
      height: 300,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: points.values.map((point) =>
            ScatterSpot(
              point.x,
              point.y,
              color: point.color,
              radius: 8,
            ),
          ).toList(),
          titlesData: const FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 30,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          gridData: const FlGridData(show: true),
          scatterTouchData: ScatterTouchData(
            enabled: true,
            touchTooltipData: ScatterTouchTooltipData(
              tooltipBgColor: Colors.black,
              getTooltipItems: (ScatterSpot spot) {
                // Find the point corresponding to this spot
                final point = points.values.firstWhere(
                  (p) => p.x == spot.x && p.y == spot.y,
                  orElse: () => Point(id: '', x: spot.x, y: spot.y),
                );
                return ScatterTooltipItem(
                  'ID: ${point.id}\n(${spot.x.toStringAsFixed(1)}, ${spot.y.toStringAsFixed(1)})',
                  textStyle: const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
        ),
      ),
    );
  }
}

class Point {
  final String id;
  final double x;
  final double y;
  final Color color;

  Point({
    required this.id,
    required this.x,
    required this.y,
    this.color = Colors.red,
  });

  Point copyWithNewPosition(double newX, double newY) {
    return Point(
      id: id,
      x: newX,
      y: newY,
      color: color,
    );
  }
}
