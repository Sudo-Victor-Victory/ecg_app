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
  PostgrestList? supabaseSessions = [];

  // Row of ecg_session in supabase
  Map<String, dynamic>? selectedSession;
  // Rows of ecg_data from supabase, all from the same session_id
  List<Map<String, dynamic>>? ecgData;

  String? loadingSessionId;
  @override
  void initState() {
    super.initState();
    getSessionsFromSupabase();
  }

  /// Returns all sessions from Supabase that the user owns.
  void getSessionsFromSupabase() async {
    final receivedSessions = await client
        .from('ecg_session')
        .select("*")
        .order('start_time', ascending: false);

    setState(() => supabaseSessions = receivedSessions);
  }

  /// Assigns returned rows from Supabase to flutter variables & sets
  Future<void> selectSession(Map<String, dynamic> session) async {
    final allRows = await fetchAllEcgRowsFromSession(client, session['id']);
    print("Fetched ${allRows.length} rows for session ${session['id']}");
    print(allRows.length);

    setState(() {
      selectedSession = session;
      ecgData = allRows;
    });
  }

  /// Retrieves all ecg_data rows from supabase based on session_id
  Future<List<Map<String, dynamic>>> fetchAllEcgRowsFromSession(
    SupabaseClient client,
    String sessionId,
  ) async {
    const int pageSize = 1000;
    int from = 0;
    int to = pageSize - 1;
    List<Map<String, dynamic>> allRows = [];

    // Without range & chunking we could not pull the 1000s of ecg_rows from
    // the postgres database.
    while (true) {
      final chunk = await client
          .from('ecg_data')
          .select('*')
          .eq('session_id', sessionId)
          .range(from, to);

      if (chunk.isEmpty) break;

      allRows.addAll(chunk);

      if (chunk.length < pageSize) break; // no more rows

      from += pageSize;
      to += pageSize;
    }

    return allRows;
  }

  /// For idempotentency
  void clearSelection() {
    setState(() {
      selectedSession = null;
      ecgData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedSession != null && ecgData != null) {
      final startTime = DateTime.parse(
        selectedSession!["start_time"],
      ).toLocal();

      final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime);

      return Scaffold(
        appBar: AppBar(
          title: Text("Session $formattedTime"),
          leading: BackButton(onPressed: clearSelection),
        ),
        body: HistoricalChart(ecgRows: ecgData!, startTime: startTime),
      );
    }

    final rows = supabaseSessions?.toList() ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text("Sessions")),
      body: rows.isEmpty
          ? Center(
              child: SizedBox(
                child: Lottie.asset(
                  'assets/lotties/loading.json',
                  fit: BoxFit.cover,
                  height: 350.0,
                  width: 400,
                ),
              ),
            )
          : ListView.builder(
              itemCount: rows.length,
              itemBuilder: (_, index) => _buildSessionTile(rows[index]),
            ),
    );
  }

  Widget _buildSessionTile(Map<String, dynamic> result) {
    final startRaw = result["start_time"];
    final endRaw = result["end_time"];
    // Parse DateTimes (actual DateTime objects) from ecg_session table
    final startDateTime = startRaw != null
        ? DateTime.parse(startRaw).toLocal()
        : null;
    final endDateTime = endRaw != null
        ? DateTime.parse(endRaw).toLocal()
        : null;

    // Format them just for displaying to the user
    final startTime = startDateTime != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(startDateTime)
        : null;
    final endTime = endDateTime != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(endDateTime)
        : null;

    final duration = endDateTime!.difference(startDateTime!);

    final sessionId = result['id'] as String;

    // Stack was chosen to overlay animations ontop of the row
    return Stack(
      children: [
        InkWell(
          onTap: () async {
            setState(() => loadingSessionId = sessionId);
            await selectSession(result);
            setState(() => loadingSessionId = null);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Start: $startTime",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Duration: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')} min",
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "End: $endTime",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.insert_chart),
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
