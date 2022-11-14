import 'package:accessibility_checker/src/accessibility_issue.dart';
import 'package:accessibility_checker/src/checkers/checker_base.dart';
import 'package:accessibility_checker/src/checkers/mixin.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class FlexOverflowChecker extends WidgetCheckerBase {
  final double textScaleFactor;

  FlexOverflowChecker({required this.textScaleFactor});

  @override
  void didUpdateSemantics(List<RenderObject> semanticRenderObjects) {}

  @override
  Widget build(BuildContext context, Widget child) {
    return _FlexOverflowCheckerInjector(
      checker: this,
      child: child,
    );
  }
}

class _FlexOverflowCheckerInjector extends StatefulWidget {
  final Widget child;
  final FlexOverflowChecker checker;

  const _FlexOverflowCheckerInjector({
    required this.child,
    required this.checker,
  });

  @override
  State<_FlexOverflowCheckerInjector> createState() =>
      _FlexOverflowCheckerInjectorState();
}

class _FlexOverflowCheckerInjectorState
    extends State<_FlexOverflowCheckerInjector> with SemanticUpdateMixin {
  @override
  void didUpdateSemantics() {
    _checkForOverflows();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: _textScaleFactor,
          ),
          child: widget.child,
        ),
      ],
    );
  }

  Iterable<DiagnosticsNode> _debugTransformDebugCreator(
    Iterable<DiagnosticsNode> properties,
  ) {
    return properties;
  }

  bool _checkingFontScale = false;
  double _textScaleFactor = 1.0;

  void _checkForOverflows() {
    if (!_checkingFontScale) {
      final issues = <AccessibilityIssue>[];
      _checkingFontScale = true;

      // Replace default Flutter error reporting while checking for overflows
      final defaultOnError = FlutterError.onError;
      FlutterError.onError = (error) {
        if (_isOverflowError(error)) {
          final collector = error.informationCollector?.call();
          final creator = collector
              ?.whereType<DiagnosticsDebugCreator>()
              .firstOrNull
              ?.value;

          if (creator is DebugCreator) {
            final renderObject = creator.element.renderObject;

            if (renderObject != null) {
              issues.add(
                AccessibilityIssue(
                  message:
                      'This RenderFlex will overflow at larger font sizes.',
                  renderObject: renderObject,
                ),
              );
            }
          }
        }
      };

      final transformers = FlutterErrorDetails.propertiesTransformers;
      final removeTransform = transformers.contains(debugTransformDebugCreator);
      if (removeTransform) {
        transformers.remove(debugTransformDebugCreator);
      }
      transformers.add(_debugTransformDebugCreator);

      setState(() {
        _textScaleFactor = 5.0;

        // Schedule a new frame to
        SchedulerBinding.instance.addPostFrameCallback((_) {
          setState(() {
            widget.checker.issues = issues;
            _textScaleFactor = 1.0;

            // Reset error reporting
            FlutterError.onError = defaultOnError;
            if (removeTransform) {
              transformers.add(debugTransformDebugCreator);
            }

            transformers.remove(_debugTransformDebugCreator);
          });
        });
      });
    }
  }

  bool _isOverflowError(FlutterErrorDetails error) {
    final summaryList = error.summary.value;

    if (summaryList is List) {
      final summary = summaryList.firstOrNull;
      if (summary is String &&
          summary.startsWith('A RenderFlex overflowed by')) {
        return true;
      }
    }

    return false;
  }
}
