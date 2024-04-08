<img width="72" alt="Rebel App Studio logo" src="https://github.com/rebelappstudio/accessibility_tools/assets/20989940/922ccd4c-858d-4d2b-8c3e-2a8adf5af4ba">

# accessibility_tools

**Checkers and tools to ensure your app is accessible to all.**

Creating an accessible app is incredibly important. But too often it's forgotten about, or left to later. This package ensures your app is accessible from day one, by checking your interface as you build it.

<img width="303" alt='A screenshot showing an icon with two failed accessibility checks: the tooltip reads "Tap area is missing a semantic label" and "Tap area of 40x40 is too small: should be at least 48×48"' src="https://user-images.githubusercontent.com/756862/208949704-1b1f9211-2ae4-428d-a410-b58f03115b6a.png">

To show the issue tooltip, hover over the widget or long-press it.

Tap wrench icon to open testing tools panel:

<img width="303" alt="A screenshot of testing tools panel with a list of toggles that developers can use to check how their app works with various settings: text scale, localization, text direction, color mode simulation" src="https://github.com/rebelappstudio/accessibility_tools/assets/20989940/f21aef83-2ec3-4ab9-8ea7-bbfe17595ea6">

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

Makes sure all tappable widgets are large enough to easily tap. Defaults to the [Material Design minimum](https://m3.material.io/foundations/accessible-design/accessibility-basics#28032e45-c598-450c-b355-f9fe737b1cd8) of 48x48 on mobile devices, and 44x44 on desktop devices.

### Large font overflow checker

Experimental: ensures that no flex widgets, such as `Column` and `Row`, overflow when a user is using larger font sizes. This checker is experimental, and disabled by default, and can be enabled via `AccessibilityTools(checkFontOverflows: true)`.

### Input label checker

Makes sure text fields (`TextField`, `TextFormField`, `Autocomplete` etc) and inputs (`Checkbox`, `Radio`, `Switch` etc) have semantic labels.

## Current testing tools toggles

* Text scale. Changes text scale factor, range is 0.1 to 10.0. Does nothing if app ignores text scaling
* Localization. Overrides current selected locale of a `WidgetApp`
* Text direction. Forces text to be displayed according to the selected values (right-to-left or left-to-right)
* Platform. Changes current `TargetPlatform`. This may change scrolling behavior, back button icon, gesture navigation etc
* Density. Changes app's visual density. This may change padding of some widgets (e.g. `ListTile`)
* Bold text. Simulates operating system's request to make text bolder
* Color mode simulation. Simulates a color mode. Supported modes: protanopia, deuteranopia, tritanopia, inverted colors, grayscale
* Screen reader mode. Enables semantics debugger to simulate how app is seen by screen readers

## Configuration

Checkers are enabled or disabled with properties on the `AccessibilityTools` widget:

```dart
AccessibilityTools(
  // Set to null to disable tap area checking
  minimumTapAreas: MinimumTapAreas.material,
  // Check for semantic labels
  checkSemanticLabels: false,
  // Check for flex overflows
  checkFontOverflows: true,
  // Set how much info about issues is printed
  logLevel: LogLevel.verbose,
  child: child,
)
```

[rebel_home]: https://rebelappstudio.com/
