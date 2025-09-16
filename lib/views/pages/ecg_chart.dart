import 'dart:async';
import 'dart:collection';
import 'package:ecg_app/data/classes/ecg_packet.dart';
import 'package:ecg_app/data/classes/notifiers.dart';
import 'package:ecg_app/utils/ble_manager.dart';
import 'package:ecg_app/views/widgets/bpm_widget.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EcgChart extends StatefulWidget {
  final void Function(VoidCallback scan)? onDisconnect;
  const EcgChart({super.key, this.onDisconnect});

  @override
  State<EcgChart> createState() => _EcgChartState();
}

class _EcgChartState extends State<EcgChart> {
  //                                              BLE logic variables
  // Manages all connection & disconnection logic
  final BleEcgManager _bleManager = BleEcgManager();
  // Stream for receiving BLE data
  StreamSubscription<EcgPacket>? _ecgSub;

  final Queue<EcgDataPoint> _unplottedEcgDataQueue = Queue<EcgDataPoint>();
  // Points currently displayed on the chart
  List<EcgDataPoint> plottedEcgData = [];
  // Necessary to update Syncfusion's charts
  ChartSeriesController? _chartSeriesController;
  double latestEcgTime = 0;
  double? _firstDeviceTimestamp;
  //                                                Chart config variables
  // 2 seconds width of visible chart
  static const double chartWindowSizeMs = 2000.0;
  // Time interval between samples (4ms → 250Hz sample rate)
  static const double samplePeriodMs = 4.0;
  // Number of samples to plot per 16ms timer tick (~60 fps screen refresh)
  static const int samplesPerFrame = 4;
  // Number of samples to accumulate before starting charting (~1s buffer)
  static const int initialBufferSamples = 250;
  Timer? _chartUpdateTimer;

  //                                                Supabase variables

  final List<Map<String, dynamic>> _supabaseBuffer = [];
  Timer? _supabaseFlushTimer;
  String? currentSessionId;
  static const int supabaseBatchSize = 200;
  static const Duration supabaseFlushInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();

    _ecgSub = _bleManager.ecgStream.listen((packet) {
      _addPacketToQueue(packet);
      _startProcessingByTimer();
      _addToSupabaseBuffer(packet);
    });

