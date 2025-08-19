import 'package:flutter/material.dart';

import 'info_button.dart';

/// A toggle for selecting a value from a list of values.
class MultiValueToggle<T> extends StatelessWidget {
  /// Default constructor.
  const MultiValueToggle({
    super.key,
    required this.value,
    required this.info,
    required this.onTap,
    required this.title,
    required this.values,
    required this.nameBuilder,
  });

  /// Label of the toggle.
  final String title;

  /// Text to display as a tooltip.
  final String info;

  /// List of values to select from.
  final List<T> values;

  /// Function to build the name of a value.
  final String Function(T? value) nameBuilder;

  /// Currently selected value.
  final T? value;

  /// Callback to call when a value is selected.
  final void Function(T? value) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(width: 8),
            InfoButton(text: info),
          ],
        ),
        const SizedBox.square(dimension: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              showCheckmark: false,
              label: Text(nameBuilder(null)),
              selected: value == null,
              onSelected: (value) => onTap(null),
            ),
            ...values.map((e) {
              return ChoiceChip(
                showCheckmark: false,
                selected: e == value,
                label: Text(nameBuilder(e)),
                onSelected: (_) => onTap(e),
              );
            }),
          ],
        ),
      ],
    );
  }
}
