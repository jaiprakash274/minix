import 'package:flutter/widgets.dart';
import 'package:minix/core/observable.dart';

typedef ContextObserverBuilder = Widget Function(BuildContext context);

class ContextObserver extends StatefulWidget {
  final ContextObserverBuilder builder;

  const ContextObserver(this.builder, {super.key});

  @override
  State<ContextObserver> createState() => _ContextObserverState();
}

class _ContextObserverState extends State<ContextObserver> {
  void _onChanged() => setState(() {});

  @override
  void dispose() {
    ObservableTracker.instance.disposeObserver(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final Widget built;

    ObservableTracker.instance.runWithObserver(_onChanged, () {
      try {
        built = widget.builder(context);
      } catch (e, stack) {
        built = ErrorWidget.withDetails(message: 'ContextObserver error: $e');
        debugPrint('ContextObserver build error: $e\n$stack');
      }
    });

    return built;
  }
}
