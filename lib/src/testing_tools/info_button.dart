import 'package:flutter/material.dart';

class InfoButton extends StatelessWidget {
  const InfoButton({required this.text, super.key});

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
