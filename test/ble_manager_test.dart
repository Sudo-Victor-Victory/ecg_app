import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecg_app/utils/ble_manager.dart';

import 'mocks.dart';

class MockBluetoothCharacteristic extends Mock
    implements BluetoothCharacteristic {}

void main() {
  late BleEcgManager manager;
  late MockBluetoothDevice mockDevice;
  late MockBluetoothService mockService;
  late MockBluetoothCharacteristic mockChar;

  setUpAll(() {
    // Register fallback values so `any()` works with Mocktail
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(const DeviceIdentifier('FAKE_ID'));
    registerFallbackValue(Guid('00000000-0000-0000-0000-000000000000'));
  });

  setUp(() {
    manager = BleEcgManager();
    mockDevice = MockBluetoothDevice();
    mockService = MockBluetoothService();
    mockChar = MockBluetoothCharacteristic();

    // Reset SharedPreferences before each test for idempotency
    SharedPreferences.setMockInitialValues({});
  });

  test('connect sets isConnected true and saves device', () async {
    // Given
    when(() => mockDevice.platformName).thenReturn("FakeECG");
    when(() => mockDevice.remoteId).thenReturn(const DeviceIdentifier("1234"));
    when(
      () => mockDevice.connect(timeout: any(named: "timeout")),
    ).thenAnswer((_) => Future.value());
    when(
      () => mockDevice.discoverServices(),
    ).thenAnswer((_) async => [mockService]);
    when(() => mockService.characteristics).thenReturn([mockChar]);
    when(() => mockChar.uuid).thenReturn(Guid(manager.characteristicUuid));
    when(() => mockChar.setNotifyValue(true)).thenAnswer((_) async => true);
    when(
      () => mockChar.onValueReceived,
    ).thenAnswer((_) => const Stream.empty());

    // When
    await manager.connect(mockDevice);

    // Then
    expect(manager.isConnected, true);

    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recent_devices');
    expect(recent, isNotNull);
    expect(recent, isNotEmpty);
    expect(recent!.first, contains("FakeECG"));
  });

  test('disconnect resets isConnected to false', () async {
    // Given
    when(() => mockDevice.platformName).thenReturn("FakeECG");
    when(() => mockDevice.remoteId).thenReturn(const DeviceIdentifier("1234"));
    when(
      () => mockDevice.connect(timeout: any(named: "timeout")),
    ).thenAnswer((_) => Future.value());
    when(
      () => mockDevice.discoverServices(),
    ).thenAnswer((_) async => [mockService]);
    when(() => mockService.characteristics).thenReturn([mockChar]);
    when(() => mockChar.uuid).thenReturn(Guid(manager.characteristicUuid));
    when(() => mockChar.setNotifyValue(true)).thenAnswer((_) async => true);
    when(
      () => mockChar.onValueReceived,
    ).thenAnswer((_) => const Stream.empty());

    await manager.connect(mockDevice);

    // When
    when(() => mockDevice.disconnect()).thenAnswer((_) => Future.value());

    // Act
    await manager.disconnect();

    // Then
    expect(manager.isConnected, false);

    final prefs = await SharedPreferences.getInstance();
    // Device should still be saved in recent_devices
    final recent = prefs.getStringList('recent_devices');
    expect(recent, isNotNull);
    expect(recent!.first, contains("FakeECG"));
  });
}