    // The definition of the onDisconnect callback ecg_page.dart uses.
    // tl;dr runs when the user presses the stop button on the chart page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDisconnect?.call(() {
        _endSupabaseSession();
        _ecgSub?.cancel();
        _bleManager.disconnect();
      });
    });

    _initSupabaseSession();
  }

  @override
  void dispose() {
    _ecgSub?.cancel();
    _chartUpdateTimer?.cancel();
    _supabaseFlushTimer?.cancel();
    _unplottedEcgDataQueue.clear();
    plottedEcgData.clear();
    _supabaseBuffer.clear();
    _chartSeriesController = null;
    super.dispose();
  }

  /// Deconstructs packet into individual samples EcgDataPoint(time & ecg value)
  /// and adds them to _unplottedEcgDataQueue.
  Future<void> _addPacketToQueue(EcgPacket packet) async {
    final n = packet.samples.length;
    // Timestamp is gathered at packet generation (10 samples) at samplePeriodMs
    // rate. So they are all samplePeriodMs apart.
    final firstTimestamp =
        packet.timestamp.toDouble() - (n - 1) * samplePeriodMs;

    _firstDeviceTimestamp ??= firstTimestamp;

    for (int i = 0; i < n; i++) {
      final timestamp =
          (firstTimestamp + i * samplePeriodMs) - _firstDeviceTimestamp!;
      final ecgValue = packet.samples[i].clamp(0, 4096).toDouble();
      _unplottedEcgDataQueue.add(EcgDataPoint(timestamp, ecgValue));
    }
    updateBPM(packet);
  }

  /// Removes left-most datapoints from the queue, adds it into the source of truth
  /// and updates the chart with the recently added points
  /// using a 2 second sliding window.
  void _processQueuedPacket() {
    int toAdd = 0;

    while (_unplottedEcgDataQueue.isNotEmpty && toAdd < samplesPerFrame) {
      final dataPoint = _unplottedEcgDataQueue.removeFirst();
      plottedEcgData.add(dataPoint);
      latestEcgTime = dataPoint.ecgTime;
      toAdd++;
    }

    if (toAdd == 0) {
      return;
    }
    // Trim sliding window
    final cutoff = latestEcgTime - chartWindowSizeMs;
    while (plottedEcgData.isNotEmpty && plottedEcgData.first.ecgTime < cutoff) {
      plottedEcgData.removeAt(0);
    }
    // Add the new data points into the chart
    final startIndex = plottedEcgData.length - toAdd;
    _chartSeriesController?.updateDataSource(
      addedDataIndexes: List.generate(toAdd, (i) => startIndex + i),
    );
    // Used to refresh the chart to display changes.
    setState(() {});
  }

  /// Calls _processQueuedPacket() within a 16ms duration for a smooth charting
  /// experience.
  /// tl;dr processes packets via timer to get a smooth chart instead of
  /// whenever the ESP32 sends data over BLE.
  void _startProcessingByTimer() {
    if (_chartUpdateTimer?.isActive == true) {
      return;
    }
    // 16 was chosen to get a 60fps screen refresh
    _chartUpdateTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || _unplottedEcgDataQueue.isEmpty) return;

      // Soft start: wait until buffer has ~1s data
      if (plottedEcgData.isEmpty &&
          _unplottedEcgDataQueue.length < initialBufferSamples) {
        return;
      }

      _processQueuedPacket();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double minX = (latestEcgTime < chartWindowSizeMs)
        ? 0
        : latestEcgTime - chartWindowSizeMs;
    final double maxX = latestEcgTime;

    return Stack(
      children: <Widget>[
        SafeArea(
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 800,
              child: SfCartesianChart(
                backgroundColor: Colors.black,
                plotAreaBorderWidth: 0,
                margin: EdgeInsets.all(15),
                primaryXAxis: NumericAxis(
                  minimum: minX,
                  maximum: maxX,
                  interval: 500,
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 4096,
                  interval: 512,
                ),
                series: [
                  LineSeries<EcgDataPoint, double>(
                    dataSource: plottedEcgData,
                    xValueMapper: (dataPoint, _) => dataPoint.ecgTime,
                    yValueMapper: (dataPoint, _) => dataPoint.ecgValue,
                    animationDuration: 0,
                    onRendererCreated: (controller) {
                      _chartSeriesController = controller;
                    },
                    color: const Color.fromARGB(255, 228, 10, 10),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(top: -5, right: 40, child: BpmWidget()),
      ],
    );
  }

  /// Currently creates an ecg_session for ecg_packets to be sent into.
  /// Also begins flushinng of buffered data for supabase.
  Future<void> _initSupabaseSession() async {
    final client = Supabase.instance.client;
    final authResponse = await client.auth.refreshSession();
    print('Refreshed session: $authResponse');

    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated or session expired');
    }

    final userId = user.id;
    print('Authenticated user ID: $userId');

    try {
      // Uses insert to create a new session and is followed by
      // select to immediately get the session id for insertion in ecg_data.
      final insertedSession = await client
          .from('ecg_session')
          .insert({'user_id': userId})
          .select()
          .single();

      currentSessionId = insertedSession['id'] as String;
      print('Inserted ECG session: $insertedSession');
    } catch (e) {
      print('Error inserting ECG session: $e');
      rethrow;
    }

    _supabaseFlushTimer = Timer.periodic(supabaseFlushInterval, (_) {
      _flushSupabaseBuffer();
    });
  }

  /// Enqueues data from the ble stream into a dedicated queue to be
  /// dequeued and inserted into the db at a later time.
  void _addToSupabaseBuffer(EcgPacket packet) {
    if (currentSessionId == null) return;

    _supabaseBuffer.add({
      'session_id': currentSessionId,
      'timestamp_ms': packet.timestamp,
      'ecg_data': packet.samples,
      'bpm': packet.bpm,
    });

    if (_supabaseBuffer.length >= supabaseBatchSize) {
      _flushSupabaseBuffer();
    }
  }

  /// Attempts to insert rows into ecg_data within _supabaseBuffer to Supabase's
  /// table. Writes specifically in ecg_data
  Future<void> _flushSupabaseBuffer() async {
    if (_supabaseBuffer.isEmpty) return;

    final client = Supabase.instance.client;
    final batch = List<Map<String, dynamic>>.from(_supabaseBuffer);
    _supabaseBuffer.clear();

    try {
      await client.from('ecg_data').insert(batch);
      print("Inserted ${batch.length} ECG rows");
    } catch (e) {
      debugPrint("Supabase insert failed: $e");
      // re-queue data if insert fails
      _supabaseBuffer.insertAll(0, batch);
    }
  }

  /// Updates row of currentSessionId (id in ecg_session) with the end time of
  /// the session  (column end_time)
  Future<void> _endSupabaseSession() async {
    try {
      final client = Supabase.instance.client;
      await client
          .from('ecg_session')
          .update({'end_time': DateTime.now().toUtc().toIso8601String()})
          .eq('id', currentSessionId!);
      print("Session $currentSessionId has come to an end");
    } catch (e) {
      print("Error ending Supabase session: $e");
    }
  }

  void updateBPM(EcgPacket newPacket) {
    bpm.value = newPacket.bpm;
  }
}

// Used to encapsulate important data for charting
class EcgDataPoint {
  final double ecgTime;
  final double ecgValue;
  EcgDataPoint(this.ecgTime, this.ecgValue);
}
