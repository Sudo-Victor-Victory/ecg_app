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

@override
class _EcgPageState extends State<EcgPage> {
  VoidCallback? _startScan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<DeviceWrapper?>(
        valueListenable: connectedDevice,
        builder: (context, wrapper, _) {
          return Column(
            children: [
              SizedBox(
                height: 45,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: EcgStatusWidget()),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: wrapper == null
                            ? () {
                                _startScan?.call();
                              }
                            : () {
                                connectedDevice.value = null;
                              },
                        child: Text(wrapper == null ? "Scan" : "Stop"),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: wrapper == null
                    ? BleScanner(
                        appBarColor: widget.appBarColor,
                        appBarTitle: widget.appBarTitle,
                        onScanProvided: (scan) {
                          _startScan = scan;
                        },
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
