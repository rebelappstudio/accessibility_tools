# accessibility_tools

**Checkers and tools to ensure your app is accessible to all.**

Creating an accessible app is incredibly important. But too often it's forgotten about, or left to later. This package ensures your app is accessible from day one, by checking your interface as you build it.

<img width="303" alt='A screenshot showing an icon with two failed accessibility checks: the tooltip reads "Tap area is missing a semantic label" and "Tap area of 40x40 is too small: should be at least 48×48"' src="https://user-images.githubusercontent.com/756862/208949704-1b1f9211-2ae4-428d-a410-b58f03115b6a.png">

To show the issue tooltip, hover over the widget or long-press it.

From [Rebel App Studio][rebel_home]

[![pub](https://img.shields.io/pub/v/accessibility_tools.svg?label=pub.dev&color=blue)](https://pub.dev/packages/accessibility_tools)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![codecov](https://codecov.io/gh/rebelappstudio/accessibility_tools/branch/main/graph/badge.svg?token=GSOA9QVWB8)](https://codecov.io/gh/rebelappstudio/accessibility_tools)

## Getting Started

Add `AccessibilityTools` to your app's `builder` property:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // *** Add the line below ***
      builder: (context, child) => AccessibilityTools(child: child),
      home: HomePage(),
    );
  }
}
```

The tools only run in debug mode, and are compiled out of release builds.

## Current accessibility checkers

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

Experimental: ensures that no flex widgets, such as `Column` and `Row`, overflow when a user is using larger font sizes. This checker is experimental, and disabled by default, and can be enabled via `AccessibilityTools(checkFontOverflows: true)`.

## Configuration

Checkers are enabled or disabled with properties on the `AccessibilityTools` widget:

```dart
AccessibilityTools(
  // Set to null to disable tap area checking
  minTapArea: 50,
  // Check for semantic labels
  checkSemanticLabels: false,
  // Check for flex overflows
  checkFontOverflows: true,
  child: child,
)
```

[rebel_home]: https://rebelappstudio.com/
