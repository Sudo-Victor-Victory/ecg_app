import 'package:ecg_app/views/widgets/historical_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Sessions extends StatefulWidget {
  const Sessions({super.key});

  @override
  State<Sessions> createState() => _SessionsState();
}

class _SessionsState extends State<Sessions> {
  final client = Supabase.instance.client;
  PostgrestList? supabaseSessions = [];

  Map<String, dynamic>? selectedSession;
  List<Map<String, dynamic>>? ecgData;

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

  Future<void> selectSession(Map<String, dynamic> session) async {
    final allRows = await fetchAllEcgRows(client, session['id']);
    print("Fetched ${allRows.length} rows for session ${session['id']}");
    print(allRows.length);

    setState(() {
      selectedSession = session;
      ecgData = allRows;
    });
  }

  Future<List<Map<String, dynamic>>> fetchAllEcgRows(
    SupabaseClient client,
    String sessionId,
  ) async {
    const int pageSize = 1000;
    int from = 0;
    int to = pageSize - 1;
    List<Map<String, dynamic>> allRows = [];

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
      return Scaffold(
        appBar: AppBar(
          title: Text("Session ${startTime.toIso8601String()}"),
          leading: BackButton(onPressed: clearSelection),
        ),
        body: HistoricalChart(ecgRows: ecgData!, startTime: startTime),
      );
    }

    final rows = supabaseSessions?.toList() ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text("Sessions")),
      body: rows.isEmpty
          ? const Center(child: Text("Sorry no data"))
          : ListView.builder(
              itemCount: rows.length,
              itemBuilder: (_, index) => _buildSessionTile(rows[index]),
            ),
    );
  }

  Widget _buildSessionTile(Map<String, dynamic> result) {
    final startRaw = result["start_time"];
    final endRaw = result["end_time"];

    final startTime = startRaw != null
        ? DateTime.parse(startRaw).toLocal()
        : null;
    final endTime = endRaw != null ? DateTime.parse(endRaw).toLocal() : null;

    return InkWell(
      onTap: () => selectSession(result),
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
                  const SizedBox(height: 4),
                  Text(
                    "End: $endTime",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.insert_chart),
          ],
        ),
      ),
    );
  }
}
