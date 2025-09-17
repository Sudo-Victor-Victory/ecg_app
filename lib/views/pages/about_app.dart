import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    Clipboard.setData(
      const ClipboardData(
        text: '+1 (323) 381-4466', 
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone number copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: const Text("About Me / Contact"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.teal.shade200,
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              "Victor Rodriguez",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Creator of this app & custom ESP32 ECG",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // About Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "About This Project",
                      style: Theme.of(context).textTheme.titleLarge,
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
                      "Along the way, I also noticed a lack of documented real-time ECG solutions and it's code for practical real-world streaming — "
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
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      "Contact Me",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.email, color: Colors.teal),
                          title: const Text(
                            "victor.manuel.rodriguez.cs@gmail.com",
                          ),
                          subtitle: const Text("Tap to copy"),
                          onTap: () => _copyEmail(context),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.phone, color: Colors.teal),
                          title: const Text("+1 (555) 123-4567"),
                          subtitle: const Text("Tap to copy"),
                          onTap: () => _copyPhone(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
