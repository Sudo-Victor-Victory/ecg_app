import 'package:ecg_app/data/classes/notifiers.dart';
import 'package:ecg_app/views/pages/ble_scanner.dart';
import 'package:ecg_app/views/pages/ecg_chart.dart';
import 'package:flutter/material.dart';

class EcgPage extends StatefulWidget {
  final Color appBarColor;
  final String appBarTitle;
  const EcgPage({
    super.key,
    required this.appBarColor,
    required this.appBarTitle,
  });

  @override
  State<EcgPage> createState() => _EcgPageState();
}

class _EcgPageState extends State<EcgPage> {
  @override
  Widget build(BuildContext context) {
    print('EcgPage build called');

    return ValueListenableBuilder<DeviceWrapper?>(
      valueListenable: connectedDevice,
      builder: (context, wrapper, _) {
        print('ValueListenableBuilder builder called with $wrapper');

        if (wrapper == null) {
          return Scaffold(
            body: BleScanner(
              appBarColor: widget.appBarColor,
              appBarTitle: widget.appBarTitle,
            ),
          );
        }

        return Scaffold(
          body: EcgChart(
            key: ValueKey(wrapper.device),
            ecgDevice: wrapper.device,
          ),
        );
      },
    );
  }
}
