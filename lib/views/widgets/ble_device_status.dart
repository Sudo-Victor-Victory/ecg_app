import 'package:ecg_app/views/widgets/ble_manager.dart';
import 'package:flutter/material.dart';
import 'package:ecg_app/data/classes/notifiers.dart';

class EcgStatusWidget extends StatelessWidget {
  const EcgStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DeviceWrapper?>(
      valueListenable: connectedDevice,
      builder: (context, device, _) {
        final bool isConnected = device != null;

        return Material(
          color: isConnected ? Colors.tealAccent : Colors.grey.shade300,

          child: InkWell(
            onTap: isConnected
                ? () {
                    connectedDevice.value = null;
                    BleEcgManager().disconnect();
                    selectedPageNotifier.value = 1;
                  }
                : null,
            splashColor: Colors.blue,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  isConnected
                      ? device.device.platformName
                      : "No connected device",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 2),

                Icon(
                  Icons.circle,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 14,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
