import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
  });

  testWidgets(
    'of returns parent IgnoreMinimumTapAreaSize',
    (WidgetTester tester) async {
      final childKey = GlobalKey();
      await tester.pumpWidget(
        TestApp(
          child: IgnoreMinimumTapAreaSize(
            child: Placeholder(key: childKey),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(() => IgnoreMinimumTapAreaSize.of(childKey.currentContext!),
          returnsNormally);
    },
  );

  testWidgets(
    'maybe of returns parent IgnoreMinimumTapAreaSize if present',
    (WidgetTester tester) async {
      final childKey = GlobalKey();
      await tester.pumpWidget(
        TestApp(
          child: IgnoreMinimumTapAreaSize(
            child: Placeholder(key: childKey),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(IgnoreMinimumTapAreaSize.maybeOf(childKey.currentContext!),
          isNotNull);
    },
  );

  testWidgets(
    'maybe of returns null if there is no IgnoreMinimumTapAreaSize parent',
    (WidgetTester tester) async {
      final childKey = GlobalKey();
      await tester.pumpWidget(
        TestApp(
          child: Placeholder(key: childKey),
        ),
      );

      await tester.pumpAndSettle();

      expect(
          IgnoreMinimumTapAreaSize.maybeOf(childKey.currentContext!), isNull);
    },
  );

  test(
    'updateShouldNotify returns false',
    () {
      const widget1 = IgnoreMinimumTapAreaSize(child: Placeholder());
      const widget2 = IgnoreMinimumTapAreaSize(child: Text(''));

      expect(widget1.updateShouldNotify(widget2), isFalse);
    },
  );
}
