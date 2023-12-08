import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

mixin SemanticUpdateMixin<T extends StatefulWidget> on State<T> {
  late final List<SemanticsClient> _clients = [];
  late final SemanticsHandle _rootSemanticsHandle;

  @override
  void initState() {
    _rootSemanticsHandle = RendererBinding.instance.ensureSemantics();

    RendererBinding.instance.rootPipelineOwner.visitChildren((child) {
      final client = SemanticsClient(child)..addListener(_update);
      _clients.add(client);
    });

    super.initState();
  }

  @override
  void dispose() {
    _rootSemanticsHandle.dispose();

    for (final client in _clients) {
      client.dispose();
    }

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
    semanticsHandle = pipelineOwner.ensureSemantics(listener: notifyListeners);
  }

  late final SemanticsHandle semanticsHandle;

  @override
  void dispose() {
    semanticsHandle.dispose();
    super.dispose();
  }
}
