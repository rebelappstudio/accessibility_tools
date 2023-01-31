import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TestingToolsWrapper extends StatelessWidget {
  const TestingToolsWrapper({
    super.key,
    required this.environment,
    required this.child,
  });

  final TestEnvironment? environment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context).copyWith(
      devicePixelRatio: environment?.devicePixelRatio,
      textScaleFactor: environment?.textScaleFactor,
      invertColors: environment?.invertColors,
      boldText: environment?.boldText,
      highContrast: environment?.highContrast,
    );

    debugBrightnessOverride = environment?.platformBrightness;
    debugSemanticsDisableAnimations = environment?.disableAnimations;

    /// Let all observers ([WidgetsApp] in particular) know that brightness has
    /// changed. [WidgetsApp] can then decide which theme to use (light to dark
    /// based on platform brightness)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PlatformDispatcher.instance.onPlatformBrightnessChanged?.call();
    });

    final themeData = Theme.of(context).copyWith(
      platform: environment?.targetPlatform,
      visualDensity: environment?.visualDensity,
    );

    final body = Localizations.override(
      context: context,
      locale: environment?.localeOverride,
      child: child,
    );

    return MediaQuery(
      data: mediaQueryData,
      child: Theme(
        data: themeData,
        child: (environment?.semanticsDebuggerEnabled ?? false)
            ? SemanticsDebugger(child: body)
            : body,
      ),
    );
  }
}

class TestingToolsPanel extends StatefulWidget {
  const TestingToolsPanel({
    super.key,
    required this.onClose,
    required this.environment,
    required this.onEnrivonmentUpdate,
    required this.child,
  });

  final Widget child;
  final TestEnvironment environment;
  final VoidCallback onClose;
  final void Function(TestEnvironment environment) onEnrivonmentUpdate;

  @override
  State<TestingToolsPanel> createState() => _AccessibilityTestingToolsState();
}

class _AccessibilityTestingToolsState extends State<TestingToolsPanel> {
  late double? devicePixelRatio = widget.environment.devicePixelRatio;
  late double? textScaleFactor = widget.environment.textScaleFactor;
  late Brightness? platformBrightness = widget.environment.platformBrightness;

  late bool? highContrast = widget.environment.highContrast;
  late bool? disableAnimations = widget.environment.disableAnimations;
  late bool? invertColors = widget.environment.invertColors;
  late bool? boldText = widget.environment.boldText;

  late TargetPlatform? targetPlatform = widget.environment.targetPlatform;
  late VisualDensity? visualDensity = widget.environment.visualDensity;
  late Locale? localeOverride = widget.environment.localeOverride;

  late bool? semanticsDebuggerEnabled =
      widget.environment.semanticsDebuggerEnabled;

