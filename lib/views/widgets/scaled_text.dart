import 'package:flutter/material.dart';
import 'package:ecg_app/data/classes/notifiers.dart';

class ScaledText extends StatelessWidget {
  final String text;
  final double baseSize;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow; // ← new optional param
  final bool? softWrap; // ← new optional param
  const ScaledText(
    this.text, {
    super.key,
    required this.baseSize,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow, // ← pass in overflow type
    this.softWrap, // ← accept softWrap
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: textSize,
      builder: (context, scale, _) {
        double sizeFactor;
        // smaller
        if (scale == 1) {
          sizeFactor = 0.8;
        }
        // larger
        else if (scale == 2) {
          sizeFactor = 1.2;
        }
        // default at 0
        else {
          sizeFactor = 1.0;
        }

        return Text(
          text,
          maxLines: maxLines,
          softWrap: softWrap ?? true, // ← use passed value, default to true
          textAlign: textAlign,
          overflow: overflow ?? TextOverflow.ellipsis,
          style: (style ?? const TextStyle()).copyWith(
            fontSize: baseSize * sizeFactor,
          ),
        );
      },
    );
  }
}
