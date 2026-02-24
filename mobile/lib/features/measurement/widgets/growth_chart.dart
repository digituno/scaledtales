import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/measurement_model.dart';

class GrowthChart extends StatelessWidget {
  final List<MeasurementLog> measurements;
  final String title;
  final String unit;
  final double? Function(MeasurementLog) getValue;
  final Color color;

  const GrowthChart({
    super.key,
    required this.measurements,
    required this.title,
    required this.unit,
    required this.getValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Filter measurements that have valid values, sorted by date ascending
    final data = measurements
        .where((m) => getValue(m) != null)
        .toList()
      ..sort((a, b) => a.measuredDate.compareTo(b.measuredDate));

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[];
    final dateLabels = <int, String>{};

    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), getValue(data[i])!));
      dateLabels[i] = DateFormat('MM/dd').format(DateTime.parse(data[i].measuredDate));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY) * 0.1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title ($unit)',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calcInterval(minY, maxY),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _calcBottomInterval(data.length),
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (dateLabels.containsKey(idx)) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                dateLabels[idx]!,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: spots.length == 1 ? minY * 0.8 : minY - yPadding,
                  maxY: spots.length == 1 ? maxY * 1.2 : maxY + yPadding,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: color,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: color,
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt();
                          final date = idx < data.length
                              ? DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(data[idx].measuredDate))
                              : '';
                          return LineTooltipItem(
                            '$date\n${spot.y.toStringAsFixed(1)}$unit',
                            const TextStyle(
                                color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calcInterval(double min, double max) {
    final range = max - min;
    if (range <= 0) return 1;
    if (range <= 10) return 2;
    if (range <= 50) return 10;
    if (range <= 200) return 50;
    return 100;
  }

  double _calcBottomInterval(int count) {
    if (count <= 5) return 1;
    if (count <= 10) return 2;
    if (count <= 20) return 4;
    return (count / 5).ceilToDouble();
  }
}
