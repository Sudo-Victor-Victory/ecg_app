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
  VoidCallback? _stopListening;
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
                    // ECG status
                    Expanded(child: EcgStatusWidget()),
                    // Button next to status
                    // Button's text and functionality changes depending on its
                    // connectivity
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
                                _stopListening?.call();
                              },
                        child: Text(wrapper == null ? "Scan" : "Stop"),
                      ),
                    ),
                  ],
                ),
              ),
              // Page content - also dynamic on the selected page
              Expanded(
                child: wrapper == null
                    ? BleScanner(
                        appBarColor: widget.appBarColor,
                        appBarTitle: widget.appBarTitle,
                        onScanProvided: (scan) {
                          _startScan = scan;
                        },
                      )
                    : EcgChart(
                        onDisconnect: (device) {
                          _stopListening = device;
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
