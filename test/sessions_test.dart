// test/sessions_test.dart

import 'package:ecg_app/views/pages/sessions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late MockSupabaseHttpClient mockHttpClient;

  setUpAll(() async {
    // Fake SharedPreferences storage
    SharedPreferences.setMockInitialValues({});

    mockHttpClient = MockSupabaseHttpClient();

    // Initialize Supabase globally for the widget under test
    await Supabase.initialize(
      url: 'https://mock.supabase.co',
      anonKey: 'fakeAnonKey',
      httpClient: mockHttpClient,
    );
  });

  tearDown(() async {
    // Reset mock DB after each test
    mockHttpClient.reset();
  });

  tearDownAll(() {
    // Close client when done
    mockHttpClient.close();
  });

  testWidgets('Sessions shows 0 when no rows exist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Sessions()));

    // Allow async loads to finish
    await tester.pumpAndSettle();

    // Should show (0)
    expect(find.textContaining('(0)'), findsOneWidget);
  });

  testWidgets('Sessions shows 1 after inserting a row', (
    WidgetTester tester,
  ) async {
    // Insert row into the SAME client used by Sessions
    await Supabase.instance.client.from('ecg_session').insert({
      'id': 'AAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE',
      'start_time': '2025-09-24T10:00:00Z',
      'end_time': '2025-09-24T10:00:00Z',
      'user_id': '4708d9ec-d546-49b9-b506-3605b7a70e6a',
    });

    await tester.pumpWidget(const MaterialApp(home: Sessions()));

    await tester.pumpAndSettle();

    // Should show (1)
    expect(find.textContaining('(1)'), findsOneWidget);
  });
}
