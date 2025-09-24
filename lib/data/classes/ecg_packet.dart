import 'dart:typed_data';

import 'package:ecg_app/data/classes/constants.dart';

class EcgPacket {
  // Currently is 28 bytes - 10 samples of 2 byte length
  // and a 4 byte timestamp.
  // then 2 bytes for BPM and 2 more for padding
  final List<int> samples; // 10 samples
  final int timestamp; // 4-byte timestamp
  final int bpm; // 2 byte bpm

  EcgPacket(this.samples, this.timestamp, this.bpm);

  static EcgPacket? fromBytes(List<int> value) {
    if (value.length != KEcgConstants.packetSize) {
      print("Unexpected packet size: ${value.length}");
      return null;
    }

    final bytes = Uint8List.fromList(value);
    final byteData = ByteData.sublistView(bytes);

    final samples = List<int>.generate(
      10,
      (i) => byteData.getUint16(i * 2, Endian.little),
    );

    final timestamp = byteData.getUint32(20, Endian.little);

    // Read bpm (bytes 24-27)
    final bpm = byteData.getUint16(24, Endian.little);
    print("BPM: $bpm");
    return EcgPacket(samples, timestamp, bpm);
  }
}
