import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecg_app/data/classes/ecg_packet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Essentially a singleton that manages BLE connection to an ECG device.

///
///- Connects / Disconnects from a single BLE ECG device
///- Discovers the characteristic for ECG data and subscribes to notifications
///- Parses bytes into EcgPacket objects
///- Broadcats packets to listeners through ecgStream
///- Expose connection status through ChangeNotifier
///
class BleEcgManager extends ChangeNotifier {
  // Singleton
  static final BleEcgManager _instance = BleEcgManager._internal();
  factory BleEcgManager() => _instance;
  BleEcgManager._internal();

  BluetoothDevice? _device;

  // Subscription to characteristic value notifications
  StreamSubscription<List<int>>? _subscription;

  // Broadcast stream of ECG packets for widgets like EcgChart to subscribe to
  final _ecgController = StreamController<EcgPacket>.broadcast();
  Stream<EcgPacket> get ecgStream => _ecgController.stream;

  bool _connected = false;
  bool get isConnected => _connected;

  // UUIDs of the ECG service and characteristic defined in the ESP32 code.
  final String serviceUuid = "b64cfb1e-045c-4975-89d6-65949bcb35aa";
  final String characteristicUuid = "33737322-fb5c-4a6f-a4d9-e41c1b20c30d";

  /// Connects to device, discovers the ECG characteristic,
  /// and begins streaming notifications into the ecgStream
  Future<void> connect(BluetoothDevice device) async {
    _device = device;
    await device.connect(timeout: const Duration(seconds: 10));
    _connected = true;
    notifyListeners();
    await _saveRecentDevice(device);
    final services = await device.discoverServices();
    final ecgChar = services
        .expand((s) => s.characteristics)
        .firstWhere((c) => c.uuid.toString() == characteristicUuid);

    await ecgChar.setNotifyValue(true);

    // Our Listener that decodes bytes and transforms it into EcgPackets
    _subscription = ecgChar.onValueReceived.listen((data) {
      final packet = EcgPacket.fromBytes(data);
      if (packet != null) {
        _ecgController.add(packet);
      }
    });
  }

  /// Necessary for system to be idempotent
  /// Disconnects from the device, cancels notifs, and resets connection bool.
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _device?.disconnect();
    _device = null;
    _connected = false;
    notifyListeners();
  }

  /// Saves a reference to last 3 successfully connected bluetooth devices via
  /// shared prefs.
  Future<void> _saveRecentDevice(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    final name = device.platformName.isNotEmpty
        ? device.platformName
        : 'Unnamed Device';

    // Each item stored as "name|id"
    final entry = '$name|${device.remoteId}';
    final list = prefs.getStringList('recent_devices') ?? [];

    // Remove if already exists (so newest goes first)
    list.removeWhere((e) => e.split('|')[1] == device.remoteId.toString());
    list.insert(0, entry);

    // Only keep last 3
    if (list.length > 3) list.removeRange(3, list.length);

    await prefs.setStringList('recent_devices', list);
  }
}
