import 'package:minix/core/injectable.dart';

/// A function used to hook into dependency injection events.
///
/// Can be used for logging or debugging registration and lookup actions.
typedef InjectorHook = void Function(String event, Type type);

/// A powerful static Dependency Injection container for managing instances.
///
/// Provides support for:
/// - `put`, `lazyPut`, `find`, `delete`, etc.
/// - Auto-dispose lifecycle
/// - Scoped and tagged instances
/// - Logging and testing overrides
class Injector {
  // --- Storage ---

  /// Stores concrete instances by type.
  static final Map<Type, dynamic> _instances = {};

  /// Stores lazy-loaded factory functions by type.
  static final Map<Type, dynamic Function()> _factories = {};

  /// Tracks types that should be auto-disposed.
  static final Set<Type> _autoDispose = {};

  /// Maps scope names to sets of types registered within them.
  static final Map<String, Set<Type>> _scopedInstances = {};

  /// Stores tagged instances with unique string keys.
  static final Map<String, dynamic> _taggedInstances = {};

  // --- Debugging ---

  /// Enables logging for DI operations.
  static bool enableLogs = false;

  /// Optional external hook to listen to internal Injector events.
  static InjectorHook? onEvent;

  static void _log(String message) {
    // ignore: avoid_print
    if (enableLogs) {
      print('[minix] $message');
    }
  }

  static void _notify(String event, Type type) {
    _log('$event<$type>()');
    if (onEvent != null) {
      onEvent!(event, type);
    }
  }

  // --- Core Registration ---

  /// Registers an already created instance for the given type.
  static T put<T>(T instance) {
    _instances[T] = instance;
    if (instance is Injectable) {
      instance.onInit();
    }
    _notify('put', T);
    return instance;
  }

  /// Registers a factory function that creates an instance lazily when needed.
  static void lazyPut<T>(T Function() builder) {
    _factories[T] = builder;
    _notify('lazyPut', T);
  }

  /// Registers an instance asynchronously using a future-based builder.
  static Future<void> putAsync<T>(Future<T> Function() builder) async {
    final instance = await builder();
    put<T>(instance);
    _notify('putAsync', T);
  }

  /// Retrieves the registered instance of type [T], or creates one via factory.
  ///
  /// Throws if no instance or factory is found.
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

  /// Attempts to find the instance or create it; returns null if not found.
  static T? getOrNull<T>() {
    if (_instances.containsKey(T)) {
      return _instances[T] as T;
    }
    if (_factories.containsKey(T)) {
      final instance = _factories[T]!();
      return put<T>(instance);
    }
    return null;
  }

  /// Returns true if an instance or factory of type [T] is registered.
  static bool isRegistered<T>() {
    return _instances.containsKey(T) || _factories.containsKey(T);
  }

  /// Removes an instance and its factory, and disposes it if applicable.
  static void delete<T>() {
    final instance = _instances.remove(T);
    _factories.remove(T);
    _autoDispose.remove(T);
    if (instance is Injectable) {
      instance.onDispose();
    }
    _notify('delete', T);
  }

  // --- Auto Dispose ---

  /// Registers an instance that will automatically be disposed via [disposeAll].
  static void autoDisposePut<T>(T instance) {
    _instances[T] = instance;
    _autoDispose.add(T);
    if (instance is Injectable) {
      instance.onInit();
    }
    _notify('autoDisposePut', T);
  }

  /// Disposes all auto-disposable instances.
  static void disposeAll() {
    for (var type in _autoDispose) {
      final instance = _instances.remove(type);
      if (instance is Injectable) {
        instance.onDispose();
      }
      _notify('disposeAuto', type);
    }
    _autoDispose.clear();
  }

  // --- Scope Support ---

  /// Registers an instance under a specific named [scope].
  static void putScoped<T>(T instance, String scope) {
    _instances[T] = instance;
    (_scopedInstances[scope] ??= {}).add(T);
    if (instance is Injectable) {
      instance.onInit();
    }
    _notify('putScoped', T);
  }

  /// Disposes all instances within the given [scope].
  static void disposeScope(String scope) {
    final types = _scopedInstances[scope];
    if (types != null) {
      for (var type in types) {
        final instance = _instances.remove(type);
        if (instance is Injectable) {
          instance.onDispose();
        }
        _notify('disposeScope', type);
      }
      _scopedInstances.remove(scope);
    }
  }

  // --- Tag Support ---

  /// Registers an instance under a specific [tag].
  static void putTagged<T>(T instance, String tag) {
    _taggedInstances['${T}_$tag'] = instance;
    if (instance is Injectable) {
      instance.onInit();
    }
    _notify('putTagged', T);
  }

  /// Finds an instance registered with a given [tag].
  ///
  /// Throws if not found.
  static T findTagged<T>(String tag) {
    final key = '${T}_$tag';
    if (!_taggedInstances.containsKey(key)) {
      throw Exception("No tagged instance of $T with tag '$tag'.");
    }
    _notify('findTagged', T);
    return _taggedInstances[key] as T;
  }

  /// Deletes a tagged instance and disposes it if needed.
  static void deleteTagged<T>(String tag) {
    final key = '${T}_$tag';
    final instance = _taggedInstances.remove(key);
    if (instance is Injectable) {
      instance.onDispose();
    }
    _notify('deleteTagged', T);
  }

  // --- Override Support (e.g., testing) ---

  /// Overrides an existing instance. Useful for testing/mocking.
  static void override<T>(T instance) {
    _instances[T] = instance;
    _notify('override', T);
  }

  // --- Reset Everything ---

  /// Disposes and clears all registered instances, factories, scopes and tags.
  static void reset() {
    _instances.forEach((type, instance) {
      if (instance is Injectable) {
        instance.onDispose();
      }
    });
    _instances.clear();
    _factories.clear();
    _autoDispose.clear();
    _scopedInstances.clear();
    _taggedInstances.clear();
    _notify('reset', Object);
  }

  // --- Debug Print ---

  /// Prints all currently registered instances, factories and tagged instances.
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
