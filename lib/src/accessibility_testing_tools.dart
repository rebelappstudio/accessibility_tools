import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AccessibilityTestingTools extends StatefulWidget {
  const AccessibilityTestingTools({
    super.key,
    required this.child,
    required this.onClose,
    required this.menuVisible,
  });

  final Widget child;
  final bool menuVisible;
  final VoidCallback onClose;

  @override
  State<AccessibilityTestingTools> createState() =>
      _AccessibilityTestingToolsState();
}

class _AccessibilityTestingToolsState extends State<AccessibilityTestingTools> {
  double? devicePixelRatio;
  double? textScaleFactor;
  Brightness? platformBrightness;

  bool? highContrast;
  bool? disableAnimations;
  bool? invertColors;
  bool? boldText;

  TargetPlatform? targetPlatform;
  VisualDensity? visualDensity;

  bool semanticsDebuggerEnabled = false;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context).copyWith(
      devicePixelRatio: devicePixelRatio,
      textScaleFactor: textScaleFactor,
      invertColors: invertColors,
      boldText: boldText,
      highContrast: highContrast,
      disableAnimations: disableAnimations,
      platformBrightness: platformBrightness,
    );

    debugSemanticsDisableAnimations = disableAnimations;

    final theme = Theme.of(context).copyWith(
      platform: targetPlatform,
      visualDensity: visualDensity,
    );

    return Stack(
      children: [
        Theme(
          data: theme,
          child: MediaQuery(
            data: mediaQueryData,
            child: semanticsDebuggerEnabled
                ? SemanticsDebugger(child: widget.child)
                : widget.child,
          ),
        ),
        if (widget.menuVisible)
          Positioned.fill(
            child: Material(
              color: Colors.white.withAlpha(240),
              child: ListView(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(
                          Icons.close,
                          semanticLabel: 'Close',
                        ),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Semantics debugger'),
                    value: semanticsDebuggerEnabled,
                    onChanged: (value) {
                      setState(() => semanticsDebuggerEnabled = value);
                    },
                  ),
                  _Toggle(
                    isOn: invertColors,
                    label: 'Invert colors',
                    onTap: (value) {
                      setState(() {
                        invertColors = value;
                      });
                    },
                  ),
                  _Toggle(
                    isOn: boldText,
                    label: 'Bold text',
                    onTap: (value) {
                      setState(() {
                        boldText = value;
                      });
                    },
                  ),
                  _Toggle(
                    isOn: highContrast,
                    label: 'High contrast',
                    onTap: (value) {
                      setState(() {
                        highContrast = value;
                      });
                    },
                  ),
                  _Toggle(
                    isOn: disableAnimations,
                    label: 'Disable animations',
                    onTap: (value) {
                      setState(() {
                        disableAnimations = value;
                      });
                    },
                  ),
                  _BrightnessToggle(
                    value: platformBrightness,
                    onTap: (value) {
                      setState(() {
                        platformBrightness = value;
                      });
                    },
                  ),
                  _MultiValuePlatformToggle(
                    value: targetPlatform,
                    onTap: (value) {
                      setState(() => targetPlatform = value);
                    },
                    label: 'Target platform',
                    values: TargetPlatform.values,
                    nameBuilder: (e) => e?.name ?? 'System',
                  ),
                  _MultiValuePlatformToggle(
                    value: visualDensity,
                    onTap: (value) {
                      setState(() => visualDensity = value);
                    },
                    label: 'Visual density',
                    values: const [
                      VisualDensity.standard,
                      VisualDensity.comfortable,
                      VisualDensity.compact,
                    ],
                    nameBuilder: (e) {
                      if (e == VisualDensity.standard) {
                        return 'standard';
                      } else if (e == VisualDensity.comfortable) {
                        return 'comfortable';
                      } else if (e == VisualDensity.compact) {
                        return 'compact';
                      } else {
                        return 'System';
                      }
                    },
                  ),
                  _Slider(
                    label: 'Text scale',
                    value: textScaleFactor ?? mediaQueryData.textScaleFactor,
                    min: 0.1,
                    max: 5.0,
                    onChanged: (value) {
                      setState(() => textScaleFactor = value);
                    },
                  ),
                  _Slider(
                    label: 'Pixel ratio',
                    value: devicePixelRatio ?? mediaQueryData.devicePixelRatio,
                    min: 1.0,
                    max: 6.0,
                    onChanged: (value) {
                      setState(() => devicePixelRatio = value);
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.isOn,
    required this.onTap,
    required this.label,
  });

  final bool? isOn;
  final void Function(bool? value) onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          const SizedBox.square(dimension: 24),
          SegmentedButton<bool?>(
            showSelectedIcon: false,
            onSelectionChanged: (set) => onTap(set.first),
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('On'),
              ),
              ButtonSegment(
                value: false,
                label: Text('Off'),
              ),
              ButtonSegment(
                value: null,
                label: Text('System'),
              ),
            ],
            selected: {isOn},
          ),
        ],
      ),
    );
  }
}

class _BrightnessToggle extends StatelessWidget {
  const _BrightnessToggle({
    required this.value,
    required this.onTap,
  });

  final Brightness? value;
  final void Function(Brightness? value) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Platform brightness'),
          ),
          const SizedBox.square(dimension: 24),
          SegmentedButton<Brightness?>(
            showSelectedIcon: false,
            onSelectionChanged: (set) => onTap(set.first),
            segments: const [
              ButtonSegment(
                value: Brightness.light,
                label: Text('Light'),
              ),
              ButtonSegment(
                value: Brightness.dark,
                label: Text('Dark'),
              ),
              ButtonSegment(
                value: null,
                label: Text('System'),
              ),
            ],
            selected: {value},
          ),
        ],
      ),
    );
  }
}

class _MultiValuePlatformToggle<T> extends StatelessWidget {
  const _MultiValuePlatformToggle({
    required this.value,
    required this.onTap,
    required this.label,
    required this.values,
    required this.nameBuilder,
  });

  final String label;
  final List<T> values;
  final String Function(T? value) nameBuilder;

  final T? value;
  final void Function(T? value) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          const SizedBox.square(dimension: 24),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: [
                ...values.map((e) {
                  return ChoiceChip(
                    selected: e == value,
                    label: Text(nameBuilder(e)),
                    onSelected: (value) => onTap(e),
                  );
                }),
                ChoiceChip(
                  label: Text(nameBuilder(null)),
                  selected: value == null,
                  onSelected: (value) => onTap(null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final void Function(double? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          const SizedBox.square(dimension: 24),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
          IconButton(
            onPressed: () => onChanged(null),
            icon: const Icon(
              Icons.replay,
              semanticLabel: 'Reset',
            ),
          ),
        ],
      ),
    );
  }
}
