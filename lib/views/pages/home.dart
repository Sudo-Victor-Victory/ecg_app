import 'package:flutter/material.dart';
import 'package:ecg_app/views/widgets/sessions_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.appBarTitle,
    required this.appBarColor,
  });
  final String appBarTitle;
  final Color appBarColor;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final quadrantWidth = constraints.maxWidth / 2 - 8; // spacing
            final quadrantHeight = constraints.maxHeight / 2 - 8;

            return Column(
              children: [
                // Top row
                Row(
                  children: [
                    // Top-left: Recent sessions
                    SizedBox(
                      width: quadrantWidth,
                      height: quadrantHeight,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Center(
                                child: Text(
                                  'Recent Sessions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Expanded(child: SessionsTile(limit: 3)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Top-right placeholder
                    SizedBox(
                      width: quadrantWidth,
                      height: quadrantHeight,
                      child: Card(
                        color: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Text('Top Right')),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bottom row
                Row(
                  children: [
                    SizedBox(
                      width: quadrantWidth,
                      height: quadrantHeight,
                      child: Card(
                        color: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Text('Bottom Left')),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: quadrantWidth,
                      height: quadrantHeight,
                      child: Card(
                        color: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Text('Bottom Right')),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
