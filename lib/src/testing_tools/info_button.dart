import 'package:flutter/material.dart';

/// An info button that shows a tooltip with a message.
class InfoButton extends StatelessWidget {
  /// Default constructor.
  const InfoButton({required this.text, super.key});

  /// The message to display.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      showDuration: const Duration(seconds: 4),
      message: text,
      triggerMode: TooltipTriggerMode.tap,
      margin: const EdgeInsets.all(8),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(Icons.info_outline),
      ),
    );
  }
}
