import 'package:flutter/material.dart';

import 'info_button.dart';

class SwitchToggle extends StatelessWidget {
  const SwitchToggle({
    super.key,
    required this.title,
    required this.info,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String info;
  final bool value;
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
