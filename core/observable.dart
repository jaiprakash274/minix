// observable.dart

typedef VoidCallback = void Function();

class Observable<T> {
  T _value;
  final Set<VoidCallback> _listeners = {};

  Observable(this._value);

  T get value {
    final currentObserver = ObservableTracker.instance.currentObserver;
    if (currentObserver != null) {
      if (!_listeners.contains(currentObserver)) {
        _listeners.add(currentObserver);
      }
      ObservableTracker.instance._registerDependency(currentObserver, this);
    }
    return _value;
  }


  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      for (final listener in _listeners) {
        try {
          listener();
        } catch (e, stack) {
          // Optional: log the error
          print('Observable listener error: $e\n$stack');
        }
      }
    }
  }


  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void dispose() {
    _listeners.clear();
  }

  T watch() => value;
  T read() => _value;
}

class ObservableTracker {
  static final ObservableTracker instance = ObservableTracker._internal();
  ObservableTracker._internal();

  final Map<VoidCallback, Set<Observable>> _observerDependencies = {};
  VoidCallback? currentObserver;

  void runWithObserver(VoidCallback observer, VoidCallback fn) {
    currentObserver = observer;
    _observerDependencies[observer] = {};
    fn();
    currentObserver = null;
  }

  void _registerDependency(VoidCallback observer, Observable observable) {
    _observerDependencies[observer]?.add(observable);
  }

  void disposeObserver(VoidCallback observer) {
    final observables = _observerDependencies[observer];
    if (observables != null) {
      for (final obs in observables) {
        obs.removeListener(observer);
      }
      _observerDependencies.remove(observer);
    }
  }
}
