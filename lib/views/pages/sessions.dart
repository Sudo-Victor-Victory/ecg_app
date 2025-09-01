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

  @override
  void initState() {
    super.initState();
    getSessionsFromSupabase();
  }

  /// Returns all sessions from Supabase that the user owns.
  void getSessionsFromSupabase() async {
    var receivedSessions = await client
        .from('ecg_session')
        .select("*")
        .order('start_time', ascending: false);
    for (var row in supabaseSessions!) {
      print(row);
    }
    setState(() {
      supabaseSessions = receivedSessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<PostgrestMap>? idk = supabaseSessions?.toList();
    return Column(
      children: [
        Expanded(
          child: (idk != null && idk.isEmpty)
              ? Center(child: Text("Sorry no data"))
              : ListView.builder(
                  itemCount: idk?.length,
                  itemBuilder: (_, index) => _buildSessionTile(idk![index]),
                ),
        ),
      ],
    );
  }

  /// Temporary tile.
  Widget _buildSessionTile(Map<String, dynamic> result) {
    final startTime = DateTime.parse(result["start_time"]).toLocal();
    final endTime = DateTime.parse(result["end_time"]).toLocal();

    return InkWell(
      onTap: () async {
        print(result["id"]);
        var idkMan = await getEcgData(result["id"]);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return HistoricalChart(ecgRows: idkMan);
            },
          ),
        );
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
                  const SizedBox(height: 4),
                  Text(
                    "End: $endTime",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.bluetooth),
          ],
        ),
      ),
    );
  }

  /// Returns ecg_data rows of which have sessionId in the session_id column
  Future<List<Map<String, dynamic>>> getEcgData(String sessionId) async {
    final allDataFromSession = await client
        .from('ecg_data')
        .select('*')
        .eq('session_id', sessionId);
    return allDataFromSession;
  }
}
