import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
  });

  testWidgets(
    'Shows warning when label is provided as a separate widget',
    (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          child: Column(
            children: [
              const Text('Label'),
              TextField(key: key),
            ],
          ),
        ),
      );

      await showAccessibilityIssues(tester);

      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(key),
        tooltipMessage: 'Text field is missing a label',
      );
    },
  );

  testWidgets('Shows warning when TextField has no hint', (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: TextField(
          key: key,
          decoration: const InputDecoration(hintText: null),
        ),
      ),
    );

    await showAccessibilityIssues(tester);

    expectAccessibilityWarning(
      tester,
      erroredWidgetFinder: find.byKey(key),
      tooltipMessage: 'Text field is missing a label',
    );
  });

  testWidgets("Shows warning when TextField's hint is empty", (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: TextField(
          key: key,
          decoration: const InputDecoration(hintText: ''),
        ),
      ),
    );

    await showAccessibilityIssues(tester);

    expectAccessibilityWarning(
      tester,
      erroredWidgetFinder: find.byKey(key),
      tooltipMessage: 'Text field is missing a label',
    );
  });

  testWidgets(
    "Shows warning when TextFields's hint is blank",
    (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          child: TextField(
            key: key,
            decoration: const InputDecoration(hintText: '   '),
          ),
        ),
      );

      await showAccessibilityIssues(tester);

      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(key),
        tooltipMessage: "Text field's label is blank",
      );
    },
  );

  testWidgets('Shows warning when TextFormField has no hint', (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: TextFormField(
          key: key,
          decoration: const InputDecoration(hintText: null),
        ),
      ),
    );

    await showAccessibilityIssues(tester);

    expectAccessibilityWarning(
      tester,
      erroredWidgetFinder: find.byKey(key),
      tooltipMessage: 'Text field is missing a label',
    );
  });

  testWidgets("Shows warning when TextFormField's hint is empty",
      (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: TextFormField(
          key: key,
          decoration: const InputDecoration(hintText: ''),
        ),
      ),
    );

    await showAccessibilityIssues(tester);

    expectAccessibilityWarning(
      tester,
      erroredWidgetFinder: find.byKey(key),
      tooltipMessage: 'Text field is missing a label',
    );
  });

  testWidgets(
    "Shows warning when TextFormFields's hint is blank",
    (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          child: TextFormField(
            key: key,
            decoration: const InputDecoration(hintText: '   '),
          ),
        ),
      );

      await showAccessibilityIssues(tester);

      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(key),
        tooltipMessage: "Text field's label is blank",
      );
    },
  );

  testWidgets(
    "Shows warning when Autocomplete's hint is blank",
    (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          child: Autocomplete<int>(
            key: key,
            optionsBuilder: (TextEditingValue textEditingValue) => const [],
          ),
        ),
      );

      await showAccessibilityIssues(tester);

      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(key),
        tooltipMessage: 'Text field is missing a label',
      );
    },
  );

  testWidgets(
    "Doesn't show warning when TextField has non-empty hint ",
    (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          child: TextField(
            key: key,
            decoration: const InputDecoration(hintText: 'Hint'),
          ),
        ),
      );

      expect(find.byIcon(Icons.accessibility_new), findsNothing);
      expect(find.byWidgetPredicate((w) => w is Tooltip), findsNothing);
    },
  );

  testWidgets(
    "Doesn't show warning when TextFormField has non-empty hint ",
    (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          child: Form(
            child: TextFormField(
              key: key,
              decoration: const InputDecoration(hintText: 'Hint'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.accessibility_new), findsNothing);
      expect(find.byWidgetPredicate((w) => w is Tooltip), findsNothing);
    },
  );

  testWidgets(
    "Doesn't show warning when TextField has labelText instead of hint",
    (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          child: TextField(
            key: key,
            decoration: const InputDecoration(labelText: 'Label'),
          ),
        ),
      );

      expect(find.byIcon(Icons.accessibility_new), findsNothing);
      expect(find.byWidgetPredicate((w) => w is Tooltip), findsNothing);
    },
  );

  testWidgets(
    "Doesn't show warning when TextField has label widget",
    (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          child: TextField(
            key: key,
            decoration: const InputDecoration(
              label: Text('This is label'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.accessibility_new), findsNothing);
      expect(find.byWidgetPredicate((w) => w is Tooltip), findsNothing);
    },
  );

  testWidgets(
    'Shows warning when TextField has icon label and no text hint',
    (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          child: TextField(
            key: key,
            decoration: const InputDecoration(
              label: Icon(
                Icons.label,
                semanticLabel: null,
              ),
            ),
          ),
        ),
      );

      await showAccessibilityIssues(tester);

      expectAccessibilityWarning(
        tester,
        erroredWidgetFinder: find.byKey(key),
        tooltipMessage: 'Text field is missing a label',
      );
    },
  );

  testWidgets(
    "Doesn't show warning when icon labels has semantic label",
    (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        TestApp(
          child: TextField(
            key: key,
            decoration: const InputDecoration(
              label: Icon(
                Icons.label,
                semanticLabel: 'Icon hint',
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.accessibility_new), findsNothing);
      expect(find.byWidgetPredicate((w) => w is Tooltip), findsNothing);
    },
  );

  testWidgets(
    'Prints console warning for empty hint',
    (WidgetTester tester) async {
      final log = await recordDebugPrint(() async {
        await tester.pumpWidget(
          const TestApp(
            child: TextField(
              decoration: InputDecoration(hintText: null),
            ),
          ),
        );

        await showAccessibilityIssues(tester);
      });

      final expectedLog = '''
==========================
ACCESSIBILITY ISSUES FOUND
==========================

Accessibility issue 1: Text field is missing a label

${getWidgetLocationDescription(tester, find.byType(TextField))}
''';

      expect(log, expectedLog);
    },
  );
}
