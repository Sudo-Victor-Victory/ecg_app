import 'package:ecg_app/views/pages/ecg_chart.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HistoricalChart extends StatelessWidget {
  final List<Map<String, dynamic>> ecgRows;
  final DateTime startTime;
  const HistoricalChart({
    super.key,
    required this.ecgRows,
    required this.startTime,
  });

  @override
  Widget build(BuildContext context) {
    final dataPoints = <EcgDataPoint>[];
    final startMs = startTime.millisecondsSinceEpoch.toDouble();
    for (var row in ecgRows) {
      final timestampMs = (row['timestamp_ms'] as int).toDouble() + startMs;
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
    return Scaffold(
      appBar: AppBar(title: Text("Your chart")),

      body: SfCartesianChart(
        backgroundColor: Colors.black,
        plotAreaBorderWidth: 0,
        primaryXAxis: NumericAxis(
          labelFormat: '{value}',
          title: AxisTitle(text: "Time"),
          axisLabelFormatter: (AxisLabelRenderDetails details) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              details.value.toInt(),
            );
            final label =
                "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
            return ChartAxisLabel(label, const TextStyle(color: Colors.white));
          },
          //
          initialVisibleMinimum: dataPoints.first.ecgTime,
          initialVisibleMaximum:
              dataPoints.first.ecgTime + 10000, // 10 seconds window
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: 4096,
          labelStyle: const TextStyle(color: Colors.white),
          title: AxisTitle(text: "ECG data"),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          zoomMode: ZoomMode.x,
          enablePanning: true,
          enableDoubleTapZooming: true,
        ),
        series: [
          LineSeries<EcgDataPoint, double>(
            dataSource: dataPoints,
            xValueMapper: (p, _) => p.ecgTime,
            yValueMapper: (p, _) => p.ecgValue,
            color: const Color.fromARGB(255, 228, 10, 10),
            animationDuration: 0,
            name: "Ecg value",
          ),
        ],
      ),
    );
  }
}
