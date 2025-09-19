import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecg_app/data/classes/constants.dart';
import 'package:ecg_app/views/widgets/sessions_widget.dart'; // for fetchSessionsNoLimit

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  int totalSessionTimeMs = 0;
  int totalDataPoints = 0;
  int totalSessions = 0;
  String signupReason = '';

  bool isLoading = true;

  // Retrieves all data relating to the user's data such as total session time
  Future<void> _loadProfileStats() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    //  Fetch user profile
    final profileRes = await supabase
        .from(KTables.userProfile)
        .select(KProfileColumns.signUpReason)
        .eq(KProfileColumns.id, userId)
        .maybeSingle();

    // Fetch all session's start, end and id
    final sessions = await supabase
        .from(KTables.ecgSession)
        .select(
          '${KSessionColumns.startTime}, ${KSessionColumns.endTime}, ${KSessionColumns.id}',
        )
        .eq(KSessionColumns.userId, userId);

    int calculatedSessionTime = 0;
    // Calculate how long a session took and add it to the total
    for (final s in sessions) {
      final start = DateTime.parse(s[KSessionColumns.startTime]);
      final end = DateTime.parse(s[KSessionColumns.endTime]);
      calculatedSessionTime += end.difference(start).inMilliseconds;
    }

    final totalPoints = (calculatedSessionTime / 4).round();

    setState(() {
      signupReason = profileRes?[KProfileColumns.signUpReason] ?? 'N/A';
      totalSessions = sessions.length;
      totalSessionTimeMs = calculatedSessionTime;
      totalDataPoints = totalPoints;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfileStats();
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours}h ${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Stats')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signup Reason: $signupReason',
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Total Sessions: $totalSessions',
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Total Session Time: ${_formatDuration(totalSessionTimeMs)}',
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Total Data Points: $totalDataPoints',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
    );
  }
}
