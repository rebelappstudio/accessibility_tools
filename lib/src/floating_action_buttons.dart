import 'package:flutter/material.dart';

import 'accessibility_issue.dart';

const toolsBoxMinSize = 48.0;
const _elevation = 10.0;

class AccessibilityIssuesToggle extends StatelessWidget {
  const AccessibilityIssuesToggle({
    super.key,
    required this.toggled,
    required this.issues,
    required this.onPressed,
  });

  final bool toggled;
  final List<AccessibilityIssue> issues;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final String message;
    final tapToChangeIssuesVisibility =
        toggled ? 'Tap to hide issues' : 'Tap to show issues';
    switch (issues.length) {
      case 1:
        message = 'Accessibility issue found\n\n$tapToChangeIssuesVisibility';
        break;
      default:
        message =
            '''${issues.length} accessibility issues found\n\n$tapToChangeIssuesVisibility''';
        break;
    }

    final double elevation;
    final Color backgroundColor;
    final Color foregroundColor;
    final String semanticLabel;

    if (issues.isEmpty) {
      elevation = _elevation;
      foregroundColor = Theme.of(context).colorScheme.onSecondary;
      backgroundColor = Theme.of(context).colorScheme.secondary;
      semanticLabel = 'Show accessibility issues\n';
    } else {
      elevation = toggled ? 0 : _elevation;
      foregroundColor = toggled ? Colors.white : Colors.yellow;
      backgroundColor = toggled ? Colors.orange : Colors.red;
      semanticLabel = toggled
          ? 'Hide accessibility issues\n'
          : 'Show accessibility issues\n';
    }

    return SizedBox.square(
      dimension: toolsBoxMinSize,
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

class AccessibilityToolsToggle extends StatelessWidget {
  const AccessibilityToolsToggle({
    super.key,
    required this.onToolsButtonPressed,
  });

  final VoidCallback onToolsButtonPressed;

  @override
  Widget build(BuildContext context) {
    const label = 'Open testing tools';

    return SizedBox.square(
      dimension: toolsBoxMinSize,
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
