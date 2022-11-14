# accessibility_checker

**Provides hints to ensure your app remains accessible to all.**

Creating an accessible app is incredibly important. But too often it's forgotten about, or left to later. This package ensures your app is accessible from day one, by checking your interface as you build it.

<img width="303" alt='A screenshot showing an icon with two failed accessibilty checks: the tooltip reads "Tap area is a missing semantic label" and "Tap area of 40x40 is too small: should be at least 48×48"' src="https://user-images.githubusercontent.com/756862/201646720-c6508f43-2cf9-4a54-a41b-ae7d17b55994.png">

## Getting Started

Add `AccessibilityChecker` to your app's `builder` property:

```dart
class MyApp extends StatelessWidget {
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

The checker only runs in debug mode, and is compiled out of release builds.

## Current checkers

### Semantic label checker

Ensures buttons (and other tappable widgets) have an associated semantic label.

For example, this icon button is missing a label:

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
