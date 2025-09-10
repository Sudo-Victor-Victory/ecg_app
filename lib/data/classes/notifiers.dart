import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(true);
ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<DeviceWrapper?> connectedDevice = ValueNotifier(null);
ValueNotifier<int> bpm = ValueNotifier(0);

class DeviceWrapper {
  final BluetoothDevice device;
  DeviceWrapper(this.device);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceWrapper &&
          runtimeType == other.runtimeType &&
          device.remoteId == other.device.remoteId;

  @override
  int get hashCode => device.remoteId.hashCode;
}
