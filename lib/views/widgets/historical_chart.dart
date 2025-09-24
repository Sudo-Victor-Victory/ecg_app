import 'package:ecg_app/data/classes/constants.dart';
import 'package:ecg_app/views/pages/ecg_chart.dart';
import 'package:ecg_app/views/widgets/animated_card.dart';
import 'package:ecg_app/views/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Utilizes SF chart to display chart data retrieved from Supabase
class HistoricalChart extends StatefulWidget {
  final List<Map<String, dynamic>> ecgRows;
  final DateTime startTime;
  final bool isChartingBPM;
  final String durationString;

  const HistoricalChart({
    super.key,
    required this.ecgRows,
    required this.startTime,
    required this.isChartingBPM,
    required this.durationString,
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
  bool isProgrammaticSelection = false;
  double yAxisBound = 0;

  // Time between samples from ESP32
  static const double sampleSpacing = KEcgConstants.sampleSpacingMs;

  @override
  void initState() {
    super.initState();
    chartData = widget.isChartingBPM ? _buildBpmPoints() : _buildEcgPoints();

    axisVisibleMin = chartData.first.ecgTime;
    axisVisibleMax = axisVisibleMin + 10000; // 10 sec window
    yAxisBound = widget.isChartingBPM ? 150 : 4096; // fixed max for simplicity

    selectionBehavior = SelectionBehavior(enable: true);
  }

  List<EcgDataPoint> _buildEcgPoints() {
    final dataPoints = <EcgDataPoint>[];
    final startMs = widget.startTime.millisecondsSinceEpoch.toDouble();
    for (var row in widget.ecgRows) {
      final timestampMs =
          (row[KECGDataColumns.timestamp] as int).toDouble() + startMs;
      final samples = List<int>.from(row[KTables.ecgData]);
      for (int i = 0; i < samples.length; i++) {
        dataPoints.add(
          EcgDataPoint(timestampMs + i * sampleSpacing, samples[i].toDouble()),
        );
      }
    }
    return dataPoints;
  }

  List<EcgDataPoint> _buildBpmPoints() {
    final startMs = widget.startTime.millisecondsSinceEpoch.toDouble();
    return widget.ecgRows.map((row) {
      final timestampMs =
          (row[KECGDataColumns.timestamp] as int).toDouble() + startMs;
      return EcgDataPoint(timestampMs, (row[KECGDataColumns.bpm]).toDouble());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Info container above the chart
          Container(
            width: double.infinity,
            color: KColors.eerieBlack,

            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    AnimatedCard(
                      delay: 100,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: ScaledText(
                                  'Start: ${DateTime.fromMillisecondsSinceEpoch(chartData.first.ecgTime.toInt())}',
                                  baseSize: KTextSize.lg,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Center(
                                child: ScaledText(
                                  widget.durationString,
                                  baseSize: KTextSize.lg,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: SfCartesianChart(
              backgroundColor: KColors.eerieBlack,
              plotAreaBorderWidth: 0,
              margin: const EdgeInsets.only(bottom: 40),
              primaryXAxis: NumericAxis(
                labelFormat: '{value}',
                title: const AxisTitle(text: "Time"),
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
                title: AxisTitle(
                  text: widget.isChartingBPM ? "BPM" : "ECG Data",
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              zoomPanBehavior: ZoomPanBehavior(
                enablePinching: true,
                zoomMode: ZoomMode.x,
                enablePanning: true,
                enableDoubleTapZooming: true,
                enableSelectionZooming: false,
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
              onSelectionChanged: (SelectionArgs args) =>
                  updateSelectedPoint(args),
              // Important. After the initial swiping motion begins and we act on it.
              // Thus using the updated axisVisibleMin/Max and direction we  swipe.
              onPlotAreaSwipe: (ChartSwipeDirection direction) =>
                  performSwipe(direction),
            ),
          ),
        ],
      ),
    );
  }

  /// When the user taps or swipes they select a point internally.
  /// Updates axisVisibleMin + Max to adjust bounds of x-axis viewport.
  void updateSelectedPoint(SelectionArgs args) {
    selectedPointIndex = isProgrammaticSelection
        ? args.pointIndex
        : args.viewportPointIndex;

    if (selectedPointIndex != null) {
      final time = chartData[selectedPointIndex!].ecgTime;
      // Sets visible minimum and visible maximum to maintain
      // the selected point in the center of viewport
      axisVisibleMin = time - 2;
      axisVisibleMax = time + 2;
    }
  }

  /// Updates the axisController based on the axisVisibleMin / Max
  /// Which were just updated in updateSelectedPoints
  void performSwipe(ChartSwipeDirection direction) {
    // Executes when swiping the chart from right to left
    if (direction == ChartSwipeDirection.end &&
        (axisVisibleMax + 20.toDouble()) < chartData.length) {
      isProgrammaticSelection = true;
      // Set the visible minimum and visible maximum to maintain
      // The selected point in the center of the viewport.
      axisVisibleMin += 20;
      axisVisibleMax += 20;
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
        (axisVisibleMin - 20) >= 0) {
      setState(() {
        axisVisibleMin -= 20;
        axisVisibleMax -= 20;
        axisController!.visibleMinimum = axisVisibleMin;
        axisController!.visibleMaximum = axisVisibleMax;
        Future.delayed(const Duration(milliseconds: 20), () {
          selectionBehavior.selectDataPoints((axisVisibleMin.toInt()) + 2);
        });
      });
    }
  }
}
