import 'package:ecg_app/views/widgets/sessions_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late MockSupabaseHttpClient mockHttpClient;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    mockHttpClient = MockSupabaseHttpClient();

    await Supabase.initialize(
      url: 'https://mock.supabase.co',
      anonKey: 'fakeAnonKey',
      httpClient: mockHttpClient,
    );
  });

  tearDown(() async {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  testWidgets('SessionsTile shows "No sessions found" when empty', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SessionsTile()));

    await tester.pumpAndSettle();

    expect(find.text('No sessions found'), findsOneWidget);
  });

  testWidgets('SessionsTile shows a session after inserting row', (
    tester,
  ) async {
    // Insert a mock session
    await Supabase.instance.client.from('ecg_session').insert({
      'id': 'AAAA-BBBB-CCCC-DDDD',
      'start_time': '2025-09-24T10:00:00Z',
      'end_time': '2025-09-24T10:10:00Z',
      'user_id': '4708d9ec-d546-49b9-b506-3605b7a70e6a',
    });

    await tester.pumpWidget(const MaterialApp(home: SessionsTile()));

    await tester.pumpAndSettle();

    // The first session card should be visible
    expect(find.textContaining('Session 1'), findsOneWidget);
    expect(find.textContaining('Duration:'), findsOneWidget);
  });

  // Not an ideal test since the unit under test is the duration.
  // Will extract duration logic into its own function to further
  // test in another PR
  testWidgets('Session tile shows correct duration', (tester) async {
    // Insert a mock session
    await Supabase.instance.client.from('ecg_session').insert({
      'id': 'AAAA-BBBB-CCCC-DDDD',
      'start_time': '2025-09-24T10:00:00Z',
      'end_time': '2025-09-24T10:10:00Z',
      'user_id': '4708d9ec-d546-49b9-b506-3605b7a70e6a',
    });

    await tester.pumpWidget(const MaterialApp(home: SessionsTile()));

    await tester.pumpAndSettle();

    // The first session card should be visible
    expect(find.textContaining('Session 1'), findsOneWidget);
    expect(find.textContaining('Duration: 10:00 Min'), findsOneWidget);
  });
}
