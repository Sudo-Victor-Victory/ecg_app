import 'package:ecg_app/utils/ble_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RecentDevicesTile extends StatefulWidget {
  const RecentDevicesTile({super.key});

  @override
  State<RecentDevicesTile> createState() => _RecentDevicesTileState();
}

class _RecentDevicesTileState extends State<RecentDevicesTile> {
  List<Map<String, String>> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadRecentDevices();
  }

  Future<void> _loadRecentDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('recent_devices') ?? [];
    final parsed = list.map((e) {
      final parts = e.split('|');
      return {'name': parts[0], 'id': parts[1]};
    }).toList();

    setState(() => _devices = parsed);
  }

  Future<void> _connectTo(String id) async {
    final device = BluetoothDevice(remoteId: DeviceIdentifier(id));
    await BleEcgManager().connect(device);
    // Optionally: show snackbar or navigate
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connecting to ${device.remoteId}...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_devices.isEmpty) {
      return const Center(child: Text('No recent devices'));
    }

    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final d = _devices[index];

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _connectTo(d['id']!),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // temporary icon will replace.
                  const Icon(Icons.watch, size: 40, color: Colors.blueAccent),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d['id'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.bluetooth_connected,
                      color: Colors.lightBlue,
                    ),
                    onPressed: () => _connectTo(d['id']!),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