  @override
  Widget build(BuildContext context) {
    final supportedLocales =
        context.findAncestorWidgetOfExactType<WidgetsApp>()?.supportedLocales ??
            const [];
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = this.textScaleFactor ?? mediaQuery.textScaleFactor;
    final devicePixelRatio =
        this.devicePixelRatio ?? mediaQuery.devicePixelRatio;

    return Stack(
      children: [
        Material(
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(240),
          child: ListView(
            padding: const EdgeInsets.all(16) +
                MediaQuery.of(context).padding +
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
                value: semanticsDebuggerEnabled ?? false,
                onChanged: (value) {
                  _updateValue(() => semanticsDebuggerEnabled = value);
                },
              ),
              MultiValueToggle<bool?>(
                value: invertColors,
                onTap: (value) {
                  _updateValue(() => invertColors = value);
                },
                label: 'Invert colors',
                values: onOffSystemValues,
                nameBuilder: onOffSystemLabels,
              ),
              MultiValueToggle<bool?>(
                value: boldText,
                label: 'Bold text',
                onTap: (value) {
                  _updateValue(() => boldText = value);
                },
                values: onOffSystemValues,
                nameBuilder: onOffSystemLabels,
              ),
              MultiValueToggle<bool?>(
                value: highContrast,
                label: 'High contrast',
                onTap: (value) {
                  _updateValue(() => highContrast = value);
                },
                values: onOffSystemValues,
                nameBuilder: onOffSystemLabels,
              ),
              MultiValueToggle<bool?>(
                value: disableAnimations,
                label: 'Disable animations',
                onTap: (value) {
                  _updateValue(() => disableAnimations = value);
                },
                values: onOffSystemValues,
                nameBuilder: onOffSystemLabels,
              ),
              MultiValueToggle(
                value: platformBrightness,
                onTap: (value) {
                  _updateValue(() => platformBrightness = value);
                },
                label: 'Platform brightness',
                values: Brightness.values,
                nameBuilder: (value) => value?.name ?? 'System',
              ),
              MultiValueToggle(
                value: targetPlatform,
                onTap: (value) {
                  _updateValue(() => targetPlatform = value);
                },
                label: 'Target platform',
                values: TargetPlatform.values,
                nameBuilder: (e) => e?.name ?? 'System',
              ),
              MultiValueToggle<VisualDensity>(
                value: visualDensity,
                onTap: (value) {
                  _updateValue(() => visualDensity = value);
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
              SliderTile(
                label: '''
Text scale factor ${textScaleFactor.toStringAsFixed(2)}''',
                value: textScaleFactor,
                min: 0.1,
                max: 5.0,
                onChanged: (value) {
                  _updateValue(() => this.textScaleFactor = value);
                },
              ),
              SliderTile(
                label: '''
Device pixel ratio ${devicePixelRatio.toStringAsFixed(2)}''',
                value: devicePixelRatio,
                min: 1.0,
                max: 6.0,
                onChanged: (value) {
                  _updateValue(() => this.devicePixelRatio = value);
                },
              ),
              if (supportedLocales.isNotEmpty) ...[
                MultiValueToggle<Locale>(
                  value: localeOverride,
                  onTap: (value) {
                    _updateValue(() => localeOverride = value);
                  },
                  label: 'Locale override',
                  values: supportedLocales.toList(),
                  nameBuilder: (locale) {
                    return locale?.toString() ?? 'System';
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _updateValue(VoidCallback callback) {
    setState(() {
      callback();
      widget.onEnrivonmentUpdate(
        TestEnvironment(
          devicePixelRatio: devicePixelRatio,
          textScaleFactor: textScaleFactor,
          platformBrightness: platformBrightness,
          highContrast: highContrast,
          disableAnimations: disableAnimations,
          invertColors: invertColors,
          boldText: boldText,
          targetPlatform: targetPlatform,
          visualDensity: visualDensity,
          localeOverride: localeOverride,
          semanticsDebuggerEnabled: semanticsDebuggerEnabled,
        ),
      );
    });
  }
}

@visibleForTesting
class MultiValueToggle<T> extends StatelessWidget {
  const MultiValueToggle({
    super.key,
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
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
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

@visibleForTesting
class SliderTile extends StatelessWidget {
  const SliderTile({
    super.key,
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
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
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

class TestEnvironment {
  const TestEnvironment({
    this.devicePixelRatio,
    this.textScaleFactor,
    this.platformBrightness,
    this.highContrast,
    this.disableAnimations,
    this.invertColors,
    this.boldText,
    this.targetPlatform,
    this.visualDensity,
    this.localeOverride,
    this.semanticsDebuggerEnabled,
  });

  final double? devicePixelRatio;
  final double? textScaleFactor;
  final Brightness? platformBrightness;

  final bool? highContrast;
  final bool? disableAnimations;
  final bool? invertColors;
  final bool? boldText;

  final TargetPlatform? targetPlatform;
  final VisualDensity? visualDensity;
  final Locale? localeOverride;

  final bool? semanticsDebuggerEnabled;
}
