import 'package:ecg_app/data/classes/constants.dart';
import 'package:ecg_app/views/pages/about_app.dart';
import 'package:ecg_app/views/pages/introduction_screen.dart';
import 'package:ecg_app/views/widgets/ble_recent.dart';
import 'package:ecg_app/views/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:ecg_app/utils/greeting.dart';
import 'package:ecg_app/views/widgets/sessions_widget.dart';
import 'package:ecg_app/views/widgets/animated_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting
            Center(
              child: ScaledText(
                '${greetOnTimeOfDay()} $firstName',
                baseSize: KTextSize.xl,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Recent Sessions row (full width)
            AnimatedCard(
              delay: 100,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: ScaledText(
                          'Recent Sessions',
                          baseSize: KTextSize.lg,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(
                        height: 200,
                        child: SessionsTile(limit: 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recent Devices row (full width)
            AnimatedCard(
              delay: 200,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ScaledText(
                          'Recent Devices',
                          baseSize: KTextSize.lg,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(height: 200, child: RecentDevicesTile()),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Last row → About & Contacts + Instructions. 2 Expandeds share
            // 50/50 row width
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AnimatedCard(
                    delay: 300,
                    child: Card(
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: KColors.blueGreen.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IntroductionScreens(),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: 32,
                                color: KColors.blueGreen,
                              ),
                              const SizedBox(height: 12),
                              ScaledText(
                                "View Instructions",
                                baseSize: KTextSize.sm,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: KColors.blueGreen,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: AnimatedCard(
                    delay: 400,
                    child: Card(
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: KColors.blueGreen.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutAppPage(),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 32,
                                color: KColors.blueGreen,
                              ),
                              const SizedBox(height: 12),
                              ScaledText(
                                "About & Contacts",
                                baseSize: KTextSize.sm,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: KColors.blueGreen,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
