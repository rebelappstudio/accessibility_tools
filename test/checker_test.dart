import 'package:accessibility_tools/src/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Shows warning for ElevatedButton without semantic label',
    (WidgetTester tester) async {
      AccessibilityTools.debugRunCheckersInTests = true;

      await tester.pumpWidget(
        TestApp(
          child: ElevatedButton(
            child: const SizedBox(),
            onPressed: () {},
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.tap(find.byIcon(Icons.accessibility_new));
      await tester.pump();

      final tooltip = find.byWidgetPredicate((w) =>
          w is Tooltip && w.message == 'Tap area is a missing semantic label');

      final container =
          find.descendant(of: tooltip, matching: find.byType(Container)).first;

      final buttonRenderObject =
          tester.renderObject(find.byType(ElevatedButton)) as RenderBox;
      final box = tester.renderObject(container) as RenderBox;

      // Error box matches button size
      expect(box.size, buttonRenderObject.size);

      // Error box matches button position
      final errorBoxPosition = box.localToGlobal(box.size.center(Offset.zero));
      final buttonPosition =
          buttonRenderObject.localToGlobal(box.size.center(Offset.zero));
      expect(errorBoxPosition, buttonPosition);
    },
  );
}

class TestApp extends StatelessWidget {
  final Widget child;

  const TestApp({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => AccessibilityTools(child: child),
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }
}
