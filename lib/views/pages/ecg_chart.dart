import 'dart:async';
import 'package:ecg_app/data/classes/ecg_packet.dart';
import 'package:ecg_app/views/widgets/ble_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EcgChart extends StatefulWidget {
  const EcgChart({super.key});

  @override
  State<EcgChart> createState() => _EcgChartState();
}

class _EcgChartState extends State<EcgChart> {
  // BLE manager instance: manages connection & provides stream of ECG packets
  final BleEcgManager _bleManager = BleEcgManager();

  // Listener for EcgPackets
  late StreamSubscription<EcgPacket> _ecgSub;

  // Buffer for data when chart controller is not initialized.
  final List<EcgPacket> _packetBuffer = [];

  // Source of truth for our chart
  List<EcgDataPoint> ecgDataPoints = [];

  // Interacts with Syncfusion chart to update chart in real time
  ChartSeriesController? _chartSeriesController;

  static const double fixedWindowSize = 2000.0;
  double latestEcgTime = 0;
  int globalEcgMax = 4096;

  @override
  void initState() {
    super.initState();

    _ecgSub = _bleManager.ecgStream.listen((sample) {
      _addPacket(sample);
    });
  }

  @override
  void dispose() {
    _ecgSub.cancel();
    super.dispose();
  }

  // Verifies controller iss initialized.
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
        final time = packet.timestamp + i * 4;
        final value = globalEcgMax - packet.samples[i].toDouble();

        ecgDataPoints.add(EcgDataPoint(time.toDouble(), value));
        // Update `latestEcgTime` to reflect most recent ecgTime value
        latestEcgTime = time.toDouble();
      }

      // Adds current ECG packet to the chart
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: List.generate(
          packet.samples.length,
          (i) => ecgDataPoints.length - packet.samples.length + i,
        ),
      );

      // Defines the left-most data to be removed from the chart
      double cutoff = ecgDataPoints.last.ecgTime - fixedWindowSize;
      // Removes (removedCount) number of elements from the left.
      int removedCount = ecgDataPoints.indexWhere((dp) => dp.ecgTime >= cutoff);
      removedCount = removedCount == -1 ? 0 : removedCount;

      if (removedCount > 0) {
        ecgDataPoints.removeRange(0, removedCount);
        _chartSeriesController?.updateDataSource(
          removedDataIndexes: List.generate(removedCount, (i) => i),
        );
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
            // Flush buffered packets
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
