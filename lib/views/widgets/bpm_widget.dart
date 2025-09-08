import 'package:ecg_app/data/classes/ecg_packet.dart';
import 'package:ecg_app/data/classes/notifiers.dart';
import 'package:flutter/material.dart';

class BpmWidget extends StatefulWidget {
  const BpmWidget({super.key});

  @override
  State<BpmWidget> createState() => _BpmWidgetState();
}

class _BpmWidgetState extends State<BpmWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: bpm,
      builder: (context, newBpm, child) {
        return Card(
          elevation: 12,
          color: Colors.cyanAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(120.0),
          ),
          child: Text("💖 BPM: $newBpm   "),
        );
      },
    );
  }
}
