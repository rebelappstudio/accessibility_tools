import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:example/app_localizations.dart';
import 'package:example/home_page.dart';
import 'package:example/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        // Add AccessibilityTools to the widget tree. The tools are available
        // only in debug mode
        return AccessibilityTools(
          checkFontOverflows: true,
          child: child,
        );
      },
      home: const MyHomePage(),
      theme: lightTheme,
      darkTheme: darkTheme,
      localizationsDelegates: localizationDelegates,
      supportedLocales: supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
