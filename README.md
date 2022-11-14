# accessibility_checker

**Provides useful hints during development to ensure your app remains accessible to all.**

Creating an accessible app is incredibly important. But all too often it's forgotten about, or left to later. This package ensures your app is accessible from day one, by keeping an eye on your interface as you build it.

It only runs in debug mode, and will get compiled out of release builds.

## Getting Started

Add `AccessibilityChecker` to your app widget's builder property:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // *** Add this line ***
      builder: (context, child) => AccessibilityChecker(child: child),
      home: HomePage(),
    );
  }
}
```

## Current checkers

### Semantic label checker

Ensures buttons (and any other tappable widget) have an associated semantic label.

For example, this button is missing a label:

```dart
IconButton(
  onPressed: () => login(),
  icon: Icon(Icons.person),
)
```

Adding a semantic label would fix this: `Icon(Icons.person, semanticLabel: 'Login')`.

### Tap area checker

Makes sure all tappable widgets are large enough to easily tap. Defaults to the Material Design minimum of 48x48.

### Large font overflow checker

Experimental: ensures that no flex widgets, such as `Column` and `Row`, overflow when a user is using larger font sizes. This checker is experimental, and disabled by default, and can be enabled via `AccessibilityChecker(checkFontOverflows: true)`.

## Configuration

Checkers are enabled or disabled with properties on the `AccessibilityChecker` widget:

```dart
AccessibilityChecker(
  // Set to null to disable tap area checking
  minTapArea: 50,
  // Check for semantic labels
  checkSemanticLabels: false,
  // Check for flex overflows
  checkFontOverflows: true,
  child: child,
)
```
