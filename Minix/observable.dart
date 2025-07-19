typedef VoidCallback = void Function();

class Observable<T> {
  T _value;
  final Set<VoidCallback> _listeners = {};

  Observable(this._value);

  T get value {
    final currentObserver = ObservableTracker.instance.currentObserver;
    if (currentObserver != null) {
      _listeners.add(currentObserver);

      // Register this observable for the current observer
      ObservableTracker.instance._registerDependency(currentObserver, this);
    }
    return _value;
  }

  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      for (final listener in _listeners) {
        listener();
      }
      ObservableTracker.instance.notifyListeners();
    }
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
}

class ObservableTracker {
  static final ObservableTracker instance = ObservableTracker._internal();
  ObservableTracker._internal();

  final List<VoidCallback> _globalListeners = [];
  final Map<VoidCallback, Set<Observable<dynamic>>> _dependencies = {};

  VoidCallback? currentObserver;

  void addListener(VoidCallback listener) => _globalListeners.add(listener);
  void removeListener(VoidCallback listener) => _globalListeners.remove(listener);

  void notifyListeners() {
    for (final listener in List<VoidCallback>.from(_globalListeners)) {
      listener();
    }
  }

  void runWithObserver(VoidCallback observer, void Function() fn) {
    // Clean old dependencies before re-building
    _dependencies[observer]?.forEach((obs) => obs.removeListener(observer));
    _dependencies[observer] = {};

    final prev = currentObserver;
    currentObserver = observer;
    fn();
    currentObserver = prev;
  }

  void _registerDependency(VoidCallback observer, Observable<dynamic> observable) {
    _dependencies.putIfAbsent(observer, () => {}).add(observable);
  }

  void disposeObserver(VoidCallback observer) {
    final observables = _dependencies[observer];
    if (observables != null) {
      for (final obs in observables) {
        obs.removeListener(observer);
      }
      _dependencies.remove(observer);
    }
  }
}
