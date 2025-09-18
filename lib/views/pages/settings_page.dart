import 'package:ecg_app/data/classes/notifiers.dart';
import 'package:ecg_app/views/widgets/scaled_text.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});
  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double sliderVal = 0.0;

  String _sizeLabel(double value) {
    switch (value.toInt()) {
      case 1:
        return "Smaller";
      case 2:
        return "Larger";
      case 0:
      default:
        return "Default";
    }
  }

  @override
  void initState() {
    super.initState();
    sliderVal = textSize.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ValueListenableBuilder<double>(
        valueListenable: textSize,
        builder: (context, value, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 25,
                    child: ScaledText(
                      "Adjust font size?",
                      baseSize: 16,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                    child: ScaledText(
                      "Current: ${_sizeLabel(sliderVal)}",
                      baseSize: 16,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(height: 20),
                  Slider.adaptive(
                    max: 2,
                    divisions: 2,
                    value: sliderVal,
                    label: _sizeLabel(sliderVal),
                    onChanged: (double value) {
                      setState(() {
                        sliderVal = value;
                        textSize.value = sliderVal;
                        saveTextSize(sliderVal);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
