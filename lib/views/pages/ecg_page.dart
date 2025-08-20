import 'package:ecg_app/data/classes/notifiers.dart';
import 'package:ecg_app/views/pages/ble_scanner.dart';
import 'package:ecg_app/views/pages/ecg_chart.dart';
import 'package:ecg_app/views/widgets/ble_device_status.dart';
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

    return Scaffold(
      body: ValueListenableBuilder<DeviceWrapper?>(
        valueListenable: connectedDevice,
        builder: (context, wrapper, _) {
          print('ValueListenableBuilder builder called with $wrapper');

          return Column(
            children: [
              const EcgStatusWidget(),
              Expanded(
                child: wrapper == null
                    ? BleScanner(
                        appBarColor: widget.appBarColor,
                        appBarTitle: widget.appBarTitle,
                      )
                    : const EcgChart(),
              ),
            ],
          );
        },
      ),
    );
  }
}
