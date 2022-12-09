import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'accessibility_issue.dart';
import 'checker_manager.dart';
import 'checkers/checker_base.dart';
import 'checkers/flex_overflow_checker.dart';
import 'checkers/minimum_tap_area_checker.dart';
import 'checkers/mixin.dart';
import 'checkers/semantic_label_checker.dart';

const defaultMinTapArea = 44.0;
const iOSLargestTextScaleFactor = 1.35;

/// A checker for debug mode that highlights accessibility issues.
///
/// Issues are highlighted by a red box.
class AccessibilityTools extends StatefulWidget {
  const AccessibilityTools({
    super.key,
    required this.child,
    this.minTapArea = defaultMinTapArea,
    this.checkSemanticLabels = true,
    this.checkFontOverflows = false,
  });
  @visibleForTesting
  static bool debugRunCheckersInTests = false;

  static TransitionBuilder builder({
    bool checkSemanticLabels = true,
  }) {
    return (context, child) {
      return child != null
          ? AccessibilityTools(
              checkSemanticLabels: checkSemanticLabels,
              child: child,
            )
          : const SizedBox();
    };
  }

  final Widget? child;
  final double? minTapArea;
  final bool checkSemanticLabels;
  final bool checkFontOverflows;

  @override
  State<AccessibilityTools> createState() => _AccessibilityToolsState();
}

class _AccessibilityToolsState extends State<AccessibilityTools>
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
  void didUpdateWidget(covariant AccessibilityTools oldWidget) {
    _checker.dispose();
    _checker = CheckerManager(_getCheckers());
    super.didUpdateWidget(oldWidget);
  }

  List<CheckerBase> _getCheckers() {
    final minTapArea = widget.minTapArea;

    return [
      if (widget.checkSemanticLabels) SemanticLabelChecker(),
      if (minTapArea != null) MinimumTapAreaChecker(minTapArea: minTapArea),
      if (widget.checkFontOverflows)
        FlexOverflowChecker(
          textScaleFactor: iOSLargestTextScaleFactor,
        ),
    ];
  }

  late final _isTest = WidgetsBinding.instance is TestWidgetsFlutterBinding;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode ||
        kIsWeb ||
        (!AccessibilityTools.debugRunCheckersInTests && _isTest)) {
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
  const CheckerOverlay({
    super.key,
    required this.checker,
    required this.child,
  });
  final CheckerManager checker;
  final Widget child;

  @override
  State<CheckerOverlay> createState() => _CheckerOverlayState();
}

class _CheckerOverlayState extends State<CheckerOverlay> {
  bool showOverlays = false;

  static Rect _inflateToMinimumSize(Rect rect) {
    if (rect.shortestSide < defaultMinTapArea) {
      return Rect.fromCenter(
        center: rect.center,
        width: max(defaultMinTapArea, rect.width),
        height: max(defaultMinTapArea, rect.height),
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
        final rects = issues
            .where((element) => element.renderObject.attached)
            .groupListsBy((issue) => issue.renderObject.getGlobalRect());

        return Stack(
          children: [
            Positioned.fill(child: widget.child),
            if (showOverlays)
              for (final entry in rects.entries)
                Positioned.fromRect(
                  rect: _inflateToMinimumSize(entry.key),
                  child: Material(
                    color: Colors.transparent,
                    child: Tooltip(
                      padding: const EdgeInsets.all(10),
                      message: entry.value.map((e) => e.message).join('\n\n'),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
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
  const _WarningButton({
    required this.issues,
    required this.onPressed,
    required this.toggled,
  });
  final bool toggled;
  final List<AccessibilityIssue> issues;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: defaultMinTapArea,
      child: Tooltip(
        message: issues.length == 1
            ? 'Accessibility issue found'
            : '${issues.length} accessibility issues found',
        child: Transform.translate(
          offset: toggled ? const Offset(1, 1) : Offset.zero,
          child: FloatingActionButton(
            elevation: toggled ? 0 : 10,
            hoverElevation: toggled ? 0 : 10,
            onPressed: onPressed,
            backgroundColor: toggled ? Colors.orange : Colors.red,
            child: Icon(
              Icons.accessibility_new,
              size: 25,
              color: toggled ? Colors.white : Colors.yellow,
              semanticLabel: toggled
                  ? 'Hide accessibility issues'
                  : 'Show accessibility issues',
            ),
          ),
        ),
      ),
    );
  }
}
