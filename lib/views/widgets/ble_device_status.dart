import 'package:flutter/material.dart';
import 'package:ecg_app/data/classes/notifiers.dart';
import 'package:lottie/lottie.dart';

/// Display's a device's name & lottie anim while connected,
/// otherwise says no device connected with a red dot.
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
              isConnected
                  ? Lottie.asset(
                      'assets/lotties/ecg.json',
                      fit: BoxFit.cover,
                      height: 25.0,
                      width: 25.0,
                    )
                  : Icon(Icons.circle, color: Colors.red, size: 14),
            ],
          ),
        );
      },
    );
  }
}
