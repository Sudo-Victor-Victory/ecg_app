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
  final BleEcgManager _bleManager = BleEcgManager();
  StreamSubscription<EcgPacket>? _ecgSub;

  // Use a Queue for safer buffered packets
  final Queue<EcgPacket> _packetBuffer = Queue<EcgPacket>();

  List<EcgDataPoint> ecgDataPoints = [];
  ChartSeriesController? _chartSeriesController;

  static const double fixedWindowSize = 2000.0;
  double latestEcgTime = 0;
  int globalEcgMax = 4096;

  @override
  void initState() {
    super.initState();

    // Listen to ECG stream
    _ecgSub = _bleManager.ecgStream.listen((packet) {
      if (!mounted) return;
      _addPacket(packet);
    });

    // Pass stop function to parent safely after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDisconnect?.call(() {
        _ecgSub?.cancel();
        _ecgSub = null;
        _bleManager.disconnect();
      });
    });
  }

  @override
  void dispose() {
    _ecgSub?.cancel();
    _packetBuffer.clear();
    _chartSeriesController = null;
    super.dispose();
  }

  void _addPacket(EcgPacket packet) {
    if (!mounted) {
      return;
    }

    if (_chartSeriesController == null) {
      _packetBuffer.add(packet);
      return;
    }

    _processPacket(packet);
  }

  // Generates timestamps for each sample in a packet and uploads the data to
  // the chart
  void _processPacket(EcgPacket packet) {
    if (!mounted) {
      return;
    }
    setState(() {
      double lastX = ecgDataPoints.isEmpty ? 0 : ecgDataPoints.last.ecgTime;
      for (int i = 0; i < packet.samples.length; i++) {
        // Timestamp in the EcgPacket are sent from the ESP32.
        // They are collected every 4ms, and 10 are batched together.
        // We collect the timestamp at the end. So every sample is 4ms off from
        // the right.
        // Lastly, BLE isn't 100% precise so data can arrive out of order,
        // or delayed. We use latestEcgTime to attach a graphable timestamp.
        double time = packet.timestamp - (packet.samples.length - 1 - i) * 4;

        // Ensure chart X increases smoothly
        if (time <= lastX) {
          time = lastX + 2; // or small increment
        }

        lastX = time;
        latestEcgTime = time;
        ecgDataPoints.add(EcgDataPoint(time, packet.samples[i].toDouble()));
      }

      // Update chart with new points
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: List.generate(
          packet.samples.length,
          (i) => ecgDataPoints.length - packet.samples.length + i,
        ),
      );

      // Remove old points beyond window
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
          xValueMapper: (dp, _) => dp.ecgTime,
          yValueMapper: (dp, _) => dp.ecgValue,
          animationDuration: 0,
          onRendererCreated: (controller) {
            if (!mounted) return;
            _chartSeriesController = controller;

            // Flush buffered packets safely
            while (_packetBuffer.isNotEmpty) {
              _processPacket(_packetBuffer.removeFirst());
            }
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
