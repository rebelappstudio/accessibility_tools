import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:accessibility_tools/src/floating_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    AccessibilityTools.debugRunCheckersInTests = true;
    AccessibilityTools.debugIgnoreTapAreaIssuesInTools = false;
  });

  testWidgets('Shows warning when label is provided as a separate widget', (
    tester,
  ) async {
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
      tooltipMessage: 'Text field is missing a label.',
    );
  });

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
      tooltipMessage: 'Text field is missing a label.',
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
      tooltipMessage: 'Text field is missing a label.',
    );
  });

  testWidgets("Shows warning when TextFields's hint is blank", (tester) async {
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
      tooltipMessage: 'Text field is missing a label.',
    );
  });

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
      tooltipMessage: 'Text field is missing a label.',
    );
  });

  testWidgets("Shows warning when TextFormField's hint is empty", (
    tester,
  ) async {
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
      tooltipMessage: 'Text field is missing a label.',
    );
  });

  testWidgets("Shows warning when TextFormFields's hint is blank", (
    tester,
  ) async {
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
      tooltipMessage: 'Text field is missing a label.',
    );
  });

  testWidgets("Shows warning when Autocomplete's hint is blank", (
    tester,
  ) async {
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
      tooltipMessage: 'Text field is missing a label.',
    );
  });

  testWidgets("Doesn't show warning when TextField has non-empty hint ", (
    tester,
  ) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: TextField(
          key: key,
          decoration: const InputDecoration(hintText: 'Hint'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AccessibilityIssuesToggle), findsNothing);
    expect(find.byType(AccessibilityToolsToggle), findsOneWidget);
  });

  testWidgets("Doesn't show warning when TextFormField has non-empty hint ", (
    tester,
  ) async {
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
    await tester.pumpAndSettle();

    expect(find.byType(AccessibilityIssuesToggle), findsNothing);
  });

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
      await tester.pumpAndSettle();

      expect(find.byType(AccessibilityIssuesToggle), findsNothing);
    },
  );

  testWidgets("Doesn't show warning when TextField has label widget", (
    tester,
  ) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: TextField(
          key: key,
          decoration: const InputDecoration(label: Text('This is label')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AccessibilityIssuesToggle), findsNothing);
  });

  testWidgets('Shows warning when TextField has icon label and no text hint', (
    tester,
  ) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: TextField(
          key: key,
          decoration: const InputDecoration(
            label: Icon(Icons.label, semanticLabel: null),
          ),
        ),
      ),
    );

    await showAccessibilityIssues(tester);

    expectAccessibilityWarning(
      tester,
      erroredWidgetFinder: find.byKey(key),
      tooltipMessage: 'Text field is missing a label.',
    );
  });

  testWidgets("Doesn't show warning when icon labels has semantic label", (
    tester,
  ) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: TextField(
          key: key,
          decoration: const InputDecoration(
            label: Icon(Icons.label, semanticLabel: 'Icon hint'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AccessibilityIssuesToggle), findsNothing);
  });

  testWidgets('Prints console warning for empty hint', (
    WidgetTester tester,
  ) async {
    final log = await recordDebugPrint(() async {
      await tester.pumpWidget(
        const TestApp(
          child: TextField(decoration: InputDecoration(hintText: null)),
        ),
      );

      await showAccessibilityIssues(tester);
    });

    final expectedLog =
        '''
==========================
ACCESSIBILITY ISSUES FOUND
==========================

Accessibility issue 1: Text field is missing a label.

${getWidgetLocationDescription(tester, find.byType(TextField))}
Semantic labels are used by screen readers to enable visually impaired users to
get spoken feedback about the contents of the screen and interact with the UI.

Consider adding a hint or a label to the text field widget. For example:

  TextField(
    inputDecoration: InputDecoration(hint: 'This is hint'),
  )

Read more about screen readers: https://docs.flutter.dev/development/accessibility-and-localization/accessibility?tab=talkback#screen-readers
''';

    expect(log, expectedLog);
  });

  testWidgets('Shows warning for Checkbox', (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: Checkbox(key: key, onChanged: (_) {}, value: false),
      ),
    );

    await showAccessibilityIssues(tester);

    expectAccessibilityWarning(
      tester,
      erroredWidgetFinder: find.byKey(key),
      tooltipMessage: 'Control widget is missing a semantic label.',
    );
  });

  testWidgets("Doesn't show warning for Checkbox with a label", (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: Semantics(
          label: 'Checkbox',
          child: Checkbox(key: key, onChanged: (_) {}, value: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AccessibilityIssuesToggle), findsNothing);
  });

  testWidgets("Doesn't show warning for CheckboxListTile", (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: CheckboxListTile(
          key: key,
          onChanged: (_) {},
          value: false,
          title: const Text('Checkbox'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AccessibilityIssuesToggle), findsNothing);
  });

  testWidgets('Shows warning for Radio', (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: RadioGroup(
          onChanged: (value) {},
          child: Radio(key: key, value: false),
        ),
      ),
    );

    await showAccessibilityIssues(tester);

    expectAccessibilityWarning(
      tester,
      erroredWidgetFinder: find.byKey(key),
      tooltipMessage: 'Control widget is missing a semantic label.',
    );
  });

  testWidgets("Doesn't show warning for RadioListTile", (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: RadioGroup(
          onChanged: (value) {},
          child: RadioListTile(
            key: key,
            value: false,
            title: const Text('Radio'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AccessibilityIssuesToggle), findsNothing);
  });

  testWidgets('Shows warning for Switch', (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: Switch(key: key, onChanged: (_) {}, value: false),
      ),
    );

    await showAccessibilityIssues(tester);

    expectAccessibilityWarning(
      tester,
      erroredWidgetFinder: find.byKey(key),
      tooltipMessage: 'Control widget is missing a semantic label.',
    );
  });

  testWidgets("Doesn't show warning for SwitchListTile", (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: SwitchListTile(
          key: key,
          onChanged: (_) {},
          value: false,
          title: const Text('Switch'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AccessibilityIssuesToggle), findsNothing);
  });

  testWidgets('Shows warning for ToggleButtons with icon', (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      TestApp(
        child: SizedBox(
          child: ToggleButtons(
            isSelected: const [true, false],
            // renderBorder: false,
            borderWidth: 0,
            children: [
              Icon(Icons.sunny, key: key),
              Semantics(label: 'Cloudy', child: const Icon(Icons.cloud)),
            ],
          ),
        ),
      ),
    );

    await showAccessibilityIssues(tester);

    expectAccessibilityWarning(
      tester,
      // ToggleButtons wrap each child in TextButton so warning box is drawn
      // around it
      erroredWidgetFinder: find.ancestor(
        matching: find.byType(TextButton),
        of: find.byIcon(Icons.sunny),
      ),
      tooltipMessage: 'Control widget is missing a semantic label.',
    );
  });
}
