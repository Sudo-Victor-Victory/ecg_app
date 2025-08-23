import 'dart:async';
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
  // Manages connection & exposes ECG data stream
  final BleEcgManager _bleManager = BleEcgManager();

  StreamSubscription<EcgPacket>? _ecgSub;

  // Buffer for data when chart controller is not initialized.
  final List<EcgPacket> _packetBuffer = [];

  // Source of truth for our chart - is our current data within the chart.
  List<EcgDataPoint> ecgDataPoints = [];

  // Interacts with Syncfusion chart to update chart in real time
  ChartSeriesController? _chartSeriesController;

  static const double fixedWindowSize = 2000.0;
  double latestEcgTime = 0;

  // Max value from ECG
  int globalEcgMax = 4096;

  @override
  void initState() {
    super.initState();

    _ecgSub = _bleManager.ecgStream.listen((sample) {
      _addPacket(sample);
    });

    // Pass back the stop function to the parent
    widget.onDisconnect?.call(() {
      _ecgSub?.cancel();
      _ecgSub = null;
      _bleManager.disconnect();
    });
  }

  @override
  void dispose() {
    // Cancels stream to avoid memory leaks.
    _ecgSub?.cancel();
    super.dispose();
  }

  // If the chart isn't ready yet, buffer packets for later processing
  void _addPacket(EcgPacket packet) {
    if (_chartSeriesController == null) {
      _packetBuffer.add(packet);
      return;
    }
    _processPacket(packet);
  }

  // Generates timestamps for each sample in a packet and uploads the data to
  // the chart
  void _processPacket(EcgPacket packet) {
    setState(() {
      for (int i = 0; i < packet.samples.length; i++) {
        // Timestamp in the EcgPacket are sent from the ESP32.
        // They are collected every 4ms, and 10 are batched together.
        // We collect the timestamp at the end. So every sample is 4ms off from
        // the right.
        // Lastly, BLE isn't 100% precise so data can arrive out of order,
        // or delayed. We use latestEcgTime to attach a graphable timestamp.
        double time = packet.timestamp - (packet.samples.length - 1 - i) * 4;

        // Enforce monotonic increasing timestamp (1 ms minimum increment)
        if (time <= latestEcgTime) {
          time = latestEcgTime + 1;
        }
        latestEcgTime = time;

        final value = packet.samples[i].toDouble();
        ecgDataPoints.add(EcgDataPoint(time, value));
      }

      // Add packet's time and ecg value to the chart
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: List.generate(
          packet.samples.length,
          (i) => ecgDataPoints.length - packet.samples.length + i,
        ),
      );

      // Remove old points from ecgDataPoints
      double cutoff = latestEcgTime - fixedWindowSize;
      int removedCount = ecgDataPoints.indexWhere((dp) => dp.ecgTime >= cutoff);
      removedCount = removedCount == -1 ? 0 : removedCount;

      if (removedCount > 0) {
        _chartSeriesController?.updateDataSource(
          removedDataIndexes: List.generate(removedCount, (i) => i),
        );
        ecgDataPoints.removeRange(0, removedCount);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxX = latestEcgTime;
    double minX = (maxX - fixedWindowSize).clamp(0, double.infinity);

    return SfCartesianChart(
      backgroundColor: Colors.black,
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(minimum: minX, maximum: maxX, interval: 500),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: globalEcgMax.toDouble(),
        interval: 512,
      ),
      series: [
        LineSeries<EcgDataPoint, double>(
          dataSource: ecgDataPoints,
          xValueMapper: (EcgDataPoint dp, _) => dp.ecgTime,
          yValueMapper: (EcgDataPoint dp, _) => dp.ecgValue,
          animationDuration: 0,
          // Absolutely necessary for real-time charting
          onRendererCreated: (controller) {
            _chartSeriesController = controller;
            // Flush buffered packets and add them into the chart
            for (final packet in _packetBuffer) {
              _processPacket(packet);
            }
            _packetBuffer.clear();
          },
          color: const Color.fromARGB(255, 228, 10, 10),
        ),
      ],
    );
  }
}

class EcgDataPoint {
  final double ecgTime;
  final double ecgValue;
  EcgDataPoint(this.ecgTime, this.ecgValue);
}
