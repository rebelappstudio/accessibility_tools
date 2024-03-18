import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:accessibility_tools/src/testing_tools/multi_value_toggle.dart';
import 'package:accessibility_tools/src/testing_tools/slider_toggle.dart';
import 'package:accessibility_tools/src/testing_tools/test_environment.dart';
import 'package:accessibility_tools/src/testing_tools/testing_tools_panel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
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

      expect(find.byIcon(Icons.accessibility_new), findsOneWidget);
      expect(find.byType(TestingToolsPanel), findsNothing);

      await showTestingTools(tester);

      expect(find.byType(TestingToolsPanel), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pump();
      expect(find.byType(TestingToolsPanel), findsNothing);
    },
  );

  testWidgets(
    'Panel disappears when warning boxes are shown',
    (tester) async {
      await tester.pumpWidget(
        const TestApp(
          child: TextField(),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.accessibility_new), findsOneWidget);
      expect(find.byType(TestingToolsPanel), findsNothing);
      expect(find.byType(WarningBox), findsNothing);

      await showTestingTools(tester);

      expect(find.byType(TestingToolsPanel), findsOneWidget);
      expect(find.byType(WarningBox), findsNothing);

      await tester.tap(find.text('Close'));
      await tester.pump();
      expect(find.byType(TestingToolsPanel), findsNothing);

      await showAccessibilityIssues(tester);
      expect(find.byType(TestingToolsPanel), findsNothing);
      expect(find.byType(WarningBox), findsOneWidget);
    },
  );

  testWidgets(
    'Can toggle semantics debugger',
    (tester) async {
      await tester.pumpWidget(
        const TestApp(
          child: SizedBox(),
        ),
      );
      await tester.pump();

      expect(find.byType(SemanticsDebugger), findsNothing);
      await showTestingTools(tester);
      await tester.scrollUntilVisible(find.text('Semantics debugger'), 550);
      await tester.tap(find.text('Semantics debugger'));
      await tester.pump();
      expect(find.byType(SemanticsDebugger), findsOneWidget);

      await tester.tap(find.text('Semantics debugger'));
      await tester.pump();
      expect(find.byType(SemanticsDebugger), findsNothing);
    },
  );

  testWidgets(
    'Can invert colors',
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
      expect(mediaQuery.invertColors, isFalse);

      await showTestingTools(tester);
      await tester.scrollUntilVisible(find.text('Invert colors'), 500);
      await tester.tap(_toggleTile<bool?>('Invert colors', 'On'));
      await tester.pump();
      expect(mediaQuery.invertColors, isTrue);
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

      await showTestingTools(tester);
      await tester.scrollUntilVisible(find.text('Bold text'), 500);
      await tester.tap(_toggleTile<bool?>('Bold text', 'On'));
      await tester.pump();
      expect(mediaQuery.boldText, isTrue);
    },
  );

  testWidgets(
    'Can toggle hight contrast',
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
      expect(mediaQuery.highContrast, isFalse);

      await showTestingTools(tester);
      await tester.scrollUntilVisible(find.text('High contrast'), 500);
      await tester.tap(_toggleTile<bool?>('High contrast', 'On'));
      await tester.pump();
      expect(mediaQuery.highContrast, isTrue);
    },
  );

  testWidgets(
    'Can disable animations',
    (tester) async {
      await tester.pumpWidget(
        const TestApp(
          child: SizedBox(),
        ),
      );
      await tester.pump();
      expect(debugSemanticsDisableAnimations, null);

      await showTestingTools(tester);
      await tester.tap(_toggleTile<bool?>('Disable animations', 'On'));
      await tester.pump();
      expect(debugSemanticsDisableAnimations, isTrue);

      await tester.tap(_toggleTile<bool?>('Disable animations', 'Off'));
      await tester.pump();
      expect(debugSemanticsDisableAnimations, isFalse);

      await tester.tap(_toggleTile<bool?>('Disable animations', 'System'));
      await tester.pump();
      expect(debugSemanticsDisableAnimations, isNull);
    },
  );

  testWidgets(
    'Can change platform brightness',
    (tester) async {
      late MediaQueryData mediaQueryData;
      late ThemeData themeData;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          builder: (context, child) => AccessibilityTools(child: child),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                mediaQueryData = MediaQuery.of(context);
                themeData = Theme.of(context);

                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pump();
      expect(debugBrightnessOverride, null);

      // Switch to dark
      await showTestingTools(tester);
      await tester.tap(_toggleTile<Brightness>('Platform brightness', 'dark'));
      await tester.pumpAndSettle();
      expect(debugBrightnessOverride, Brightness.dark);
      expect(mediaQueryData.platformBrightness, Brightness.dark);
      expect(themeData.brightness, Brightness.dark);

      // Switch to light
      await tester.tap(
        _toggleTile<Brightness>('Platform brightness', 'light'),
      );
      await tester.pumpAndSettle();
      expect(debugBrightnessOverride, Brightness.light);
      expect(mediaQueryData.platformBrightness, Brightness.light);
      expect(themeData.brightness, Brightness.light);

      // Remove override
      await tester.tap(
        _toggleTile<Brightness>('Platform brightness', 'System'),
      );
      await tester.pumpAndSettle();
      expect(debugBrightnessOverride, isNull);
      expect(mediaQueryData.platformBrightness, Brightness.light);
      expect(themeData.brightness, Brightness.light);
    },
  );

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
      await tester.tap(
        _toggleTile<TargetPlatform>('Target platform', 'android'),
      );
      await tester.pump();
      expect(themeData.platform, TargetPlatform.android);

      // Switch to iOS
      await tester.tap(
        _toggleTile<TargetPlatform>('Target platform', 'iOS'),
      );
      await tester.pump();
      expect(themeData.platform, TargetPlatform.iOS);
    },
  );

  testWidgets(
    'Can toggle visual density',
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

      final defaultDensity = themeData.visualDensity;

      await tester.scrollUntilVisible(find.text('Visual density'), 150);

      // Switch to standard
      await tester.tap(
        _toggleTile<VisualDensity>('Visual density', 'standard'),
      );
      await tester.pump();
      expect(themeData.visualDensity, VisualDensity.standard);

      // Switch to comfortable
      await tester.tap(
        _toggleTile<VisualDensity>('Visual density', 'comfortable'),
      );
      await tester.pump();
      expect(themeData.visualDensity, VisualDensity.comfortable);

      // Switch to default value
      await tester.tap(
        _toggleTile<VisualDensity>('Visual density', 'System'),
      );
      await tester.pump();
      expect(themeData.visualDensity, defaultDensity);
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
      await tester.scrollUntilVisible(
        find.textContaining('Text scale factor'),
        150,
      );

      await tester.drag(_slider('Text scale factor'), const Offset(1000, 0));
      await tester.pump();

      expect(mediaQuery.textScaler.scale(1.0), 5.0);

      await tester.tap(_sliderResetButton('Text scale factor'));
      await tester.pump();

      expect(mediaQuery.textScaler.scale(1.0), 1.0);
    },
  );

  testWidgets(
    'Can change device pixel ratio',
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
      final defaultPixelRatio = mediaQuery.devicePixelRatio;
      await showTestingTools(tester);
      await tester.scrollUntilVisible(
        find.textContaining('Device pixel ratio'),
        150,
      );

      await tester.drag(_slider('Device pixel ratio'), const Offset(1000, 0));
      await tester.pump();

      expect(mediaQuery.devicePixelRatio, 6.0);

      await tester.tap(_sliderResetButton('Device pixel ratio'));
      await tester.pump();

      expect(mediaQuery.devicePixelRatio, defaultPixelRatio);
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
        find.textContaining('Locale override'),
        150,
      );

      final tile = find.ancestor(
        of: find.text('Locale override'),
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
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byWidgetPredicate((w) =>
              w is Tooltip &&
              w.message != 'Long tap to toggle testing tools visibility'),
          findsNothing,
        );
      });

      expect(log, isEmpty);
    },
  );

  testWidgets('Can reset all changes', (tester) async {
    late MediaQueryData mediaQueryData;
    late ThemeData themeData;

    await tester.pumpWidget(
      TestApp(
        child: Builder(builder: (context) {
          mediaQueryData = MediaQuery.of(context);
          themeData = Theme.of(context);

          return Container();
        }),
      ),
    );
    await tester.pump();
    final defaultPlatform = themeData.platform;

    await showTestingTools(tester);

    await tester.scrollUntilVisible(find.text('Disable animations'), 150);
    await tester.tap(_toggleTile<bool?>('Disable animations', 'On'));

    await tester.scrollUntilVisible(find.text('Invert colors'), 150);
    await tester.tap(_toggleTile<bool?>('Invert colors', 'On'));

    await tester.scrollUntilVisible(find.text('Target platform'), 150);
    await tester.tap(_toggleTile<TargetPlatform>('Target platform', 'iOS'));

    await tester.pump();

    expect(debugSemanticsDisableAnimations, true);
    expect(mediaQueryData.invertColors, true);
    expect(themeData.platform, TargetPlatform.iOS);

    var env = tester
        .widget<TestingToolsPanel>(find.byType(TestingToolsPanel))
        .environment;
    expect(env, isNot(const TestEnvironment()));

    await tester.tap(find.text('Reset all'));
    await tester.pump();

    expect(debugSemanticsDisableAnimations, null);
    expect(mediaQueryData.invertColors, false);
    expect(themeData.platform, defaultPlatform);

    env = tester
        .widget<TestingToolsPanel>(find.byType(TestingToolsPanel))
        .environment;
    expect(env, const TestEnvironment());
  });
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
    matching: find.byIcon(Icons.replay),
  );
}

class MockLocalizations {
  const MockLocalizations(this.locale);

  final Locale locale;

  static MockLocalizations of(BuildContext context) {
    return Localizations.of<MockLocalizations>(context, MockLocalizations)!;
  }

  String get greetings {
    switch (locale.languageCode.toLowerCase()) {
      case 'fi':
        return 'Moi';
      default:
        return 'Hello';
    }
  }
}

class MockLocalizationsDelegate
    extends LocalizationsDelegate<MockLocalizations> {
  @override
  bool isSupported(Locale locale) =>
      ['fi', 'en'].contains(locale.languageCode.toLowerCase());

  @override
  Future<MockLocalizations> load(Locale locale) =>
      SynchronousFuture<MockLocalizations>(MockLocalizations(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<MockLocalizations> old) {
    return false;
  }
}
