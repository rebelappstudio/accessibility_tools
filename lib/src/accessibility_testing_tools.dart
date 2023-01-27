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
  Locale? localeOverride;

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

    final supportedLocales =
        context.findAncestorWidgetOfExactType<WidgetsApp>()?.supportedLocales ??
            const [];

    final child = Localizations.override(
      context: context,
      locale: localeOverride,
      child: widget.child,
    );

    return Stack(
      children: [
        Theme(
          data: theme,
          child: MediaQuery(
            data: mediaQueryData,
            child: semanticsDebuggerEnabled
                ? SemanticsDebugger(child: child)
                : child,
          ),
        ),
        if (widget.menuVisible)
          Material(
            color: theme.scaffoldBackgroundColor.withAlpha(240),
            child: ListView(
              padding: const EdgeInsets.all(16) +
                  mediaQueryData.padding +
                  const EdgeInsets.only(bottom: 56),
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
                  subtitle: const Text(
                    '''Useful to understand how an app presents itself to screen readers''',
                  ),
                  value: semanticsDebuggerEnabled,
                  onChanged: (value) {
                    setState(() => semanticsDebuggerEnabled = value);
                  },
                ),
                _MultiValueToggle<bool?>(
                  value: invertColors,
                  onTap: (value) {
                    setState(() {
                      invertColors = value;
                    });
                  },
                  label: 'Invert colors',
                  values: onOffSystemValues,
                  nameBuilder: onOffSystemLabels,
                ),
                _MultiValueToggle<bool?>(
                  value: boldText,
                  label: 'Bold text',
                  onTap: (value) {
                    setState(() {
                      boldText = value;
                    });
                  },
                  values: onOffSystemValues,
                  nameBuilder: onOffSystemLabels,
                ),
                _MultiValueToggle<bool?>(
                  value: highContrast,
                  label: 'High contrast',
                  onTap: (value) {
                    setState(() {
                      highContrast = value;
                    });
                  },
                  values: onOffSystemValues,
                  nameBuilder: onOffSystemLabels,
                ),
                _MultiValueToggle<bool?>(
                  value: disableAnimations,
                  label: 'Disable animations',
                  onTap: (value) {
                    setState(() {
                      disableAnimations = value;
                    });
                  },
                  values: onOffSystemValues,
                  nameBuilder: onOffSystemLabels,
                ),
                _MultiValueToggle(
                  value: platformBrightness,
                  onTap: (value) {
                    setState(() {
                      platformBrightness = value;
                    });
                  },
                  label: 'Platform brightness',
                  values: Brightness.values,
                  nameBuilder: (value) => value?.name ?? 'System',
                ),
                _MultiValueToggle(
                  value: targetPlatform,
                  onTap: (value) {
                    setState(() => targetPlatform = value);
                  },
                  label: 'Target platform',
                  values: TargetPlatform.values,
                  nameBuilder: (e) => e?.name ?? 'System',
                ),
                _MultiValueToggle(
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
                  label: '''
Text scale factor ${mediaQueryData.textScaleFactor.toStringAsFixed(2)}''',
                  value: textScaleFactor ?? mediaQueryData.textScaleFactor,
                  min: 0.1,
                  max: 5.0,
                  onChanged: (value) {
                    setState(() => textScaleFactor = value);
                  },
                ),
                _Slider(
                  label: '''
Device pixel ratio ${mediaQueryData.devicePixelRatio.toStringAsFixed(2)}''',
                  value: devicePixelRatio ?? mediaQueryData.devicePixelRatio,
                  min: 1.0,
                  max: 6.0,
                  onChanged: (value) {
                    setState(() => devicePixelRatio = value);
                  },
                ),
                if (supportedLocales.isNotEmpty) ...[
                  _MultiValueToggle(
                    value: localeOverride,
                    onTap: (value) {
                      setState(() => localeOverride = value);
                    },
                    label: 'Locale override',
                    values: supportedLocales.toList(),
                    nameBuilder: (locale) {
                      return locale?.toString() ?? 'System';
                    },
                  )
                ],
              ],
            ),
          ),
      ],
    );
  }
}

const onOffSystemValues = [true, false];

String onOffSystemLabels(bool? value) {
  switch (value) {
    case true:
      return 'On';
    case false:
      return 'Off';
    case null:
    default:
      return 'System';
  }
}

class _MultiValueToggle<T> extends StatelessWidget {
  const _MultiValueToggle({
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
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
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
