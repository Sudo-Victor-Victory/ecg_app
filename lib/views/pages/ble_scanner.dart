import 'dart:async';
import 'package:ecg_app/data/classes/notifiers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleScanner extends StatefulWidget {
  const BleScanner({
    super.key,
    required this.appBarTitle,
    required this.appBarColor,
  });
  final String appBarTitle;
  final Color appBarColor;
  @override
  State<BleScanner> createState() => _BleScannerState();
}

class _BleScannerState extends State<BleScanner> {
  // The list of devices
  List<ScanResult> _bluetoothDevices = [];

  // Used to prevent the Bluetooth adapter from duplicating resources
  bool _isScanningForBluetoothDevices = false;

  // Subscription to asynchronously retreive List<ScanResult> which has
  // Bluetooth devices. Will be initialized on retrival of BLE devices.
  late final StreamSubscription<List<ScanResult>> _scanSubscription;

  final String serviceUuid = "b64cfb1e-045c-4975-89d6-65949bcb35aa";
  final String characteristicUuid = "33737322-fb5c-4a6f-a4d9-e41c1b20c30d";

  // List of data points that is being charted

  // Used to have change timestamps to be relative instead of esp32's absolute.
  int? startTimestampMs;

  double latestEcgTime = 0;

  @override
  void initState() {
    super.initState();
    // Calls initBLE after Widget Tree has finished being built.
    // Without it, the BLE util will be inaccessible & cause errors.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initBle());
  }

  Future<void> _initBle() async {
    try {
      await _requestPermissions();
      // Allows us to scan for BLE dev. if the initial state
      // of the Bluetooth adapter is on. Otherwise the adapater has issues.
      final state = await FlutterBluePlus.adapterState.first;
      if (state == BluetoothAdapterState.on) {
        _listenScanResults();
        await _startScan();
      } else {
        print("Bluetooth is not ON");
      }
    } catch (e) {
      print("BLE init error: $e");
    }
  }

  Future<void> _requestPermissions() async {
    if (!await Permission.bluetoothScan.request().isGranted) {
      throw Exception("Bluetooth scan permission not granted");
    }

    if (!await Permission.bluetoothConnect.request().isGranted) {
      throw Exception("Bluetooth connect permission not granted");
    }

    if (!await Permission.location.request().isGranted) {
      throw Exception("Location permission not granted");
    }
  }

  void _listenScanResults() {
    // Updates _scanSubscription based on the stream of scan results
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (!listEquals(_bluetoothDevices, results)) {
        // Rebuilds the widget with the new list of devices
        setState(() => _bluetoothDevices = List.from(results));
      }
    });
  }

  Future<void> _startScan() async {
    if (_isScanningForBluetoothDevices) {
      return;
    }
    // A scan started - therefore we must set the bool to prevent dup. scans.
    setState(() => _isScanningForBluetoothDevices = true);
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      print("Scan failed: $e");
    } finally {
      setState(() => _isScanningForBluetoothDevices = false);
    }
  }

  @override
  void dispose() {
    // Stops the stream from receiving updates.
    _scanSubscription.cancel();
    // Stops the bluetooth scan.
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _connectToDevice(BluetoothDevice device, String name) async {
    try {
      if (_isScanningForBluetoothDevices) {
        await FlutterBluePlus.stopScan();
        setState(() => _isScanningForBluetoothDevices = false);
      }

      print('Connecting to ${device.remoteId}');
      await device.connect(timeout: const Duration(seconds: 10));
      if (!mounted) {
        return;
      }
      print('Connected to ${device.remoteId}');
      print('Notifier BEFORE: ${connectedDevice.value}');
      connectedDevice.value = DeviceWrapper(
        device,
      ); // always a new wrapper object
      print('Notifier AFTER: ${connectedDevice.value}');

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

      if (targetCharacteristic != null) {
        return;
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Connected'),
          content: SizedBox(
            width: 200.0,
            height: 100.0,
            child: Column(children: [Text('Successfully connected to $name')]),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to connect to $name')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(
          onPressed: _startScan,
          child: Text("Tap to scan"),
          style: FilledButton.styleFrom(
            minimumSize: Size(double.infinity, 50.0),
            shape: RoundedRectangleBorder(),
          ),
        ),
        if (_bluetoothDevices.isEmpty)
          const Expanded(child: Center(child: Text("No devices found.")))
        else
          Expanded(
            child: ListView.builder(
              itemCount: _bluetoothDevices.length,
              itemBuilder: (_, index) =>
                  _buildDeviceTile(_bluetoothDevices[index]),
            ),
          ),
      ],
    );
  }

  // Creates visual and ontap for a BLE scan result, and houses Ecg charter
  Widget _buildDeviceTile(ScanResult result) {
    final bluetoothDevice = result.device;
    final bluetoothDeviceName = bluetoothDevice.platformName.isNotEmpty
        ? bluetoothDevice.platformName
        : "Unnamed Device";

    return InkWell(
      onTap: () => _connectToDevice(bluetoothDevice, bluetoothDeviceName),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bluetoothDeviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bluetoothDevice.remoteId.toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.bluetooth),
          ],
        ),
      ),
    );
  }
}
