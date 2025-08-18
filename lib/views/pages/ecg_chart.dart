import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EcgChart extends StatefulWidget {
  final BluetoothDevice? ecgDevice;
  const EcgChart({super.key, required this.ecgDevice});
  @override
  State<EcgChart> createState() => _EcgChartState();
}

class _EcgChartState extends State<EcgChart> {
  BluetoothDevice? _connectedEcgDevice;
  late ZoomPanBehavior _zoomPanBehavior;
  StreamSubscription<List<int>>? _ecgSubscription;

  // Chart-related
  List<EcgDataPoint> ecgDataPoints = [];
  double latestEcgTime = 0;
  static const double fixedWindowSize = 2000.0;
  late ChartSeriesController _chartSeriesController;
  int? startTimestampMs;
  final String serviceUuid = "b64cfb1e-045c-4975-89d6-65949bcb35aa";
  final String characteristicUuid = "33737322-fb5c-4a6f-a4d9-e41c1b20c30d";
  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(enablePanning: true);
    _connectedEcgDevice = widget.ecgDevice;
    _resetData();
    if (_connectedEcgDevice != null) {
      _setupCharacteristic(_connectedEcgDevice!);
    } else {
      print("Sorry was null");
    }
  }

  Future<void> _setupCharacteristic(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? targetCharacteristic;

      for (var service in services) {
        if (service.uuid.str == serviceUuid) {
          for (var c in service.characteristics) {
            if (c.uuid.str == characteristicUuid) {
              targetCharacteristic = c;
              break;
            }
          }
        }
      }
      // Converts the received bytes from the ble notification
      // and sends it to be processed by handleNotificaiton
      if (targetCharacteristic != null) {
        await targetCharacteristic.setNotifyValue(true);
        targetCharacteristic.onValueReceived.listen(
          (value) => handleNotification(Uint8List.fromList(value)),
        );
      }

      if (!mounted) {
        return;
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Connected'),
          content: SizedBox(
            width: 200.0,
            height: 100.0,
            child: Column(
              children: [
                Text('Successfully connected to ${device.platformName}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Connection failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to ${device.platformName}'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _ecgSubscription?.cancel();
    _connectedEcgDevice?.disconnect();
    super.dispose();
  }

  void _resetData() {
    ecgDataPoints.clear();
    startTimestampMs = null;
    latestEcgTime = 0;
  }

  void handleNotification(List<int> value) {
    final packet = decodeEcgData(value);
    if (packet == null) return;

    startTimestampMs ??= packet.timestamp;
    _updateChart(packet);
  }

  void _updateChart(EcgPacket packet) {
    for (int i = 0; i < packet.samples.length; i++) {
      double ecgTime =
          (packet.timestamp - (startTimestampMs ?? packet.timestamp))
              .toDouble() +
          i * 4;
      double ecgValue = packet.samples[i].toDouble();

      ecgDataPoints.add(EcgDataPoint(ecgTime, ecgValue));
      latestEcgTime = ecgTime;

      _chartSeriesController.updateDataSource(
        addedDataIndexes: [ecgDataPoints.length - 1],
      );
    }

    double cutoff = ecgDataPoints.last.ecgTime - fixedWindowSize;
    int removedCount = 0;
    while (ecgDataPoints.isNotEmpty && ecgDataPoints.first.ecgTime < cutoff) {
      ecgDataPoints.removeAt(0);
      removedCount++;
    }

    if (removedCount > 0) {
      _chartSeriesController.updateDataSource(
        removedDataIndexes: List.generate(removedCount, (index) => index),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Define the visible window using absolute time on ecgTime axis:
    double maxX = latestEcgTime;
    double minX = maxX - fixedWindowSize;
    print("Hi I am from the ecg chart");
    if (minX < 0) minX = 0;
    return Scaffold(
      body: _connectedEcgDevice == null
          ? Text("Could not connect to ECG")
          : Column(
              children: [
                Expanded(
                  child: SfCartesianChart(
                    backgroundColor: Colors.black,
                    plotAreaBorderWidth: 0,
                    primaryXAxis: NumericAxis(
                      minimum: minX,
                      maximum: maxX,
                      interval:
                          500, // Adds a tick mark every 500ms for clarity.
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: 4096,
                      interval: 512,
                    ),
                    series: [
                      LineSeries<EcgDataPoint, double>(
                        dataSource: ecgDataPoints,
                        xValueMapper: (EcgDataPoint dp, _) => dp.ecgTime,
                        yValueMapper: (EcgDataPoint dp, _) => dp.ecgValue,
                        animationDuration: 0,
                        // Absolutely necessary for real-time charting
                        onRendererCreated: (controller) =>
                            _chartSeriesController = controller,
                        color: const Color.fromARGB(255, 228, 10, 10),
                      ),
                    ],
                    zoomPanBehavior: _zoomPanBehavior,
                  ),
                ),
              ],
            ),
    );
  }
}

// Keep your EcgPacket and EcgDataPoint classes as-is
class EcgPacket {
  final List<int> samples;
  final int timestamp;
  EcgPacket(this.samples, this.timestamp);
}

class EcgDataPoint {
  final double ecgTime;
  final double ecgValue;
  EcgDataPoint(this.ecgTime, this.ecgValue);
}

EcgPacket? decodeEcgData(List<int> value) {
  if (value.length != 24) {
    print("Unexpected packet size: ${value.length}");
    return null;
  }

  final bytes = Uint8List.fromList(value);
  final byteData = ByteData.sublistView(bytes);

  List<int> samples = [];
  for (int i = 0; i < 10; i++) {
    samples.add(byteData.getUint16(i * 2, Endian.little));
  }
  int timestamp = byteData.getUint32(20, Endian.little);

  return EcgPacket(samples, timestamp);
}
