import 'package:ecg_app/views/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecg_app/data/classes/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  int totalSessionTimeMs = 0;
  int totalDataPoints = 0;
  int totalSessions = 0;
  String signupReason = '';

  bool isLoading = true;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _loadProfileStats();
  }

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
    // add a if thing is not null
    setState(() {
      signupReason = profileRes?[KProfileColumns.signUpReason] ?? 'N/A';
      totalSessions = sessions.length;
      totalSessionTimeMs = calculatedSessionTime;
      totalDataPoints = totalPoints;
      isLoading = false;
    });

    _controller.forward();
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours}h ${minutes}m ${seconds}s';
  }

  Widget _buildAnimatedStatCard(
    String title,
    String value,
    IconData icon,
    double start,
  ) {
    final fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, start + 0.3, curve: Curves.easeOut),
    );
    final scale = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, start + 0.3, curve: Curves.easeOutBack),
    );

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: AspectRatio(
          aspectRatio: 1.1, // keeps cards more compact/square
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: KColors.blueGreen.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24, color: KColors.blueGreen),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: KColors.blueGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: KColors.blueGreen.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ScaledText(
                    'Profile & Stats',
                    baseSize: KTextSize.xl,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Signup reason card
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: KColors.blueGreen.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 28,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Signed up because:\n$signupReason',
                              style: const TextStyle(
                                fontSize: 14,
                                color: KColors.blueGreen,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildAnimatedStatCard(
                        'Total Sessions',
                        '$totalSessions',
                        Icons.bar_chart,
                        0.1,
                      ),
                      _buildAnimatedStatCard(
                        'Total Time',
                        _formatDuration(totalSessionTimeMs),
                        Icons.timer,
                        0.2,
                      ),
                      _buildAnimatedStatCard(
                        'Data Points',
                        '$totalDataPoints',
                        Icons.data_usage,
                        0.3,
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsetsGeometry.all(60)),
                ],
              ),
            ),
    );
  }
}
