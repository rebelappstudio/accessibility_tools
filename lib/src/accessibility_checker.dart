import 'dart:math';
import 'dart:ui' as ui;
import 'package:accessibility_checker/src/accessibility_issue.dart';
import 'package:accessibility_checker/src/checker_manager.dart';
import 'package:accessibility_checker/src/checkers/checker_base.dart';
import 'package:accessibility_checker/src/checkers/flex_overflow_checker.dart';
import 'package:accessibility_checker/src/checkers/minimum_tap_area_checker.dart';
import 'package:accessibility_checker/src/checkers/mixin.dart';
import 'package:accessibility_checker/src/checkers/semantic_label_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

const _defaultMinTapArea = 44.0;

/// A checker for debug mode that highlights accessibility issues.
///
/// Issues are highlighted by a red box.
class AccessibilityChecker extends StatefulWidget {
  static TransitionBuilder builder({
    bool checkSemanticLabels = true,
  }) {
    return (context, child) {
      return child != null
          ? AccessibilityChecker(
              checkSemanticLabels: checkSemanticLabels,
              child: child,
            )
          : const SizedBox();
    };
  }

  final Widget? child;
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

class _AccessibilityCheckerState extends State<AccessibilityChecker>
    with SemanticUpdateMixin {
  late CheckerManager _checker = CheckerManager(_getCheckers());

  @override
  void dispose() {
    _checker.dispose();
    super.dispose();
  }

  @override
  void didUpdateSemantics() {
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      // Semantic information are only available at the end of a frame and our
      // only chance to paint them on the screen is the next frame. To achieve
      // this, we call setState() in a post-frame callback.
      if (mounted) {
        _checker.update();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AccessibilityChecker oldWidget) {
    _checker.dispose();
    _checker = CheckerManager(_getCheckers());
    super.didUpdateWidget(oldWidget);
  }

  List<CheckerBase> _getCheckers() {
    final minTapArea = widget.minTapArea;

    return [
      if (widget.checkSemanticLabels) SemanticLabelChecker(),
      if (minTapArea != null) MinimumTapAreaChecker(minTapArea: minTapArea),
      FlexOverflowChecker(textScaleFactor: 5.0),
    ];
  }

  late final _isTest = WidgetsBinding.instance is TestWidgetsFlutterBinding;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || kIsWeb || _isTest) {
      return widget.child!;
    }

    final actualChild = widget.child;
    if (actualChild == null) {
      return const SizedBox();
    }

    Widget child = actualChild;
    for (final checker in _checker.checkers) {
      if (checker is WidgetCheckerBase) {
        child = checker.build(context, child);
      }
    }

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (_) {
              return CheckerOverlay(
                checker: _checker,
                child: child,
              );
            },
          ),
        ],
      ),
    );
  }
}

class CheckerOverlay extends StatefulWidget {
  final CheckerManager checker;
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
  bool showOverlays = false;

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
        final rects =
            issues.groupListsBy((issue) => issue.renderObject.getGlobalRect());

        return Stack(
          children: [
            Positioned.fill(child: widget.child),
            if (showOverlays)
              for (final entry in rects.entries)
                Positioned.fromRect(
                  rect: _inflateToMinimumSize(entry.key),
                  child: Material(
                    child: Tooltip(
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
                ),
            if (issues.isNotEmpty)
              Positioned(
                bottom: 10,
                right: 10,
                child: SafeArea(
                  child: _WarningButton(
                    issues: issues,
                    onPressed: () {
                      setState(() => showOverlays = !showOverlays);
                    },
                    toggled: showOverlays,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _WarningButton extends StatelessWidget {
  final bool toggled;
  final List<AccessibilityIssue> issues;
  final VoidCallback onPressed;

  const _WarningButton({
    Key? key,
    required this.issues,
    required this.onPressed,
    required this.toggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 44,
      child: Tooltip(
        message: issues.length == 1
            ? 'Accessibility issue found'
            : '${issues.length} accessibility issues found',
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: toggled ? Colors.orange : Colors.red,
          child: Icon(
            Icons.warning,
            size: 25,
            color: toggled ? Colors.white : Colors.yellow,
            semanticLabel: toggled
                ? 'Hide accessibility issues'
                : 'Show accessibility issues',
          ),
        ),
      ),
    );
  }
}
