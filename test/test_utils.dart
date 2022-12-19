import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> showAccessibilityIssues(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.tap(find.byIcon(Icons.accessibility_new));
  await tester.pump();
}

void expectAccessibilityWarning(
  WidgetTester tester, {
  required Finder finder,
  required String tooltipMessage,
}) {
  final tooltip = find.byWidgetPredicate((w) =>
      w is Tooltip && w.message == 'Tap area is a missing semantic label');

  final warningBox =
      find.descendant(of: tooltip, matching: find.byType(WarningBox)).first;

  final warningBoxPainter =
      find.descendant(of: warningBox, matching: find.byType(CustomPaint)).first;

  final buttonRenderObject = tester.renderObject(finder) as RenderBox;
  final box = tester.renderObject(warningBoxPainter) as RenderBox;

  const borderSize = 5.0;

  expect(
    box.size,
    buttonRenderObject.size + const Offset(borderSize, borderSize),
  );

  final errorBoxPosition = box.localToGlobal(box.size.center(Offset.zero));
  final buttonPosition =
      buttonRenderObject.localToGlobal(box.size.center(Offset.zero));
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
