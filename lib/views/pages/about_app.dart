import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecg_app/data/classes/constants.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  void _copyEmail(BuildContext context) {
    Clipboard.setData(
      const ClipboardData(text: 'victor.manuel.rodriguez.cs@gmail.com'),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Email copied to clipboard')));
  }

  void _copyPhone(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: '+1 (323) 381-4466'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone number copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("About Me / Contact"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [KColors.cerulean, KColors.blueGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: KColors.jonquil, width: 3),
                ),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: KColors.jonquil, width: 3),
                  ),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: KColors.jonquil, width: 3),
                    ),
                    child: ClipOval(
                      child: Transform.scale(
                        scale: 2.2, // zoom in
                        child: FractionalTranslation(
                          translation: const Offset(
                            -0.05,
                            0.02,
                          ), // move left/up
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image.asset(
                              'assets/images/Me.jpg',
                              width: 400,
                              height: 400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Victor Rodriguez",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: KColors.cerulean,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Creator of this app & custom ESP32 ECG",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: KColors.blueGreen,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // About Section card with Outline
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: KColors.blueGreen, width: 1.8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "About This Project",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: KColors.blueGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "I'm the one man band that created this app and the custom ESP32-based ECG device it connects to.",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "I built this project because I recently discovered how fascinating biotechnology and biomedical engineering are, "
                        "and I wanted to create something that could help people in need.",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Along the way, I also noticed a lack of documented real-time ECG solutions and its code for practical real-world streaming — "
                        "so I decided to build one myself.",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Contact Section
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: KColors.cerulean, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        "Contact Me",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: KColors.cerulean,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.email,
                              color: KColors.blueGreen,
                            ),
                            title: const Text(
                              "victor.manuel.rodriguez.cs@gmail.com",
                            ),
                            subtitle: const Text("Tap to copy"),
                            onTap: () => _copyEmail(context),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(
                              Icons.phone,
                              color: KColors.jonquil,
                            ),
                            title: const Text("+1 (323) 381-4466"),
                            subtitle: const Text("Tap to copy"),
                            onTap: () => _copyPhone(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Added bottom padding
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
