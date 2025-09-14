import 'dart:ffi';

import 'package:ecg_app/views/pages/ecg_chart.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HistoricalChart extends StatefulWidget {
  final List<Map<String, dynamic>> ecgRows;
  final DateTime startTime;
  final bool isChartingBPM;

  const HistoricalChart({
    super.key,
    required this.ecgRows,
    required this.startTime,
    required this.isChartingBPM,
  });

  @override
  State<HistoricalChart> createState() => _HistoricalChartState();
}

class _HistoricalChartState extends State<HistoricalChart> {
  late List<EcgDataPoint> chartData;
  // Both of these vars act as the left and right bound of the chart.
  late double axisVisibleMin;
  late double axisVisibleMax;
  late SelectionBehavior selectionBehavior;
  // Controller that updates chart viewport when axisVisibleMin/Max change
  NumericAxisController? axisController;
  // Used to determine where the user tapped to begin swiping.
  int? selectedPointIndex;
  // Used to determine if a tap/swap was programmatic or manual.
  // Tap provides pointIndex, swipe provides viewportPointIndex
  bool manualTap = false;
  double yAxisBound = 0;
  @override
  void initState() {
    //Initialize the data source to the chart
    final dataPoints = <EcgDataPoint>[];
    final startMs = widget.startTime.millisecondsSinceEpoch.toDouble();
    print(widget.isChartingBPM);
    final String? table_column;
    if (widget.isChartingBPM == false) {
      table_column = 'ecg_data';
      for (var row in widget.ecgRows) {
        final timestampMs = (row['timestamp_ms'] as int).toDouble() + startMs;
        final samples = List<int>.from(row[table_column]);
        for (int i = 0; i < samples.length; i++) {
          dataPoints.add(
            EcgDataPoint(
              timestampMs + i * 4.0, // 4ms sample spacing. May want to env it.
              samples[i].toDouble(),
            ),
          );
        }
      }
      yAxisBound = 4096;
    } else {
      table_column = 'bpm';
      for (var row in widget.ecgRows) {
        final timestampMs = (row['timestamp_ms'] as int).toDouble() + startMs;
        final sample = (row[table_column]).toDouble();
        dataPoints.add(
          EcgDataPoint(
            timestampMs + 4.0, // 4ms sample spacing. May want to env it.
            sample,
          ),
        );
      }
    }
    yAxisBound =
        dataPoints.map((p) => p.ecgValue).reduce((a, b) => a > b ? a : b) + 2;

    // Decided to assign instead of using late to possibly optimize
    // for querying in chunks.
    chartData = dataPoints;
    // Screen will maintain a 10 second window
    axisVisibleMin = dataPoints.first.ecgTime;
    axisVisibleMax = dataPoints.first.ecgTime + 10000;
    // Enabling selection behavior
    selectionBehavior = SelectionBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: SfCartesianChart(
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
              return ChartAxisLabel(
                label,
                const TextStyle(color: Colors.white),
              );
            },
            onRendererCreated: (NumericAxisController controller) =>
                axisController = controller,

            initialVisibleMinimum: axisVisibleMin,
            initialVisibleMaximum: axisVisibleMax,
          ),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: yAxisBound,
            labelStyle: const TextStyle(color: Colors.white),
            title: AxisTitle(text: widget.isChartingBPM ? "BPM" : "ECG Data"),
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
              dataSource: chartData,
              xValueMapper: (p, _) => p.ecgTime,
              yValueMapper: (p, _) => p.ecgValue,
              color: const Color.fromARGB(255, 228, 10, 10),
              animationDuration: 0,
              name: widget.isChartingBPM ? "BPM Value" : "ECG Value",
            ),
          ],
          // Important. Sliding starts with selecting a point
          // So all logic is dependant on it.
          onSelectionChanged: (SelectionArgs args) => updateSelectedPoint(args),
          // Important. After the initial swiping motion begins and we act on it.
          // Thus using the updated axisVisibleMin/Max and direction we  swipe.
          onPlotAreaSwipe: (ChartSwipeDirection direction) =>
              performSwipe(direction),
        ),
      ),
    );
  }

  /// When the user taps or swipes they select a point internally.
  /// Updates axisVisibleMin + Max to adjust bounds of x-axis viewport.
  void updateSelectedPoint(SelectionArgs args) {
    // While manually selecting the points.
    if (!manualTap) {
      selectedPointIndex = args.viewportPointIndex;
    }
    // While swiping the point gets selected.
    else {
      selectedPointIndex = args.pointIndex;
    }

    // Sets visible minimum and visible maximum to maintain
    // the selected point in the center of viewport
    axisVisibleMin = selectedPointIndex! - 2.toDouble();
    axisVisibleMax = selectedPointIndex! + 2.toDouble();
  }

  /// Updates the axisController based on the axisVisibleMin / Max
  /// Which were just updated in updateSelectedPoints
  void performSwipe(ChartSwipeDirection direction) {
    // Executes when swiping the chart from right to left
    if (direction == ChartSwipeDirection.end &&
        (axisVisibleMax + 20.toDouble()) < chartData.length) {
      manualTap = true;
      // Set the visible minimum and visible maximum to maintain
      // The selected point in the center of the viewport.
      axisVisibleMin = axisVisibleMin + 20.toDouble();
      axisVisibleMax = axisVisibleMax + 20.toDouble();
      // To update the visible maximum and visible minimum dynamically by using axis controller.
      axisController!.visibleMinimum = axisVisibleMin;
      axisController!.visibleMaximum = axisVisibleMax;
      // To execute after chart redrawn with new visible minimum and maximum,
      // We used delay for 1 second to give the chart time to render the changes.
      Future.delayed(const Duration(milliseconds: 1000), () {
        // Public method used to select the data point dynamically
        selectionBehavior.selectDataPoints((axisVisibleMin.toInt()) + 2);
      });
    }
    // Executes when swiping the chart from left to right
    // Same logic as above
    else if (direction == ChartSwipeDirection.start &&
        (axisVisibleMin - 20.toDouble()) >= 0) {
      setState(() {
        axisVisibleMin = axisVisibleMin - 20.toDouble();
        axisVisibleMax = axisVisibleMax - 20.toDouble();
        axisController!.visibleMinimum = axisVisibleMin;
        axisController!.visibleMaximum = axisVisibleMax;
        Future.delayed(const Duration(milliseconds: 20), () {
          selectionBehavior.selectDataPoints((axisVisibleMin.toInt()) + 2);
        });
      });
    }
  }
}
