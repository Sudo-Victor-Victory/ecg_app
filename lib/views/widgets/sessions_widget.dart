import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecg_app/views/widgets/historical_chart.dart';

class SessionsTile extends StatefulWidget {
  final int? limit;
  const SessionsTile({super.key, this.limit});

  @override
  State<SessionsTile> createState() => _SessionsTileState();
}

class _SessionsTileState extends State<SessionsTile> {
  final client = Supabase.instance.client;
  // Global used to hold all session data for easy access across functions.
  List<Map<String, dynamic>> supabaseSessions = [];
  String? selectedSessionId;
  bool isLoadingSessions = false;
  @override
  void initState() {
    super.initState();
    fetchSessions(limit: widget.limit);
  }

  /// Returns (limit) amount of sessions the user owns.
  Future<void> fetchSessions({int? limit}) async {
    if (!mounted) return;
    setState(() => isLoadingSessions = true);

    var query = client
        .from('ecg_session')
        .select('*')
        .order('start_time', ascending: false);
    if (limit != null) query = query.limit(limit);

    final data = await query;

    if (!mounted) return;
    setState(() {
      supabaseSessions = List<Map<String, dynamic>>.from(data);
      isLoadingSessions = false;
    });
  }

  /// Retrieve and assign returned rows from Supabase to and navigates
  /// to the charting site.
  Future<void> _retrieveDataAndChart(
    Map<String, dynamic> session, {
    required bool chartBPM,
  }) async {
    final sessionId = session['id'];
    setState(() => selectedSessionId = sessionId);

    //  Chunked fetching
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

    final startTime = DateTime.parse(session['start_time']).toLocal();

    setState(() => selectedSessionId = null);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => Navigator.pop(context)),
            centerTitle: true,
            backgroundColor: const Color(0xFF07A0C3),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Session ${DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: chartBPM
                      ? Lottie.asset('assets/lotties/heart_beat.json')
                      : Lottie.asset('assets/lotties/ecg.json'),
                ),
              ],
            ),
          ),
          body: HistoricalChart(
            ecgRows: allRows,
            startTime: startTime,
            isChartingBPM: chartBPM,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTile(Map<String, dynamic> session, int index) {
    final startDate = DateTime.parse(session['start_time']).toLocal();
    final endDate = DateTime.parse(session['end_time']).toLocal();
    final duration = endDate.difference(startDate);
    final startText = DateFormat('yyyy-MM-dd HH:mm').format(startDate);
    final endText = DateFormat('yyyy-MM-dd HH:mm').format(endDate);
    final sessionId = session['id'];
    final unitOfTime = duration.inMinutes < 1 ? "seconds" : "minutes";

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _retrieveDataAndChart(session, chartBPM: false),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Image(
                    image: AssetImage('assets/lotties/temp_img.jpg'),
                    width: 50,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Session $index",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Duration: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')} $unitOfTime",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text('Start: $startText, End: $endText'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.show_chart, color: Colors.lightBlue),
                    onPressed: () =>
                        _retrieveDataAndChart(session, chartBPM: false),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () =>
                        _retrieveDataAndChart(session, chartBPM: true),
                  ),
                ],
              ),
            ),
            // Overlays clipboard anim ontop of the selected session
            if (selectedSessionId == sessionId) ...[
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // while the client is loading sessions the loading anim will play
    if (isLoadingSessions) {
      return Center(
        child: Lottie.asset(
          'assets/lotties/loading.json',
          width: 500,
          height: 500,
        ),
      );
    }

    if (supabaseSessions.isEmpty) {
      return const Center(child: Text('No sessions found'));
    }

    return ListView.builder(
      itemCount: supabaseSessions.length,
      itemBuilder: (_, index) => _buildSessionTile(
        supabaseSessions[index],
        supabaseSessions.length - index,
      ),
    );
  }
}
