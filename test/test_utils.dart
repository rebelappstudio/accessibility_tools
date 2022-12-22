import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => AccessibilityTools(
        checkFontOverflows: true,
        child: child,
      ),
      home: Scaffold(
        body: Center(child: child),
      ),
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

void expectAccessibilityWarning(
  WidgetTester tester, {
  required Finder erroredWidgetFinder,
  required String tooltipMessage,
}) {
  final warningBoxFinder = find.byWidgetPredicate(
    (widget) => widget is WarningBox && widget.message == tooltipMessage,
  );

  expect(warningBoxFinder, findsOneWidget,
      reason: "Couldn't find warning box with tooltip $tooltipMessage");

  // Verify accessibility tooltip
  final warningBox = tester.renderObject(
    find.descendant(
      of: find.byType(WarningBox),
      matching: find.byType(CustomPaint),
    ),
  ) as RenderBox;

  final buttonRenderBox = tester.renderObject<RenderBox>(erroredWidgetFinder);
  const borderSize = 5.0;

  // Verify size of warning box
  expect(
    warningBox.size,
    buttonRenderBox.size + const Offset(borderSize, borderSize),
  );

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

/// Returns the diagnostic location of the widget.
String getWidgetLocationDescription(WidgetTester tester, Finder finder) {
  final debugCreator = tester.element(finder).renderObject!.debugCreator!;
  final diagnosticsNodes =
      debugTransformDebugCreator([DiagnosticsDebugCreator(debugCreator)]);
  return diagnosticsNodes.map((e) => e.toStringDeep()).join('\n');
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
