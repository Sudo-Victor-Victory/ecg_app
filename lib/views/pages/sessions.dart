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
    final rows = await client
        .from('ecg_data')
        .select('*')
        .eq('session_id', session['id']);

    setState(() {
      selectedSession = session;
      ecgData = rows;
    });
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
    final startTime = DateTime.parse(result["start_time"]).toLocal();
    final endTime = DateTime.parse(result["end_time"]).toLocal();

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
