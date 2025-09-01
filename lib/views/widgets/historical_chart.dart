import 'package:ecg_app/views/pages/ecg_chart.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HistoricalChart extends StatelessWidget {
  final List<Map<String, dynamic>> ecgRows;
  const HistoricalChart({super.key, required this.ecgRows});

  @override
  Widget build(BuildContext context) {
    final dataPoints = <EcgDataPoint>[];

    for (var row in ecgRows) {
      final timestampMs = (row['timestamp_ms'] as int).toDouble();
      final samples = List<int>.from(row['ecg_data']);
      for (int i = 0; i < samples.length; i++) {
        dataPoints.add(
          EcgDataPoint(
            timestampMs + i * 4.0, // 4ms sample spacing. May want to env it.
            samples[i].toDouble(),
          ),
        );
      }
    }

    return SfCartesianChart(
      backgroundColor: Colors.black,
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(),
      primaryYAxis: NumericAxis(minimum: 0, maximum: 4096),
      series: [
        LineSeries<EcgDataPoint, double>(
          dataSource: dataPoints,
          xValueMapper: (p, _) => p.ecgTime,
          yValueMapper: (p, _) => p.ecgValue,
          color: const Color.fromARGB(255, 228, 10, 10),
          animationDuration: 0,
        ),
      ],
    );
  }
}
