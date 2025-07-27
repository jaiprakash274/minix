![Minix Banner](https://github.com/jaiprakash274/minix/blob/main/Minix.jpeg)

### Minix 🚀
A powerful, lightweight state management and dependency injection solution for Flutter applications. Minix provides reactive programming capabilities with minimal boilerplate and maximum performance.
## Built with ❤️ by [Jai Prakash Thawait](https://github.com/jaiprakash274/minix)

### ✨ Features

* 🔥 Reactive State Management - Observable values that automatically update UI
* 💉 Dependency Injection - Lightweight service locator with advanced features
* ⚡ Performance Optimized - Minimal rebuilds, maximum efficiency
* 🎯 Type Safe - Full Dart type safety with generics
* 🔄 Async Support - Built-in async operations handling
* 📡 Stream Integration - Reactive stream management
* 🏷️ Tagged Dependencies - Multiple instances with tags
* 🔍 Scoped Injection - Scope-based lifecycle management
* 🧪 Testing Friendly - Easy mocking and overrides
* 📱 Flutter Optimized - Designed specifically for Flutter widgets

### 🚀 Quick Start
## 📦 Installation
Add the following line to your `pubspec.yaml`:

dependencies:
  minix: ^1.0.0

### Basic Usage
import 'package:minix/minix.dart';

// 1. Create observable state
final counter = Observable(0);

// 2. Use in widgets
class CounterWidget extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Observer(() => Text('Count: ${counter.value}'));
}
}

// 3. Update state
counter.value++; // UI automatically rebuilds

### 📚 Core Components
🔭 Observer Widget
Automatically rebuilds when observables change:

 Observer(() {
      return Column(
          children: [
                Text('Counter: ${counter.value}'),
                Text('Name: ${userName.value}'),
                ],
          );
      })


### 🎯 ContextObserver Widget
Observer with BuildContext access:

ContextObserver((context) {
              return Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text('Responsive: ${counter.value}'),
                    );
                })

### ⚡ Observable
Reactive state container:
// Create observable
final userName = Observable<String>('John');
final isLoading = Observable<bool>(false);

// Read value (reactive in Observer)
final name = userName.value;

// Update value
userName.value = 'Jane'; // Triggers UI rebuild

// Non-reactive read
final currentName = userName.read();

### 🔄 AsyncObservable
Handle async operations with built-in loading states:

final userService = AsyncObservable<User>();

// Execute async operation
await userService.execute(() async {
return await api.fetchUser();
});

// Use in UI
Observer(() {
if (userService.isLoading) return CircularProgressIndicator();
if (userService.hasError) return Text('Error: ${userService.error}');
if (userService.hasData) return UserWidget(userService.data!);
return Text('No data');
})

### AsyncObservable States

// Check states
userService.watchLoading() // bool - reactive
userService.watchData()    // T? - reactive  
userService.watchError()   // String? - reactive
userService.watchState()   // AsyncState - reactive

// Manual control
userService.setData(user);
userService.setError('Network error');
userService.reset();

### 📡 StreamObservable
Reactive stream management:

final chatMessages = StreamObservable<Message>();

// Listen to stream
chatMessages.listen(
messageStream,
onData: (message) => print('New message: $message'),
onError: (error) => print('Stream error: $error'),
);

// Use in UI
Observer(() {
return ListView.builder(
itemCount: chatMessages.hasData ? 1 : 0,
itemBuilder: (context, index) {
return MessageTile(chatMessages.data!);
},
);
})

// Stream operations
final filteredMessages = chatMessages
.where((msg) => msg.isImportant)
.map((msg) => msg.content);

// Control stream
chatMessages.pause();
chatMessages.resume();
await chatMessages.cancel();

### 💉 Dependency Injection
Basic Registration

// Register instance
Injector.put<ApiService>(ApiService());

// Lazy registration
Injector.lazyPut<DatabaseService>(() => DatabaseService());

// Async registration
await Injector.putAsync<ConfigService>(() async {
return await ConfigService.initialize();
});

// Find dependencies
final api = Injector.find<ApiService>();
final db = Injector.getOrNull<DatabaseService>(); // null if not found

### Advanced Features

// Auto dispose (automatic cleanup)
Injector.autoDisposePut<TempService>(TempService());
Injector.disposeAll(); // Cleans up all auto-dispose instances

// Scoped injection
Injector.putScoped<UserSession>(UserSession(), 'user_scope');
Injector.disposeScope('user_scope'); // Cleanup scope

// Tagged instances (multiple instances of same type)
Injector.putTagged<Logger>(FileLogger(), 'file');
Injector.putTagged<Logger>(ConsoleLogger(), 'console');

final fileLogger = Injector.findTagged<Logger>('file');
final consoleLogger = Injector.findTagged<Logger>('console');

// Testing overrides
Injector.override<ApiService>(MockApiService());

### Injectable Interface

class MyService implements Injectable {
@override
void onInit() {
  print('Service initialized');
}

@override
void onDispose() {
  print('Service disposed');
  }
}

### 🏗️ Architecture Patterns
MVVM with Minix

// ViewModel
class UserViewModel {
final _user = Observable<User?>(null);
final _userAsync = AsyncObservable<User>();

User? get user => _user.value;
AsyncObservable<User> get userAsync => _userAsync;

Future<void> loadUser(String id) async {
await _userAsync.execute(() =>
Injector.find<ApiService>().fetchUser(id)
);
_user.value = _userAsync.data;
}
}

// Register ViewModel
Injector.lazyPut<UserViewModel>(() => UserViewModel());

// View
class UserScreen extends StatelessWidget {
@override
Widget build(BuildContext context) {
final viewModel = Injector.find<UserViewModel>();

    return Observer(() {
      if (viewModel.userAsync.isLoading) {
        return CircularProgressIndicator();
      }
      
      return Column(
        children: [
          Text('User: ${viewModel.user?.name ?? 'Unknown'}'),
          ElevatedButton(
            onPressed: () => viewModel.loadUser('123'),
            child: Text('Load User'),
          ),
        ],
      );
    });
}
}

### Repository Pattern

abstract class UserRepository {
Future<User> getUser(String id);
Stream<List<User>> watchUsers();
}

class ApiUserRepository implements UserRepository {
final ApiService _api = Injector.find<ApiService>();

@override
Future<User> getUser(String id) => _api.fetchUser(id);

@override
Stream<List<User>> watchUsers() => _api.userStream();
}

// Registration
Injector.put<UserRepository>(ApiUserRepository());


### 🎯 Performance Tips

* Use Observer wisely - Wrap only widgets that need reactivity
* Read vs Value - Use observable.read() for non-reactive access
* Dispose resources - Always dispose observables and streams
* Lazy registration - Use lazyPut for heavy services
* Scoped dependencies - Use scopes for lifecycle management

### 🔍 Debugging
Enable logging to track dependency injection:

void main() {
Injector.enableLogs = true;
Injector.onEvent = (event, type) {
print('DI Event: $event for $type');
};

runApp(MyApp());
}

// Debug current dependencies
Injector.debugPrintDependencies();

📱 Platform Support

✅ Android
✅ iOS
✅ Web
✅ Desktop (Windows, macOS, Linux)

🤝 Contributing
We welcome contributions! Please see our Contributing Guide for details.
📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
🙋‍♂️ Support

📖 Documentation
🐛 Issues
💬 Discussions

🌟 Examples
Find complete examples in our examples directory:

📱 Counter App
🌐 API Integration
📋 Todo List with MVVM
🔄 Real-time Chat
🧪 Testing Examples


Made with ❤️ for the Flutter community







