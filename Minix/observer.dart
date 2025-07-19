import 'package:flutter/widgets.dart';
import 'observable.dart';

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
  void initState() {
    super.initState();
    ObservableTracker.instance.addListener(_onObservableChanged);
  }

  @override
  void dispose() {
    // 🔥 Remove all observables listening to this observer
    ObservableTracker.instance.removeListener(_onObservableChanged);
    ObservableTracker.instance.disposeObserver(_onObservableChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? built;
    ObservableTracker.instance.runWithObserver(_onObservableChanged, () {
      built = widget.builder();
    });
    return built!;
  }
}
