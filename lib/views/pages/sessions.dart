import 'package:ecg_app/views/widgets/historical_chart.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class Sessions extends StatefulWidget {
  const Sessions({super.key});

  @override
  State<Sessions> createState() => _SessionsState();
}

class _SessionsState extends State<Sessions> {
  final client = Supabase.instance.client;

  List<Map<String, dynamic>> supabaseSessions = [];
  // The ecg_session row we pull from supabase.
  Map<String, dynamic>? selectedSession;
  // The ecg_data rows we pull from supabase.
  List<Map<String, dynamic>>? ecgData;

  bool isLoadingSessions = false;
  bool isChartingBPM = false;
  String? loadingSessionId;
  String appBarMessage = "Sessions ";
  @override
  void initState() {
    super.initState();
    _getSessionsFromSupabase();
  }

  /// Returns all sessions from Supabase that the user owns.
  Future<void> _getSessionsFromSupabase() async {
    try {
      setState(() => isLoadingSessions = true);

      final sessions = await client
          .from('ecg_session')
          .select('*')
          .order('start_time', ascending: false);

      setState(() {
        appBarMessage = "Total number of Sessions: ${sessions.length}";
        supabaseSessions = sessions;
        isLoadingSessions = false;
      });
    } catch (e) {
      if (!mounted) return;
      // optionally show an error
    }
  }

  /// Assigns returned rows from Supabase to flutter variables
  Future<void> _loadSession(
    Map<String, dynamic> session, {
    bool chartBPM = false,
  }) async {
    setState(() {
      loadingSessionId = session['id'];
      isChartingBPM = chartBPM;
    });

    final rows = await _fetchAllEcgRowsFromSession(session['id']);

    setState(() {
      selectedSession = session;
      ecgData = rows;
      loadingSessionId = null;
    });
  }

  /// Retrieves all ecg_data rows from supabase based on session_id
  Future<List<Map<String, dynamic>>> _fetchAllEcgRowsFromSession(
    String sessionId,
  ) async {
    const int pageSize = 1000;
    int from = 0;
    int to = pageSize - 1;
    final allRows = <Map<String, dynamic>>[];
    // Without range & chunking we could not pull the 1000s of ecg_rows from
    // the postgres database.
    while (true) {
      final chunk = await client
          .from('ecg_data')
          .select('*')
          .eq('session_id', sessionId)
          .range(from, to);

      if (chunk.isEmpty) break;

      allRows.addAll(List<Map<String, dynamic>>.from(chunk));
      if (chunk.length < pageSize) break; // no more rows

      from += pageSize;
      to += pageSize;
    }

    return allRows;
  }

  void _clearSelection() {
    setState(() {
      selectedSession = null;
      ecgData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If a session is selected, show its chart
    if (selectedSession != null && ecgData != null) {
      final startTime = DateTime.parse(
        selectedSession!['start_time'],
      ).toLocal();
      final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime);
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Session $formattedTime'),
              SizedBox(
                width: 40,
                height: 40,
                child: isChartingBPM
                    ? Lottie.asset('assets/lotties/heart_beat.json')
                    : Lottie.asset('assets/lotties/ecg.json'),
              ),
            ],
          ),
          centerTitle: true,
          leading: BackButton(onPressed: _clearSelection),
        ),
        body: HistoricalChart(
          ecgRows: ecgData!,
          startTime: startTime,
          isChartingBPM: isChartingBPM,
        ),
      );
    }

    // Otherwise show the list of sessions
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sessions'),
            const SizedBox(width: 8),
            // Animate the session count
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: supabaseSessions.length),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, _) {
                return Text('($value)', style: const TextStyle(fontSize: 16));
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: supabaseSessions.isEmpty
          ? Center(
              child: Lottie.asset('assets/lotties/loading.json', height: 250),
            )
          : ListView.builder(
              itemCount: supabaseSessions.length,
              itemBuilder: (_, i) => _buildSessionTile(supabaseSessions[i]),
            ),
    );
  }

  Widget _buildSessionTile(Map<String, dynamic> session) {
    // Parse DateTimes (actual DateTime objects) from ecg_session table
    final startDate = DateTime.parse(session['start_time']).toLocal();
    final endDate = DateTime.parse(session['end_time']).toLocal();
    final duration = endDate.difference(startDate);

    // Format them just for displaying to the user
    final startText = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate);
    final endText = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate);
    final sessionId = session['id'];

    // Tells the user if the duration of a session was minutes or seconds
    String unitOfTime = endDate.difference(startDate).inMinutes < 1
        ? "seconds"
        : "minutes";

    // Stack was chosen to overlay animations ontop of the row
    return Stack(
      children: [
        InkWell(
          onTap: () => _loadSession(session),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image(
                  image: AssetImage('assets/lotties/temp_img.jpg'),
                  width: 50,
                ),
                Padding(padding: EdgeInsetsGeometry.all(10)),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start: $startText',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Duration: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')} ${unitOfTime}",
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'End: $endText',
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
                    Icons.show_chart,
                    color: Colors.lightBlue,
                  ), // ECG icon
                  onPressed: () => _loadSession(session, chartBPM: false),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ), // BPM icon
                  onPressed: () {
                    _loadSession(session, chartBPM: true);
                  },
                ),
              ],
            ),
          ),
        ),

        // overlay loading animation on this tile if it's the tapped one
        if (loadingSessionId == sessionId) ...[
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Lottie.asset(
                    'assets/lotties/clipboard.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
