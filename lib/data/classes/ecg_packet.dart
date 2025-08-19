import 'dart:typed_data';

class EcgPacket {
  // Currently is 24 bytes - 10 samples of 2 byte length
  // and a 4 byte timestamp.
  final List<int> samples; // 10 samples
  final int timestamp; // 4-byte timestamp

  EcgPacket(this.samples, this.timestamp);

  static EcgPacket? fromBytes(List<int> value) {
    if (value.length != 24) {
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
    return EcgPacket(samples, timestamp);
  }
}
