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
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

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
  late final IssueChecker _checker;
  late final _SemanticsClient _client;

  @override
  void initState() {
    super.initState();
    _client = _SemanticsClient(WidgetsBinding.instance.pipelineOwner)
      ..addListener(_update);
    _checker = IssueChecker(_getCheckers());
  }

  @override
  void dispose() {
    _client
      ..removeListener(_update)
      ..dispose();
    _checker.dispose();

    super.dispose();
  }

  void _update() {
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
      return Directionality(
        textDirection: ui.TextDirection.ltr,
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
            Positioned.fill(child: widget.child),
            if (_showOverlays)
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
                child: _MediaQueryFromWindow(
                  child: SafeArea(
                    child: _WarningButton(
                      issues: issues,
                      onPressed: () {
                        setState(() => _showOverlays = !_showOverlays);
                      },
                      toggled: _showOverlays,
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

class _SemanticsClient extends ChangeNotifier {
  late final SemanticsHandle _semanticsHandle;

  _SemanticsClient(PipelineOwner pipelineOwner) {
    _semanticsHandle = pipelineOwner.ensureSemantics(
      listener: notifyListeners,
    );
  }

  @override
  void dispose() {
    _semanticsHandle.dispose();
    super.dispose();
  }
}

/// Provides a [MediaQuery] which is built and updated using the latest
/// [WidgetsBinding.window] values.
///
/// Receives `window` updates by listening to [WidgetsBinding].
///
/// The standalone widget ensures that it rebuilds **only** [MediaQuery] and
/// its dependents when `window` changes, instead of rebuilding the entire
/// widget tree.
///
/// It is used by [WidgetsApp] if no other [MediaQuery] is available above it.
///
/// See also:
///
///  * [MediaQuery], which establishes a subtree in which media queries resolve
///    to a [MediaQueryData].
class _MediaQueryFromWindow extends StatefulWidget {
  /// Creates a [_MediaQueryFromWindow] that provides a [MediaQuery] to its
  /// descendants using the `window` to keep [MediaQueryData] up to date.
  ///
  /// The [child] must not be null.
  const _MediaQueryFromWindow({
    required this.child,
  });

  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  State<_MediaQueryFromWindow> createState() => _MediaQueryFromWindowState();
}

class _MediaQueryFromWindowState extends State<_MediaQueryFromWindow>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // ACCESSIBILITY

  @override
  void didChangeAccessibilityFeatures() {
    setState(() {
      // The properties of window have changed. We use them in our build
      // function, so we need setState(), but we don't cache anything locally.
    });
  }

  // METRICS

  @override
  void didChangeMetrics() {
    setState(() {
      // The properties of window have changed. We use them in our build
      // function, so we need setState(), but we don't cache anything locally.
    });
  }

  @override
  void didChangeTextScaleFactor() {
    setState(() {
      // The textScaleFactor property of window has changed. We reference
      // window in our build function, so we need to call setState(), but
      // we don't need to cache anything locally.
    });
  }

  // RENDERING
  @override
  void didChangePlatformBrightness() {
    setState(() {
      // The platformBrightness property of window has changed. We reference
      // window in our build function, so we need to call setState(), but
      // we don't need to cache anything locally.
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData data =
        MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    if (!kReleaseMode) {
      data = data.copyWith(platformBrightness: debugBrightnessOverride);
    }
    return MediaQuery(
      data: data,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
