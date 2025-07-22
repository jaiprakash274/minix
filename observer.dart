import 'package:flutter/widgets.dart';
import 'package:minix/core/observable.dart';

typedef ObserverBuilder = Widget Function();

class Observer extends StatefulWidget {
  final ObserverBuilder builder;

  const Observer(this.builder, {super.key});

  @override
  State<Observer> createState() => _ObserverState();
}

class _ObserverState extends State<Observer> {
  void _onObservableChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    ObservableTracker.instance.disposeObserver(_onObservableChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final Widget built;

    ObservableTracker.instance.runWithObserver(_onObservableChanged, () {
      try {
        built = widget.builder();
      } catch (e, stack) {
        built = ErrorWidget.withDetails(message: 'Observer build error: $e');
        debugPrint('Observer build error: $e\n$stack');
      }
    });

    return built;
  }
}
