import 'package:flutter/material.dart';

import 'info_button.dart';

/// A slider to set a value.
class SliderTile extends StatelessWidget {
  /// Default constructor.
  const SliderTile({
    super.key,
    required this.label,
    required this.info,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  /// Label of the slider.
  final String label;

  /// Text to display as a tooltip.
  final String info;

  /// Current value of the slider.
  final double value;

  /// Minimum value of the slider.
  final double min;

  /// Maximum value of the slider.
  final double max;

  /// Callback to call when the value is changed.
  final void Function(double? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final divisions = (max * 10 - min).toInt();

    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
            const SizedBox(width: 8),
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
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
