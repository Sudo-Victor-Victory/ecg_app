import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecg_app/views/widgets/sessions_widget.dart';

class Sessions extends StatefulWidget {
  const Sessions({super.key});

  @override
  State<Sessions> createState() => _SessionsState();
}

class _SessionsState extends State<Sessions> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> supabaseSessions = [];
  bool isLoadingSessions = true;

  @override
  void initState() {
    super.initState();
    fetchSessionsNoLimit();
  }

  /// Returns all sessions from Supabase that the user owns.
  Future<void> fetchSessionsNoLimit() async {
    final data = await supabase
        .from('ecg_session')
        .select('*')
        .order('start_time', ascending: false);

    setState(() {
      supabaseSessions = List<Map<String, dynamic>>.from(data);
      isLoadingSessions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoadingSessions
          ? Center(
              child: Lottie.asset('assets/lotties/loading.json', width: 100),
            )
          : SessionsTile(
              limit: null, // show all sessions
            ),
    );
  }
}
