// import 'package:accessibility_checker/src/accessibility_checker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   testWidgets(
//     'Shows warning for ElevatedButton without semantic label',
//     (WidgetTester tester) async {
//       await tester.pumpWidget(
//         App(
//           child: ElevatedButton(
//             child: const SizedBox(),
//             onPressed: () {},
//           ),
//         ),
//       );
//       await tester.pump(const Duration(seconds: 1));
//       await tester.tap(find.byIcon(Icons.warning));
//       await tester.pump();

//       final tooltip = find.byWidgetPredicate((w) =>
//           w is Tooltip && w.message == 'Tap area is missing semantic label');

//       final container = find
//           .descendant(of: tooltip, matching: find.byType(Container))
//           .evaluate()
//           .single;

//       final box = container.renderObject! as RenderBox;
//       final location = box.localToGlobal(box.size.center(Offset.zero));

//       final tooltips = find.byType(Tooltip).evaluate().toList();
//       expect(tooltips.length, 1);

//       // "Tap area is missing semantic label"

//       // final tooltip = find.byWidgetPredicate((w) => w is Tooltip && w.);
//       // tooltip.size;
//       // tooltip.renderObject;
//       // final widget = tooltip.widget;

//       // print(tooltip);
//     },
//   );

//   testWidgets(
//     'Shows warning for InkWell without semantic label',
//     (WidgetTester tester) async {
//       tester.pumpWidget(
//         App(
//           child: ElevatedButton(
//             child: const SizedBox(),
//             onPressed: () {},
//           ),
//         ),
//       );
//     },
//   );

//   testWidgets(
//     'Shows warning for GestureDetector without semantic label',
//     (WidgetTester tester) async {
//       tester.pumpWidget(
//         App(
//           child: GestureDetector(
//             child: const SizedBox(),
//             onTap: () {},
//           ),
//         ),
//       );
//     },
//   );
// }

// class App extends StatelessWidget {
//   final Widget child;

//   const App({
//     super.key,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AccessibilityChecker(
//       child: MaterialApp(
//         home: Scaffold(
//           body: Center(child: child),
//         ),
//       ),
//     );
//   }
// }
