import 'package:flutter/material.dart';

import 'info_button.dart';

/// A switch widget to toggle a boolean value.
class SwitchToggle extends StatelessWidget {
  /// Default constructor.
  const SwitchToggle({
    super.key,
    required this.title,
    required this.info,
    required this.value,
    required this.onChanged,
  });

  /// Label of the switch.
  final String title;

  /// Text to display as a tooltip.
  final String info;

  /// Current value of the switch.
  final bool value;

  /// Callback to call when the value is changed.
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              InfoButton(text: info),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
