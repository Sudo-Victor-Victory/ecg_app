import 'dart:async';

import 'package:ecg_app/data/classes/ecg_packet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleEcgManager extends ChangeNotifier {
  static final BleEcgManager _instance = BleEcgManager._internal();
  factory BleEcgManager() => _instance;
  BleEcgManager._internal();

  BluetoothDevice? _device;
  StreamSubscription<List<int>>? _subscription;

  final _ecgController = StreamController<EcgPacket>.broadcast();
  Stream<EcgPacket> get ecgStream => _ecgController.stream;

  bool _connected = false;
  bool get isConnected => _connected;

  // replace with your actual UUIDs
  final String serviceUuid = "b64cfb1e-045c-4975-89d6-65949bcb35aa";
  final String characteristicUuid = "33737322-fb5c-4a6f-a4d9-e41c1b20c30d";

  Future<void> connect(BluetoothDevice device) async {
    _device = device;
    await device.connect(timeout: const Duration(seconds: 10));
    _connected = true;
    notifyListeners();

    final services = await device.discoverServices();
    final ecgChar = services
        .expand((s) => s.characteristics)
        .firstWhere((c) => c.uuid.toString() == characteristicUuid);

    await ecgChar.setNotifyValue(true);

    _subscription = ecgChar.onValueReceived.listen((data) {
      final packet = EcgPacket.fromBytes(data);
      if (packet != null) {
        _ecgController.add(packet);
      }
    });
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _device?.disconnect();
    _device = null;
    _connected = false;
    notifyListeners();
  }
}
