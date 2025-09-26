import 'package:ecg_app/views/widgets/historical_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  group('HistoricalChart widget', () {
    testWidgets('renders ECG chart with provided data', (tester) async {
      // Given
      final now = DateTime(2025, 9, 26, 10, 0, 0);
      final ecgRows = [
        {
          'id': 'a8d186f3-c320-498d-9239-66afb91129bd',
          'session_id': 'fd0252d4-766e-46f3-bcde-8cd14b1a3a53',
          'timestamp_ms': 0,
          'ecg_data': [1594, 1596, 1597, 1598, 1600],
          'bpm': 68,
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: HistoricalChart(
            ecgRows: ecgRows,
            startTime: now,
            isChartingBPM: false,
            durationString: 'Duration: 0:05 Min',
          ),
        ),
      );
      // When
      await tester.pumpAndSettle();

      final chartWidget = tester.widget<SfCartesianChart>(
        find.byType(SfCartesianChart),
      );
      // Then
      expect(chartWidget.series.first, isA<LineSeries>());

      final series = chartWidget.series.first as LineSeries;

      expect(series.dataSource, isNotEmpty);

      final dataPoints = series.dataSource?.cast();
      expect(dataPoints?.any((p) => (p as dynamic).ecgValue == 1597), isTrue);
    });

    testWidgets('renders nothing when no ECG rows provided', (tester) async {
      // Given
      final now = DateTime(2025, 9, 26, 10, 0, 0);
      List<Map<String, dynamic>> ecgRows = [];
      await tester.pumpWidget(
        MaterialApp(
          home: HistoricalChart(
            ecgRows: ecgRows,
            startTime: now,
            isChartingBPM: false,
            durationString: 'Duration: 0:05 Min',
          ),
        ),
      );
      // When
      await tester.pumpAndSettle();

      // Then
      expect(find.text('No chart data'), findsOneWidget);

      // And importantly, no chart is rendered
      expect(find.byType(SfCartesianChart), findsNothing);
    });

    testWidgets('renders BPM chart when isChartingBPM is true', (tester) async {
      // Given
      final now = DateTime(2025, 9, 26, 10, 0, 0);
      final bpmRows = [
        {
          'id': 'bpm-row-1',
          'session_id': 'session-123',
          'timestamp_ms': 0,
          'ecg_data': [], // not used in BPM mode
          'bpm': 72,
        },
        {
          'id': 'bpm-row-2',
          'session_id': 'session-123',
          'timestamp_ms': 1000,
          'ecg_data': [],
          'bpm': 75,
        },
      ];
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: HistoricalChart(
            ecgRows: bpmRows,
            startTime: now,
            isChartingBPM: true,
            durationString: 'Duration: 0:02 Min',
          ),
        ),
      );

      await tester.pumpAndSettle();

      final chartWidget = tester.widget<SfCartesianChart>(
        find.byType(SfCartesianChart),
      );

      final series = chartWidget.series.first as LineSeries;
      // Then
      expect(series.dataSource, isNotEmpty);

      final dataPoints = series.dataSource?.cast();
      expect(dataPoints?.any((p) => (p as dynamic).ecgValue == 72), isTrue);
      expect(dataPoints?.any((p) => (p as dynamic).ecgValue == 75), isTrue);
    });
  });
}
