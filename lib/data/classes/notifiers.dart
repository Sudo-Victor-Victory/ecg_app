import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(true);
ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<DeviceWrapper?> connectedDevice = ValueNotifier(null);
ValueNotifier<int> bpm = ValueNotifier(0);
ValueNotifier<double> textSize = ValueNotifier(1.0);

/// Used within connectedDevice ValueNotifier to handle object comparison
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

/// Free function used to retrieve the textSize value used for scaledText
Future<void> loadTextSize() async {
  final prefs = await SharedPreferences.getInstance();
  textSize.value = prefs.getDouble('textSize') ?? 1.0;
}

/// Free function used to set the textSize value used for scaledText
Future<void> saveTextSize(double value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('textSize', value);
}
