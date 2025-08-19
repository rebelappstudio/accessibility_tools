import 'package:flutter/material.dart';

import 'accessibility_issue.dart';

const _floatingActionButtonSize = 48.0;
const _elevation = 10.0;

/// A toggle for changing visibility of accessibility issues.
class AccessibilityIssuesToggle extends StatelessWidget {
  /// Default constructor.
  const AccessibilityIssuesToggle({
    super.key,
    required this.toggled,
    required this.issues,
    required this.onPressed,
  });

  /// Whether the toggle is on.
  ///
  /// True if issues are highlighted using warning boxes.
  final bool toggled;

  /// The list of accessibility issues.
  final List<AccessibilityIssue> issues;

  /// The callback to call when the toggle is pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final String message;
    final tapToChangeIssuesVisibility = toggled
        ? 'Tap to hide issues'
        : 'Tap to show issues';
    switch (issues.length) {
      case 1:
        message = 'Accessibility issue found\n\n$tapToChangeIssuesVisibility';
      default:
        message =
            '''${issues.length} accessibility issues found\n\n$tapToChangeIssuesVisibility''';
    }

    final double elevation = toggled ? 0 : _elevation;
    final Color backgroundColor = toggled ? Colors.orange : Colors.red;
    final Color foregroundColor = toggled ? Colors.white : Colors.yellow;
    final String semanticLabel = toggled
        ? 'Hide accessibility issues\n'
        : 'Show accessibility issues\n';

    return SizedBox.square(
      dimension: _floatingActionButtonSize,
      child: Tooltip(
        message: message,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          elevation: elevation,
          hoverElevation: elevation,
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          child: Icon(
            Icons.accessibility_new,
            size: 24,
            color: foregroundColor,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}

/// A toggle for opening testing tools.
class AccessibilityToolsToggle extends StatelessWidget {
  /// Default constructor.
  const AccessibilityToolsToggle({
    super.key,
    required this.onToolsButtonPressed,
  });

  /// The callback to call when the toggle is pressed.
  final VoidCallback onToolsButtonPressed;

  @override
  Widget build(BuildContext context) {
    const label = 'Open testing tools';

    return SizedBox.square(
      dimension: _floatingActionButtonSize,
      child: Tooltip(
        message: label,
        child: FloatingActionButton(
          onPressed: onToolsButtonPressed,
          shape: const CircleBorder(),
          elevation: _elevation,
          hoverElevation: _elevation,
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.build,
            size: 24,
            color: Colors.white,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}
