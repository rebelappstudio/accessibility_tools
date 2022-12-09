import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

mixin SemanticUpdateMixin<T extends StatefulWidget> on State<T> {
  late final SemanticsClient client;

  @override
  void initState() {
    client = SemanticsClient(WidgetsBinding.instance.pipelineOwner)
      ..addListener(_update);
    super.initState();
  }

  @override
  void dispose() {
    client.dispose();
    super.dispose();
  }

  void _update() {
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        setState(didUpdateSemantics);
      }
    });
  }

  void didUpdateSemantics();
}

class SemanticsClient extends ChangeNotifier {
  SemanticsClient(PipelineOwner pipelineOwner) {
    semanticsHandle = pipelineOwner.ensureSemantics(
      listener: notifyListeners,
    );
  }
  late final SemanticsHandle semanticsHandle;

  @override
  void dispose() {
    semanticsHandle.dispose();
    super.dispose();
  }
}
