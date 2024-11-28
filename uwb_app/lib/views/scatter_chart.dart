import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

enum PainterType {
  circle,
  square,
  cross,
}

class Point {
  String id;
  String name;
  double x;
  double y;
  Color color;

  Point({
    this.id = "",
    this.name = "",
    this.x = 0,
    this.y = 0,
    this.color = Colors.grey,
  });

  Point copyWithNewPosition(String name, double newX, double newY,
      {Color? newColor}) {
    return Point(
      id: id,
      name: name,
      x: newX,
      y: newY,
      color: newColor ?? color,
    );
  }
}

class PositionScatterChart extends StatefulWidget {
  final Map<String, Point> points;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  PositionScatterChart({
    super.key,
    required this.points,
    this.minX = 0,
    this.maxX = 10,
    this.minY = 0,
    this.maxY = 10,
  });

  @override
  _PositionScatterChartState createState() => _PositionScatterChartState();
}

class _PositionScatterChartState extends State<PositionScatterChart> {
  late double minX;
  late double maxX;
  late double minY;
  late double maxY;

  @override
  void initState() {
    super.initState();
    minX = widget.minX;
    maxX = widget.maxX;
    minY = widget.minY;
    maxY = widget.maxY;
  }

  static FlDotPainter _getPaint(PainterType type, double size, Color color) {
    switch (type) {
      case PainterType.circle:
        return FlDotCirclePainter(
          color: color,
          radius: size,
        );
      case PainterType.square:
        return FlDotSquarePainter(
          color: color,
          size: size * 2,
          strokeWidth: 0,
        );
      case PainterType.cross:
        return FlDotCrossPainter(
          color: color,
          size: size * 2,
          width: max(size / 5, 2),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
            setState(() {
              var scale = scaleDetails.scale;
              if (scale > 1) {
                minX += maxX * 0.01;
                maxX -= maxX * 0.01;
                minY += maxY * 0.01;
                maxY -= maxY * 0.01;
              } else {
                minX -= maxX * 0.01;
                maxX += maxX * 0.01;
                minY -= maxY * 0.01;
                maxY += maxY * 0.01;
              }
            });
          },
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: ScatterChart(ScatterChartData(
              scatterSpots: widget.points.values
                  .map((point) => ScatterSpot(
                        point.x,
                        point.y,
                        dotPainter: _getPaint(
                          PainterType.circle,
                          5,
                          point.color,
                        ),
                      ))
                  .toList(),
              minX: 0,
              maxX: maxX,
              minY: 0,
              maxY: maxY,
              borderData: FlBorderData(
                show: false,
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                checkToShowHorizontalLine: (value) => true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                ),
                drawVerticalLine: true,
                checkToShowVerticalLine: (value) => true,
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              titlesData: const FlTitlesData(
                show: false,
              ),
              scatterTouchData: ScatterTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                touchTooltipData: ScatterTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipColor: (ScatterSpot touchedBarSpot) {
                    return touchedBarSpot.dotPainter.mainColor.withOpacity(0.5);
                  },
                  getTooltipItems: (ScatterSpot touchedSpot) {
                    final point = widget.points.values.firstWhere(
                      (p) => p.x == touchedSpot.x && p.y == touchedSpot.y,
                      orElse: () =>
                          Point(id: '', x: touchedSpot.x, y: touchedSpot.y),
                    );
                    return ScatterTooltipItem(
                      '(${point.name} ${touchedSpot.x}, ${touchedSpot.y})',
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  },
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                ),
              ),
              showingTooltipIndicators: List.generate(
                widget.points.length,
                (index) => index,
              ),
            )),
          ),
        ),
      ),
    );
  }
}
