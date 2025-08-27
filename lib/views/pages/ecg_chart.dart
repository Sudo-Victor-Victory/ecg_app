import 'dart:async';
import 'dart:collection';
import 'package:ecg_app/data/classes/ecg_packet.dart';
import 'package:ecg_app/views/widgets/ble_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EcgChart extends StatefulWidget {
  final void Function(VoidCallback scan)? onDisconnect;
  const EcgChart({super.key, this.onDisconnect});

  @override
  State<EcgChart> createState() => _EcgChartState();
}

class _EcgChartState extends State<EcgChart> {
  // Manages all connection & disconnection logic
  final BleEcgManager _bleManager = BleEcgManager();
  // Stream for receiving BLE data
  StreamSubscription<EcgPacket>? _ecgSub;

  final Queue<EcgDataPoint> _unplottedEcgDataQueue = Queue<EcgDataPoint>();
  // Points currently displayed on the chart
  List<EcgDataPoint> plottedEcgData = [];
  // Necessary to update Syncfusion's charts
  ChartSeriesController? _chartSeriesController;

  // Chart config
  // 2 seconds width of visible chart (in ms)
  static const double chartWindowSizeMs = 2000.0;
  // Time interval between samples (4ms → 250Hz sample rate)
  static const double samplePeriodMs = 4.0;
  // Number of samples to plot per 16ms timer tick (~60 fps screen refresh)
  static const int samplesPerFrame = 4;
  // Number of samples to accumulate before starting charting (~1s buffer)
  static const int initialBufferSamples = 250;

  double latestEcgTime = 0;
  Timer? _chartUpdateTimer;
  // Used to contextualize timestamps and normalize them to 0 for charting.
  double? _firstDeviceTimestamp;

  @override
  void initState() {
    super.initState();

    _ecgSub = _bleManager.ecgStream.listen((packet) {
      _addPacketToQueue(packet);
      _startProcessingByTimer();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDisconnect?.call(() {
        _ecgSub?.cancel();
        _bleManager.disconnect();
      });
    });
  }

  @override
  void dispose() {
    _ecgSub?.cancel();
    _chartUpdateTimer?.cancel();
    _unplottedEcgDataQueue.clear();
    plottedEcgData.clear();
    _chartSeriesController = null;
    super.dispose();
  }

  /// Deconstructs packet into individual samples EcgDataPoint(time & ecg value)
  /// and adds them to _unplottedEcgDataQueue.
  void _addPacketToQueue(EcgPacket packet) {
    final n = packet.samples.length;
    // Timestamp is gathered at packet generation (10 samples) at samplePeriodMs
    // rate. So they are all samplePeriodMs apart.
    final firstTimestamp =
        packet.timestamp.toDouble() - (n - 1) * samplePeriodMs;

    _firstDeviceTimestamp ??= firstTimestamp;

    for (int i = 0; i < n; i++) {
      final timestamp =
          (firstTimestamp + i * samplePeriodMs) - _firstDeviceTimestamp!;
      final ecgValue = packet.samples[i].clamp(0, 4096).toDouble();
      _unplottedEcgDataQueue.add(EcgDataPoint(timestamp, ecgValue));
    }
  }

  /// Removes left-most datapoints from the queue, adds it into the source of truth
  /// and updates the chart with the recently added points
  /// using a 2 second sliding window.
  void _processQueuedPacket() {
    int toAdd = 0;

    while (_unplottedEcgDataQueue.isNotEmpty && toAdd < samplesPerFrame) {
      final dataPoint = _unplottedEcgDataQueue.removeFirst();
      plottedEcgData.add(dataPoint);
      latestEcgTime = dataPoint.ecgTime;
      toAdd++;
    }

    if (toAdd == 0) {
      return;
    }

    // Trim sliding window
    final cutoff = latestEcgTime - chartWindowSizeMs;
    while (plottedEcgData.isNotEmpty && plottedEcgData.first.ecgTime < cutoff) {
      plottedEcgData.removeAt(0);
    }
    // Add the new data points into the chart
    final startIndex = plottedEcgData.length - toAdd;
    _chartSeriesController?.updateDataSource(
      addedDataIndexes: List.generate(toAdd, (i) => startIndex + i),
    );

    // Used to refresh the chart to display changes.
    setState(() {});
  }

  /// Calls _processQueuedPacket() within a 16ms duration for a smooth charting
  /// experience.
  /// tl;dr processes packets via timer to get a smooth chart instead of
  /// whenever the ESP32 sends data over BLE.
  void _startProcessingByTimer() {
    if (_chartUpdateTimer?.isActive == true) {
      return;
    }

    // 16 was chosen to get a 60fps screen refresh
    _chartUpdateTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || _unplottedEcgDataQueue.isEmpty) return;

      // Soft start: wait until buffer has ~1s data
      if (plottedEcgData.isEmpty &&
          _unplottedEcgDataQueue.length < initialBufferSamples) {
        return;
      }

      _processQueuedPacket();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double minX = (latestEcgTime < chartWindowSizeMs)
        ? 0
        : latestEcgTime - chartWindowSizeMs;
    final double maxX = latestEcgTime;

    return SfCartesianChart(
      backgroundColor: Colors.black,
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(minimum: minX, maximum: maxX, interval: 500),
      primaryYAxis: NumericAxis(minimum: 0, maximum: 4096, interval: 512),
      series: [
        LineSeries<EcgDataPoint, double>(
          dataSource: plottedEcgData,
          xValueMapper: (dataPoint, _) => dataPoint.ecgTime,
          yValueMapper: (dataPoint, _) => dataPoint.ecgValue,
          animationDuration: 0,
          onRendererCreated: (controller) {
            _chartSeriesController = controller;
          },
          color: const Color.fromARGB(255, 228, 10, 10),
        ),
      ],
    );
  }
}

// Used to encapsulate important data for charting
class EcgDataPoint {
  final double ecgTime;
  final double ecgValue;
  EcgDataPoint(this.ecgTime, this.ecgValue);
}
