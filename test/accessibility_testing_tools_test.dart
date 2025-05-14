import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:accessibility_tools/src/floating_action_buttons.dart';
import 'package:accessibility_tools/src/testing_tools/color_mode_simulation.dart';
import 'package:accessibility_tools/src/testing_tools/multi_value_toggle.dart';
import 'package:accessibility_tools/src/testing_tools/slider_toggle.dart';
import 'package:accessibility_tools/src/testing_tools/switch_toggle.dart';
import 'package:accessibility_tools/src/testing_tools/testing_tools_panel.dart';
import 'package:accessibility_tools/src/testing_tools/testing_tools_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
    AccessibilityTools.debugIgnoreTapAreaIssuesInTools = false;
  });

  testWidgets(
    "Can toggle testing panel's visibility",
    (tester) async {
      await tester.pumpWidget(
        const TestApp(
          child: SizedBox(),
        ),
      );
      await tester.pump();

      expect(find.byType(AccessibilityToolsToggle), findsOneWidget);
      expect(find.byType(TestingToolsPanel), findsNothing);

      await showTestingTools(tester);
      expect(find.byType(TestingToolsPanel), findsOneWidget);

      await closeTestingTools(tester);
      expect(find.byType(TestingToolsPanel), findsNothing);
      expect(find.byType(AccessibilityToolsToggle), findsOneWidget);
    },
  );

  testWidgets('Can use bottom close button', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: SizedBox(),
      ),
    );
    await tester.pump();

    expect(find.byType(AccessibilityToolsToggle), findsOneWidget);
    expect(find.byType(TestingToolsPanel), findsNothing);

    await showTestingTools(tester);
    expect(find.byType(TestingToolsPanel), findsOneWidget);

    final closeButton = find.ancestor(
      of: find.text('Close'),
      matching: find.byWidgetPredicate((widget) => widget is ElevatedButton),
    );
    await tester.scrollUntilVisible(closeButton, 150);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    expect(find.byType(TestingToolsPanel), findsNothing);
    expect(find.byType(AccessibilityToolsToggle), findsOneWidget);
  });

  testWidgets('Custom testEnvironment is used as default values',
      (tester) async {
    late MediaQueryData mediaQueryData;
    late ThemeData themeData;
    late TextDirection textDirection;
    late MockLocalizations localizations;

    await tester.pumpWidget(
      TestApp(
        child: Builder(
          builder: (context) {
            mediaQueryData = MediaQuery.of(context);
            themeData = Theme.of(context);
            textDirection = Directionality.of(context);
            localizations = MockLocalizations.of(context);

            return Container();
          },
        ),
      ),
    );
    await tester.pump();
    final defaultPlatform = themeData.platform;

    await showTestingTools(tester);

    final env = tester
        .widget<TestingToolsPanel>(find.byType(TestingToolsPanel))
        .environment;
    expect(
      env,
      equals(const TestEnvironment(visualDensity: VisualDensity.standard)),
    );

    expect(mediaQueryData.textScaler.scale(1.0), 1.0);
    expect(localizations.locale, const Locale('en', 'US'));
    expect(textDirection, TextDirection.ltr);
    expect(themeData.platform, defaultPlatform);
    expect(themeData.visualDensity, VisualDensity.standard);
    expect(mediaQueryData.boldText, isFalse);
    expect(find.byType(ColorModeSimulator), findsNothing);
    expect(find.byType(SemanticsDebugger), findsNothing);
  });

  testWidgets(
    'Warning boxes are hidden when panel is displayed',
    (tester) async {
      await tester.pumpWidget(
        const TestApp(
          child: TextField(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AccessibilityIssuesToggle), findsOneWidget);
      expect(find.byType(AccessibilityToolsToggle), findsOneWidget);
      expect(find.byType(TestingToolsPanel), findsNothing);
      expect(find.byType(WarningBox), findsNothing);

      await showTestingTools(tester);
      expect(find.byType(TestingToolsPanel), findsOneWidget);
      expect(find.byType(WarningBox), findsNothing);

      await closeTestingTools(tester);
      expect(find.byType(TestingToolsPanel), findsNothing);
      expect(find.byType(WarningBox), findsNothing);

      await showAccessibilityIssues(tester);
      expect(find.byType(TestingToolsPanel), findsNothing);
      expect(find.byType(WarningBox), findsOneWidget);
    },
  );

  testWidgets(
    'Can change text scale',
    (tester) async {
      late MediaQueryData mediaQuery;

      await tester.pumpWidget(
        TestApp(
          child: Builder(
            builder: (context) {
              mediaQuery = MediaQuery.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump();
      await showTestingTools(tester);
      await tester.scrollUntilVisible(find.textContaining('Text scale:'), 150);
      await tester.drag(_slider('Text scale:'), const Offset(1000, 0));
      await tester.pump();

      expect(mediaQuery.textScaler.scale(1.0), 10.0);

      await tester.tap(_sliderResetButton('Text scale:'));
      await tester.pump();

      expect(mediaQuery.textScaler.scale(1.0), 1.0);
    },
  );

  testWidgets(
    'Can override locale',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => AccessibilityTools(child: child),
          locale: const Locale('en'),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('fi', 'FI'),
          ],
          localizationsDelegates: [
            MockLocalizationsDelegate(),
          ],
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return Text(MockLocalizations.of(context).greetings);
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await showTestingTools(tester);

      await tester.scrollUntilVisible(
        find.textContaining('Localization'),
        150,
      );

      final tile = find.ancestor(
        of: find.text('Localization'),
        matching: find.byType(MultiValueToggle<Locale>),
      );
      final localeFi = find.descendant(
        of: tile,
        matching: find.text('fi_FI'),
      );
      final localeEn = find.descendant(
        of: tile,
        matching: find.text('en_US'),
      );

      expect(localeFi, findsOneWidget);
      expect(localeEn, findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Moi'), findsNothing);

      await tester.tap(localeFi);
      await tester.pump();
      expect(find.text('Hello'), findsNothing);
      expect(find.text('Moi'), findsOneWidget);
    },
  );

  testWidgets('Can change text direction', (tester) async {
    late TextDirection textDirection;

    await tester.pumpWidget(
      TestApp(
        child: Builder(builder: (context) {
          textDirection = Directionality.of(context);
          return const Text('Hello!');
        }),
      ),
    );
    await tester.pump();
    await showTestingTools(tester);

    expect(textDirection, TextDirection.ltr);

    await tester.scrollUntilVisible(find.text('Text direction'), 150);
    await tester.tap(_toggleTile<TextDirection>('Text direction', 'RTL'));
    await tester.pump();
    expect(textDirection, TextDirection.rtl);

    await tester.tap(_toggleTile<TextDirection>('Text direction', 'LTR'));
    await tester.pump();
    expect(textDirection, TextDirection.ltr);

    await tester.tap(_toggleTile<TextDirection>('Text direction', 'System'));
    await tester.pump();
    expect(textDirection, TextDirection.ltr);
  });

  testWidgets(
    'Can change target platform',
    (tester) async {
      late ThemeData themeData;
      await tester.pumpWidget(
        TestApp(
          child: Builder(
            builder: (context) {
              themeData = Theme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump();
      await showTestingTools(tester);

      // Switch to Android
      await tester.tap(_toggleTile<TargetPlatform>('Platform', 'android'));
      await tester.pump();
      expect(themeData.platform, TargetPlatform.android);

      // Switch to iOS
      await tester.tap(_toggleTile<TargetPlatform>('Platform', 'iOS'));
      await tester.pump();
      expect(themeData.platform, TargetPlatform.iOS);

      // Reset
      await tester.tap(_toggleTile<TargetPlatform>('Platform', 'System'));
      await tester.pump();
      expect(
        find.byWidgetPredicate((widget) =>
            widget is TestingToolsWrapper &&
            widget.environment != null &&
            widget.environment?.targetPlatform == null),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Can toggle visual density',
    (tester) async {
      const itemName = 'Density';
      late ThemeData themeData;
      await tester.pumpWidget(
        TestApp(
          child: Builder(
            builder: (context) {
              themeData = Theme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump();
      await showTestingTools(tester);

      final defaultDensity = themeData.visualDensity;

      await tester.scrollUntilVisible(find.text(itemName), 150);

      // Switch to standard
      await tester.tap(
        _toggleTile<VisualDensity>(itemName, 'standard'),
      );
      await tester.pump();
      expect(themeData.visualDensity, VisualDensity.standard);

      // Switch to comfortable
      await tester.tap(
        _toggleTile<VisualDensity>(itemName, 'comfortable'),
      );
      await tester.pump();
      expect(themeData.visualDensity, VisualDensity.comfortable);

      // Switch to default value
      await tester.tap(
        _toggleTile<VisualDensity>(itemName, 'System'),
      );
      await tester.pump();
      expect(themeData.visualDensity, defaultDensity);
    },
  );

  testWidgets(
    'Can toggle bold text',
    (tester) async {
      late MediaQueryData mediaQuery;

      await tester.pumpWidget(
        TestApp(
          child: Builder(
            builder: (context) {
              mediaQuery = MediaQuery.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump();
      expect(mediaQuery.boldText, isFalse);

      // Turn on
      await showTestingTools(tester);
      await tester.scrollUntilVisible(find.text('Bold text'), 500);
      await tester.tap(_toggleTile<bool?>('Bold text', 'on'));
      await tester.pump();
      expect(mediaQuery.boldText, isTrue);

      // Turn off
      await tester.tap(_toggleTile<bool?>('Bold text', 'off'));
      await tester.pump();
      expect(mediaQuery.boldText, isFalse);

      // Reset
      await tester.tap(_toggleTile<bool?>('Bold text', 'System'));
      await tester.pump();
      expect(
        find.byWidgetPredicate((widget) =>
            widget is TestingToolsWrapper &&
            widget.environment != null &&
            widget.environment?.boldText == null),
        findsOneWidget,
      );
    },
  );

  testWidgets('Can use color mode simulation', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: SizedBox(),
      ),
    );
    await tester.pump();

    expect(find.byType(ColorModeSimulator), findsNothing);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is TestingToolsWrapper &&
          widget.environment?.colorModeSimulation != null),
      findsNothing,
    );

    await showTestingTools(tester);
    await tester.scrollUntilVisible(
      find.descendant(
        of: find.ancestor(
          of: find.text('Color mode simulation'),
          matching: find.byType(MultiValueToggle<ColorModeSimulation?>),
        ),
        matching: find.text('inverted'),
      ),
      50,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      _toggleTile<ColorModeSimulation?>('Color mode simulation', 'inverted'),
    );
    await tester.pumpAndSettle();
    await closeTestingTools(tester);
    await tester.pumpAndSettle();

    expect(find.byType(ColorModeSimulator), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TestingToolsWrapper &&
            widget.environment?.colorModeSimulation ==
                ColorModeSimulation.inverted,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'Can toggle semantics debugger',
    (tester) async {
      const itemName = 'Screen reader mode';
      await tester.pumpWidget(
        const TestApp(
          child: SizedBox(),
        ),
      );
      await tester.pump();

      expect(find.byType(SemanticsDebugger), findsNothing);
      await showTestingTools(tester);
      await tester.scrollUntilVisible(find.text(itemName), 550);

      await _tapSwitchToggle(tester, itemName);
      await tester.pumpAndSettle();
      expect(find.byType(SemanticsDebugger), findsOneWidget);

      await _tapSwitchToggle(tester, itemName);
      await tester.pumpAndSettle();
      expect(find.byType(SemanticsDebugger), findsNothing);
    },
  );

  testWidgets(
    'Testing tool panel has no accessibility issues',
    (tester) async {
      final log = await recordDebugPrint(() async {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => AccessibilityTools(
              // Chip widget has quite small tap area but it's coming from the
              // theme so they're ignored here
              minimumTapAreas: const MinimumTapAreas(mobile: 12, desktop: 12),
              child: child,
            ),
            home: Scaffold(
              body: TestingToolsPanel(
                environment: const TestEnvironment(),
                onClose: () {},
                onEnvironmentUpdate: (_) {},
                onResetAll: () {},
                configuration: const TestingToolsConfiguration(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AccessibilityIssuesToggle), findsNothing);
      });

      expect(log, isEmpty);
    },
  );

  testWidgets('Can reset all changes', (tester) async {
    late MediaQueryData mediaQueryData;
    late ThemeData themeData;
    late TextDirection textDirection;
    late MockLocalizations localizations;

    await tester.pumpWidget(
      TestApp(
        child: Builder(
          builder: (context) {
            mediaQueryData = MediaQuery.of(context);
            themeData = Theme.of(context);
            textDirection = Directionality.of(context);
            localizations = MockLocalizations.of(context);

            return Container();
          },
        ),
      ),
    );
    await tester.pump();
    final defaultPlatform = themeData.platform;

    await showTestingTools(tester);

    await tester.scrollUntilVisible(find.textContaining('Text scale:'), 150);
    await tester.drag(_slider('Text scale:'), const Offset(1000, 0));

    await tester.scrollUntilVisible(find.text('Localization'), 150);
    await tester.tap(_toggleTile<Locale>('Localization', 'fi_FI'));

    await tester.scrollUntilVisible(find.text('Text direction'), 15);
    await tester.tap(_toggleTile<TextDirection>('Text direction', 'RTL'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Platform'), 15);
    await tester.tap(_toggleTile<TargetPlatform>('Platform', 'iOS'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Density'), 15);
    await tester.tap(_toggleTile<VisualDensity>('Density', 'compact'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Bold text'), 15);
    await tester.tap(_toggleTile<bool?>('Bold text', 'on'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Color mode simulation'), 15);
    await tester.tap(
      _toggleTile<ColorModeSimulation?>('Color mode simulation', 'protanopia'),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Screen reader mode'), 15);
    await _tapSwitchToggle(tester, 'Screen reader mode');
    await tester.pumpAndSettle();

    var env = tester
        .widget<TestingToolsPanel>(find.byType(TestingToolsPanel))
        .environment;
    expect(
      env,
      equals(
        const TestEnvironment(
          textScaleFactor: 10.0,
          boldText: true,
          targetPlatform: TargetPlatform.iOS,
          visualDensity: VisualDensity.compact,
          localeOverride: Locale('fi', 'FI'),
          textDirection: TextDirection.rtl,
          semanticsDebuggerEnabled: true,
          colorModeSimulation: ColorModeSimulation.protanopia,
        ),
      ),
    );

    expect(mediaQueryData.textScaler.scale(1.0), 10.0);
    expect(localizations.locale, const Locale('fi', 'FI'));
    expect(textDirection, TextDirection.rtl);
    expect(themeData.platform, TargetPlatform.iOS);
    expect(themeData.visualDensity, VisualDensity.compact);
    expect(mediaQueryData.boldText, isTrue);
    expect(find.byType(ColorModeSimulator), findsOneWidget);
    expect(find.byType(SemanticsDebugger), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Reset all'));
    await tester.pumpAndSettle();

    expect(mediaQueryData.textScaler.scale(1.0), 1.0);
    expect(localizations.locale, const Locale('en', 'US'));
    expect(textDirection, TextDirection.ltr);
    expect(themeData.platform, defaultPlatform);
    expect(themeData.visualDensity, VisualDensity.standard);
    expect(mediaQueryData.boldText, isFalse);
    expect(find.byType(ColorModeSimulator), findsNothing);
    expect(find.byType(SemanticsDebugger), findsNothing);

    env = tester
        .widget<TestingToolsPanel>(find.byType(TestingToolsPanel))
        .environment;
    expect(env, const TestEnvironment(visualDensity: VisualDensity.standard));
  });

  testWidgets(
    'Can move buttons when enableButtonsDrag is true',
    (tester) async {
      await tester.pumpWidget(
        const TestApp(
          enableButtonsDrag: true,
          child: SizedBox(),
        ),
      );
      await tester.pump();

      final buttonFinder = find.byType(AccessibilityToolsToggle);
      final view = tester.viewOf(buttonFinder);
      final deviceSize = view.physicalSize / view.devicePixelRatio;

      expect(buttonFinder, findsOneWidget);

      Offset center() => tester.getCenter(buttonFinder);

      expect(center().dx, greaterThan(deviceSize.width / 2));
      expect(center().dy, greaterThan(deviceSize.height / 2));

      await _pan(tester, buttonFinder, Offset(0, -deviceSize.height));

      expect(center().dx, greaterThan(deviceSize.width / 2));
      expect(center().dy, lessThan(deviceSize.height / 2));

      await _pan(tester, buttonFinder, Offset(-deviceSize.width, 0));

      expect(center().dx, lessThan(deviceSize.width / 2));
      expect(center().dy, lessThan(deviceSize.height / 2));

      await _pan(tester, buttonFinder, Offset(0, deviceSize.height));

      expect(center().dx, lessThan(deviceSize.width / 2));
      expect(center().dy, greaterThan(deviceSize.height / 2));

      await _pan(tester, buttonFinder, Offset(deviceSize.width, 0));

      expect(center().dx, greaterThan(deviceSize.width / 2));
      expect(center().dy, greaterThan(deviceSize.height / 2));
    },
  );

  testWidgets('Default scale configuration', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        enableButtonsDrag: true,
        child: SizedBox(),
      ),
    );
    await tester.pump();
    await showTestingTools(tester);
    const defaultTestingToolsConfiguration = TestingToolsConfiguration();

    final slider = _slider('Text scale:');
    final widget = slider.evaluate().single.widget as Slider;
    expect(widget.min, defaultTestingToolsConfiguration.minTextScale);
    expect(widget.max, defaultTestingToolsConfiguration.maxTextScale);
  });

  testWidgets('Custom scale configuration', (tester) async {
    const customTestingToolsConfiguration = TestingToolsConfiguration(
      minTextScale: 1,
      maxTextScale: 100,
    );
    await tester.pumpWidget(
      const TestApp(
        enableButtonsDrag: true,
        testingToolsConfiguration: customTestingToolsConfiguration,
        child: SizedBox(),
      ),
    );
    await tester.pump();
    await showTestingTools(tester);

    final slider = _slider('Text scale:');
    final widget = slider.evaluate().single.widget as Slider;
    expect(widget.min, customTestingToolsConfiguration.minTextScale);
    expect(widget.max, customTestingToolsConfiguration.maxTextScale);
  });
}

Future<void> _pan(
    WidgetTester tester, Finder buttonFinder, Offset offset) async {
  await tester.fling(
    buttonFinder,
    offset,
    offset.distance * 10,
  );
  await tester.pumpAndSettle();
}

Finder _toggleTile<T>(String tileName, String optionName) {
  final tile = find.ancestor(
    of: find.text(tileName),
    matching: find.byType(MultiValueToggle<T>),
  );
  return find.descendant(
    of: tile,
    matching: find.text(optionName),
  );
}

Future<void> _tapSwitchToggle(WidgetTester tester, String name) async {
  final switchWidget = find.ancestor(
    of: find.text(name),
    matching: find.byType(SwitchToggle),
  );
  final toggleWidget = find.descendant(
    of: switchWidget,
    matching: find.byType(Switch),
  );
  await tester.tap(toggleWidget);
  await tester.pump();
}

Finder _slider(String tileName) {
  final tile = find.ancestor(
    of: find.textContaining(tileName),
    matching: find.byType(SliderTile),
  );
  return find.descendant(
    of: tile,
    matching: find.byType(Slider),
  );
}

Finder _sliderResetButton(String tileName) {
  final tile = find.ancestor(
    of: find.textContaining(tileName),
    matching: find.byType(SliderTile),
  );
  return find.descendant(
    of: tile,
    matching: find.widgetWithText(OutlinedButton, 'Reset'),
  );
}
