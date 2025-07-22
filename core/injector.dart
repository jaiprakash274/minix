import 'package:minix/core/injectable.dart';

typedef InjectorHook = void Function(String event, Type type);

class Injector {
  // --- Storage ---
  static final Map<Type, dynamic> _instances = {};
  static final Map<Type, dynamic Function()> _factories = {};
  static final Set<Type> _autoDispose = {};
  static final Map<String, Set<Type>> _scopedInstances = {};
  static final Map<String, dynamic> _taggedInstances = {};

  // --- Debugging ---
  static bool enableLogs = false;
  static InjectorHook? onEvent;

  static void _log(String message) {
    // ignore: avoid_print
    if (enableLogs) print('[minix] $message');
  }

  static void _notify(String event, Type type) {
    _log('$event<$type>()');
    if (onEvent != null) onEvent!(event, type);
  }

  // --- Core Registration ---
  static T put<T>(T instance) {
    _instances[T] = instance;
    if (instance is Injectable) instance.onInit();
    _notify('put', T);
    return instance;
  }

  static void lazyPut<T>(T Function() builder) {
    _factories[T] = builder;
    _notify('lazyPut', T);
  }

  static Future<void> putAsync<T>(Future<T> Function() builder) async {
    final instance = await builder();
    put<T>(instance);
    _notify('putAsync', T);
  }

  static T find<T>() {
    if (_instances.containsKey(T)) {
      _notify('find', T);
      return _instances[T] as T;
    } else if (_factories.containsKey(T)) {
      final instance = _factories[T]!();
      return put<T>(instance);
    } else {
      throw Exception("No instance of $T found.");
    }
  }

  static T? getOrNull<T>() {
    if (_instances.containsKey(T)) return _instances[T] as T;
    if (_factories.containsKey(T)) {
      final instance = _factories[T]!();
      return put<T>(instance);
    }
    return null;
  }

  static bool isRegistered<T>() {
    return _instances.containsKey(T) || _factories.containsKey(T);
  }

  static void delete<T>() {
    final instance = _instances.remove(T);
    _factories.remove(T);
    _autoDispose.remove(T);
    if (instance is Injectable) instance.onDispose();
    _notify('delete', T);
  }

  // --- Auto Dispose ---
  static void autoDisposePut<T>(T instance) {
    _instances[T] = instance;
    _autoDispose.add(T);
    if (instance is Injectable) instance.onInit();
    _notify('autoDisposePut', T);
  }

  static void disposeAll() {
    for (var type in _autoDispose) {
      final instance = _instances.remove(type);
      if (instance is Injectable) instance.onDispose();
      _notify('disposeAuto', type);
    }
    _autoDispose.clear();
  }

  // --- Scope Support ---
  static void putScoped<T>(T instance, String scope) {
    _instances[T] = instance;
    (_scopedInstances[scope] ??= {}).add(T);
    if (instance is Injectable) instance.onInit();
    _notify('putScoped', T);
  }

  static void disposeScope(String scope) {
    final types = _scopedInstances[scope];
    if (types != null) {
      for (var type in types) {
        final instance = _instances.remove(type);
        if (instance is Injectable) instance.onDispose();
        _notify('disposeScope', type);
      }
      _scopedInstances.remove(scope);
    }
  }

  // --- Tag Support ---
  static void putTagged<T>(T instance, String tag) {
    _taggedInstances['${T}_$tag'] = instance;
    if (instance is Injectable) instance.onInit();
    _notify('putTagged', T);
  }

  static T findTagged<T>(String tag) {
    final key = '${T}_$tag';
    if (!_taggedInstances.containsKey(key)) {
      throw Exception("No tagged instance of $T with tag '$tag'.");
    }
    _notify('findTagged', T);
    return _taggedInstances[key] as T;
  }

  static void deleteTagged<T>(String tag) {
    final key = '${T}_$tag';
    final instance = _taggedInstances.remove(key);
    if (instance is Injectable) instance.onDispose();
    _notify('deleteTagged', T);
  }

  // --- Override Support (e.g., testing) ---
  static void override<T>(T instance) {
    _instances[T] = instance;
    _notify('override', T);
  }

  // --- Reset Everything ---
  static void reset() {
    _instances.forEach((type, instance) {
      if (instance is Injectable) instance.onDispose();
    });
    _instances.clear();
    _factories.clear();
    _autoDispose.clear();
    _scopedInstances.clear();
    _taggedInstances.clear();
    _notify('reset', Object);
  }

  // --- Debug Print ---
  static void debugPrintDependencies() {
    // ignore: avoid_print
    print("🔍 Registered Instances:");
    // ignore: avoid_print
    _instances.forEach((k, v) => print(" - $k => $v"));
    // ignore: avoid_print
    print("🧪 Lazy Factories:");
    // ignore: avoid_print
    _factories.forEach((k, v) => print(" - $k => $v"));
    // ignore: avoid_print
    print("🔖 Tagged Instances:");
    // ignore: avoid_print
    _taggedInstances.forEach((k, v) => print(" - $k => $v"));
  }
}
