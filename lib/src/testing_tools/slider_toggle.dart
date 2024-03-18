import 'package:flutter/material.dart';

import 'info_button.dart';

class SliderTile extends StatelessWidget {
  const SliderTile({
    super.key,
    required this.label,
    required this.info,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String info;

  final double value;
  final double min;
  final double max;
  final void Function(double? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TODO editable value
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InfoButton(text: info),
                ],
              ),
            ),
            const SizedBox(height: 4),
            OutlinedButton(
              onPressed: () => onChanged(null),
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox.square(dimension: 4),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
