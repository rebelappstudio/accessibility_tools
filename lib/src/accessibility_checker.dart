import 'dart:math';
import 'dart:ui' as ui;
import 'package:accessibility_checker/src/accessibility_issue.dart';
import 'package:accessibility_checker/src/checker.dart';
import 'package:accessibility_checker/src/checkers/checker_base.dart';
import 'package:accessibility_checker/src/checkers/minimum_tap_area_checker.dart';
import 'package:accessibility_checker/src/checkers/semantic_label_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

const _defaultMinTapArea = 44.0;

/// A checker for debug mode that highlights accessibility issues.
///
/// Issues are highlighted by a red box.
class AccessibilityChecker extends StatefulWidget {
  final Widget child;
  final double? minTapArea;
  final bool checkSemanticLabels;

  const AccessibilityChecker({
    super.key,
    required this.child,
    this.minTapArea = _defaultMinTapArea,
    this.checkSemanticLabels = true,
  });

  @override
  State<AccessibilityChecker> createState() => _AccessibilityCheckerState();
}

class _AccessibilityCheckerState extends State<AccessibilityChecker> {
  late final _checker = IssueChecker(_getCheckers());

  @override
  void dispose() {
    _checker.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AccessibilityChecker oldWidget) {
    _checker.checkers = _getCheckers();
    super.didUpdateWidget(oldWidget);
  }

  List<CheckerBase> _getCheckers() {
    final minTapArea = widget.minTapArea;

    return [
      if (widget.checkSemanticLabels) SemanticLabelChecker(),
      if (minTapArea != null) MinimumTapAreaChecker(minTapArea: minTapArea),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && kDebugMode) {
      return MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Material(
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (_) {
                    return CheckerOverlay(
                      checker: _checker,
                      child: widget.child,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}

class CheckerOverlay extends StatefulWidget {
  final IssueChecker checker;
  final Widget child;

  const CheckerOverlay({
    Key? key,
    required this.checker,
    required this.child,
  }) : super(key: key);

  @override
  State<CheckerOverlay> createState() => _CheckerOverlayState();
}

class _CheckerOverlayState extends State<CheckerOverlay> {
  bool _showOverlays = false;

  static Rect _inflateToMinimumSize(Rect rect) {
    if (rect.shortestSide < _defaultMinTapArea) {
      return Rect.fromCenter(
        center: rect.center,
        width: max(_defaultMinTapArea, rect.width),
        height: max(_defaultMinTapArea, rect.height),
      );
    }

    return rect;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.checker,
      builder: (context, _) {
        final issues = List<AccessibilityIssue>.from(widget.checker.issues);
        final rects = issues.groupListsBy((issue) => issue.rect);

        return Stack(
          children: [
            Positioned.fill(
              child: widget.child,
            ),
            if (_showOverlays)
              for (final entry in rects.entries)
                Positioned.fromRect(
                  rect: _inflateToMinimumSize(entry.key),
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.manual,
                    padding: const EdgeInsets.all(10),
                    message: entry.value.map((e) => e.message).join('\n\n'),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        height: max(5, entry.key.height),
                        width: max(5, entry.key.width),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(150),
                          border: Border.all(
                            color: Colors.yellow,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            if (issues.isNotEmpty)
              Positioned(
                bottom: 15,
                right: 15,
                child: SizedBox(
                  height: 44,
                  width: 44,
                  child: Tooltip(
                    message: '${issues.length} accessibility issues found',
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(
                          () => _showOverlays = !_showOverlays,
                        );
                      },
                      backgroundColor:
                          _showOverlays ? Colors.orange : Colors.red,
                      child: Icon(
                        Icons.warning,
                        size: 25,
                        color: _showOverlays ? Colors.white : Colors.yellow,
                        semanticLabel: _showOverlays
                            ? 'Hide accessibility issues'
                            : 'Show accessibility issues',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
