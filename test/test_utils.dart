import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:accessibility_tools/src/accessibility_tools.dart';
import 'package:accessibility_tools/src/floating_action_buttons.dart';
import 'package:accessibility_tools/src/testing_tools/testing_tools_panel.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    required this.child,
    this.minimumTapAreas = MinimumTapAreas.material,
    this.logLevel = LogLevel.verbose,
    this.enableButtonsDrag = false,
    this.testingToolsConfiguration = const TestingToolsConfiguration(),
  });

  final Widget child;
  final MinimumTapAreas? minimumTapAreas;
  final LogLevel logLevel;
  final bool enableButtonsDrag;
  final TestingToolsConfiguration testingToolsConfiguration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const [Locale('en', 'US'), Locale('fi', 'FI')],
      localizationsDelegates: [MockLocalizationsDelegate()],
      builder: (context, child) {
        return AccessibilityTools(
          checkFontOverflows: true,
          checkImageLabels: true,
          minimumTapAreas: minimumTapAreas,
          enableButtonsDrag: enableButtonsDrag,
          logLevel: logLevel,
          testingToolsConfiguration: testingToolsConfiguration,
          testEnvironment: const TestEnvironment(
            visualDensity: VisualDensity.standard,
          ),
          child: child,
        );
      },
      home: Scaffold(body: Center(child: child)),
    );
  }
}

Future<void> showAccessibilityIssues(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump();
  await tester.tap(find.byIcon(Icons.accessibility_new));
  await tester.pump();
}

Future<void> showTestingTools(WidgetTester tester) async {
  await tester.pump();
  await tester.tap(find.byType(AccessibilityToolsToggle));
  await tester.pump();
}

Future<void> closeTestingTools(WidgetTester tester) async {
  await tester.pump();
  await tester.tap(
    find.descendant(
      of: find.byType(Toolbar),
      matching: find.byIcon(Icons.close),
    ),
  );
  await tester.pump();
}

void expectAccessibilityWarning(
  WidgetTester tester, {
  required Finder erroredWidgetFinder,
  required String tooltipMessage,
}) {
  final warningBoxFinder = find.byWidgetPredicate(
    (widget) => widget is WarningBox && widget.message == tooltipMessage,
  );

  expect(
    warningBoxFinder,
    findsOneWidget,
    reason:
        '''
Couldn't find warning box with tooltip '$tooltipMessage'.
          
${debugWarningBoxesText(tester)}''',
  );

  // Verify accessibility tooltip
  final warningBox = tester.renderObject(
    find.descendant(of: warningBoxFinder, matching: find.byType(CustomPaint)),
  ) as RenderBox;

  final buttonRenderBox = tester.renderObject<RenderBox>(erroredWidgetFinder);
  const borderSize = 5.0;

  // Verify size of warning box
  const delta = Offset(0.001, 0.001);
  final buttonBox = buttonRenderBox.size + const Offset(borderSize, borderSize);
  final sizeDiff = warningBox.size - buttonBox;
  expect(sizeDiff, lessThan(delta));

  final errorBoxPosition = warningBox.localToGlobal(
    warningBox.size.center(Offset.zero),
  );

  final buttonPosition = buttonRenderBox.localToGlobal(
    warningBox.size.center(Offset.zero),
  );

  expect(
    errorBoxPosition,
    buttonPosition - const Offset(borderSize / 2, borderSize / 2),
  );
}

/// Utility to debug failing tests which gets the text of all warning boxes.
String debugWarningBoxesText(WidgetTester tester) {
  final warningBoxes = tester.widgetList<WarningBox>(find.byType(WarningBox));

  return '''
Found ${warningBoxes.length} warning boxes:

${warningBoxes.mapIndexed((i, warningBox) {
    return "  * Error ${i + 1}: '${warningBox.message}'";
  }).join('\n')}
  ''';
}

/// Returns the diagnostic location of the widget.
String getWidgetLocationDescription(WidgetTester tester, Finder finder) {
  final debugCreator = tester.element(finder).renderObject!.debugCreator!;
  final diagnosticsNodes = debugTransformDebugCreator([
    DiagnosticsDebugCreator(debugCreator),
  ]);
  return diagnosticsNodes.map((e) => e.toStringDeep()).join('\n');
}

/// Returns the diagnostic location of the [RenderObject] that owns a matching
/// [SemanticsNode] under [finder].
///
/// Accessibility checkers log the creator of that render object (for example
/// an inner `Semantics` in [TextField]), which can differ from the creator of
/// [finder]'s element render object.
String getSemanticsCreatorLocationDescription(
  WidgetTester tester,
  Finder finder,
  bool Function(SemanticsData data) matches,
) {
  RenderObject? target;
  void visit(Element element) {
    if (target != null) return;
    final renderObject = element.renderObject;
    final node = renderObject?.debugSemantics;
    if (node != null &&
        !node.isMergedIntoParent &&
        !node.isInvisible &&
        !node.flagsCollection.isHidden) {
      final data = node.getSemanticsData();
      if (matches(data)) {
        target = renderObject;
        return;
      }
    }
    element.visitChildren(visit);
  }

  visit(tester.element(finder));
  assert(target != null, 'No matching SemanticsNode found under $finder');

  final debugCreator = target!.debugCreator!;
  final diagnosticsNodes = debugTransformDebugCreator([
    DiagnosticsDebugCreator(debugCreator),
  ]);
  return diagnosticsNodes.map((e) => e.toStringDeep()).join('\n');
}

/// Convenience for TextField console-log expectations.
String getTextFieldLocationDescription(WidgetTester tester) {
  return getSemanticsCreatorLocationDescription(
    tester,
    find.byType(TextField),
    (data) => data.flagsCollection.isTextField,
  );
}

/// Records the output of [debugPrint] during the execution of [callback].
Future<String> recordDebugPrint(Future<void> Function() callback) async {
  final logBuffer = StringBuffer();
  final originalDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    logBuffer.writeln(message);
  };

  await callback();

  debugPrint = originalDebugPrint;
  return logBuffer.toString();
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
