import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ecg_app/data/classes/notifiers.dart';

/// Displays the BPM received while a device is connected
class BpmWidget extends StatelessWidget {
  const BpmWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: bpm,
      builder: (context, newBpm, child) {
        return Card(
          color: Colors.cyanAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                  width: 30,

                  child: Lottie.asset(
                    'assets/lotties/heart_beat.json',
                    repeat: true,
                  ),
                ),
                const SizedBox(width: 8),

                Text(
                  "BPM: $newBpm",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
