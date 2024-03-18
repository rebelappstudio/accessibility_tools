import 'package:flutter/material.dart';

import 'color_mode_simulation.dart';
import 'multi_value_toggle.dart';
import 'slider_toggle.dart';
import 'switch_toggle.dart';
import 'test_environment.dart';

/// Testing tools panel widget with various toggles and settings. Changing any
/// setting produces a new instance of [TestEnvironment] delivered
/// via [onEnvironmentUpdate]
class TestingToolsPanel extends StatefulWidget {
  const TestingToolsPanel({
    super.key,
    required this.onClose,
    required this.environment,
    required this.onEnvironmentUpdate,
  });

  final TestEnvironment environment;
  final VoidCallback onClose;
  final void Function(TestEnvironment environment) onEnvironmentUpdate;

  @override
  State<TestingToolsPanel> createState() => _TestingToolsPanelState();
}

class _TestingToolsPanelState extends State<TestingToolsPanel> {
  late double? textScaleFactor;

  late bool? boldText;

  late TargetPlatform? targetPlatform;
  late VisualDensity? visualDensity;
  late Locale? localeOverride;
  late TextDirection? textDirection;

  late bool? semanticsDebuggerEnabled;
  late ColorModeSimulation? colorModeSimulation;

  @override
  Widget build(BuildContext context) {
    this.textScaleFactor = widget.environment.textScaleFactor;
    boldText = widget.environment.boldText;
    targetPlatform = widget.environment.targetPlatform;
    visualDensity = widget.environment.visualDensity;
    localeOverride = widget.environment.localeOverride;
    textDirection = widget.environment.textDirection;
    semanticsDebuggerEnabled = widget.environment.semanticsDebuggerEnabled;
    colorModeSimulation = widget.environment.colorModeSimulation;

    final supportedLocales =
        context.findAncestorWidgetOfExactType<WidgetsApp>()?.supportedLocales ??
            const [];
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = this.textScaleFactor != null
        ? TextScaler.linear(this.textScaleFactor!)
        : mediaQuery.textScaler;
    const gap = SizedBox(height: 18);

    return Stack(
      children: [
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: MediaQuery.paddingOf(context),
            child: Column(
              children: [
                _Toolbar(
                  onClose: widget.onClose,
                  onResetAll: () => widget.onEnvironmentUpdate(
                    const TestEnvironment(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SliderTile(
                        label:
                            '''Text scale: ${textScaleFactor.scale(1.0).toStringAsFixed(2)}''',
                        info:
                            '''Change text scaler value to see how layouts behave with different font sizes''',
                        value: textScaleFactor.scale(1.0),
                        min: 0.1,
                        max: 10.0,
                        onChanged: (value) {
                          this.textScaleFactor = value;
                          _notifyTestEnvironmentChanged();
                        },
                      ),
                      gap,
                      if (supportedLocales.isNotEmpty) ...[
                        MultiValueToggle<Locale>(
                          title: 'Localization',
                          info:
                              '''Force a specific locale found in WidgetsApp''',
                          value: localeOverride,
                          onTap: (value) {
                            localeOverride = value;
                            _notifyTestEnvironmentChanged();
                          },
                          values: supportedLocales.toList(),
                          nameBuilder: (locale) {
                            return locale?.toString() ?? 'System';
                          },
                        ),
                      ],
                      gap,
                      MultiValueToggle<TextDirection>(
                        value: textDirection,
                        info: '''Force a specific text direction''',
                        onTap: (value) {
                          textDirection = value;
                          _notifyTestEnvironmentChanged();
                        },
                        title: 'Text direction',
                        values: TextDirection.values.toList(),
                        nameBuilder: (value) =>
                            value?.name.toUpperCase() ?? 'System',
                      ),
                      gap,
                      MultiValueToggle(
                        value: targetPlatform,
                        info:
                            '''Force a specific target platform. This usually changes scrolling behavior, toolbar back button icon, gesture navigation etc''',
                        onTap: (value) {
                          targetPlatform = value;
                          _notifyTestEnvironmentChanged();
                        },
                        title: 'Platform',
                        values: TargetPlatform.values,
                        nameBuilder: (e) => e?.name ?? 'System',
                      ),
                      gap,
                      MultiValueToggle<VisualDensity>(
                        title: 'Density',
                        info:
                            '''Force a specific visual density supported by Flutter. This may change paddings, margins and icons sizes''',
                        value: visualDensity,
                        onTap: (value) {
                          visualDensity = value;
                          _notifyTestEnvironmentChanged();
                        },
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
                      gap,
                      MultiValueToggle<bool?>(
                        value: boldText,
                        title: 'Bold text',
                        info:
                            '''Mimic platform's request to draw texts with a bold font weight''',
                        onTap: (value) {
                          boldText = value;
                          _notifyTestEnvironmentChanged();
                        },
                        values: _onOffSystemValues,
                        nameBuilder: _onOffSystemLabels,
                      ),
                      gap,
                      MultiValueToggle<ColorModeSimulation?>(
                        title: 'Color mode simulation',
                        info:
                            '''Simulate a certain color mode to check contrast and colors accessibility''',
                        value: colorModeSimulation,
                        onTap: (value) {
                          colorModeSimulation = value;
                          _notifyTestEnvironmentChanged();
                        },
                        values: ColorModeSimulation.values,
                        nameBuilder: (e) => e?.name ?? 'Off',
                      ),
                      gap,
                      SwitchToggle(
                        title: 'Screen reader mode',
                        info:
                            '''Use Semantics Debugger to simulate how the app behaves with screen readers''',
                        value: semanticsDebuggerEnabled ?? false,
                        onChanged: (value) {
                          semanticsDebuggerEnabled = value;
                          _notifyTestEnvironmentChanged();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _notifyTestEnvironmentChanged() {
    widget.onEnvironmentUpdate(
      TestEnvironment(
        textScaleFactor: textScaleFactor,
        boldText: boldText,
        targetPlatform: targetPlatform,
        visualDensity: visualDensity,
        localeOverride: localeOverride,
        semanticsDebuggerEnabled: semanticsDebuggerEnabled,
        textDirection: textDirection,
        colorModeSimulation: colorModeSimulation,
      ),
    );
  }
}

const _onOffSystemValues = [true, false];

String _onOffSystemLabels(bool? value) {
  switch (value) {
    case true:
      return 'on';
    case false:
      return 'off';
    case null:
    default:
      return 'System';
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.onClose,
    required this.onResetAll,
  });

  final VoidCallback onClose;
  final VoidCallback onResetAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 8, right: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: onClose,
          ),
          Expanded(
            child: Text(
              'UI settings',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: onResetAll,
            child: const Text('Reset all'),
          ),
        ],
      ),
    );
  }
}
