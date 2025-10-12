# 📚 Logbook

A powerful, elegant, and developer-friendly logging package for Flutter applications. Logbook provides an intuitive overlay UI for viewing logs in real-time, with support for different log levels, color coding, and optional server integration for remote debugging.

<div style="display: flex; flex-direction: row; flex-wrap: wrap; gap: 10px;">
  <img src="https://github.com/Miracle-Blue/logbook/raw/main/screenshots/screenshot_1.png" width="180" alt="Logbook Overview">
  <img src="https://github.com/Miracle-Blue/logbook/raw/main/screenshots/screenshot_2.png" width="180" alt="Logbook filter">
  <img src="https://github.com/Miracle-Blue/logbook/raw/main/screenshots/screenshot_3.png" width="180" alt="Logbook filter">
  <img src="https://github.com/Miracle-Blue/logbook/raw/main/screenshots/screenshot_4.png" width="180" alt="Logbook search">
</div>

## ✨ Features

- 🎨 **Comprehensive UI Overlay** - Slide-in panel with color-coded logs
- 📊 **Multiple Log Levels** - Fine, Config, Info, Warning, Severe, and Custom
- 🔍 **Real-Time Viewing** - See logs as they happen in your app
- 📱 **Sever Integration** - Send logs to your sever for remote debugging in CSV format
- 🚀 **Lightweight** - Minimal performance impact
- 🔧 **Configurable** - Enable/disable in different environments
- 📦 **No Dependencies** - Only depends on Flutter SDK and http package

---

## 📦 Installation

Add `logbook` to your `pubspec.yaml`:

```yaml
dependencies:
  logbook: ^0.0.1 # Replace with actual version
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

### 1. Wrap Your App

Wrap your `MaterialApp` with the `Logbook` widget:

```dart
import 'package:flutter/material.dart';
import 'package:logbook/logbook.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: const HomePage(),
      builder: (context, child) => Logbook(
        config: LogbookConfig(
          enabled: true,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
```

### 2. Start Logging

Use the global `l` instance to log messages:

```dart
import 'package:logbook/logbook.dart';

void someFunction() {
  l.i('This is an info message');
  l.w('This is a warning');
  l.f('This is a fine (debug) message');
}
```

### 3. View Logs

Tap the small overlay handle on the side of your screen to open the log viewer!

---

## 📖 Basic Usage

### Log Types

Logbook provides several log types, each with its own color and purpose:

```dart
// Fine - Detailed debugging information (Black)
l.f('User data loaded: ${user.name}');

// Config - Configuration information (Green)
l.c('API endpoint: https://api.example.com');

// Info - General information messages (Blue)
l.i('User logged in successfully');

// Warning - Potential issues (Yellow/Orange)
l.w('Network latency is high', StackTrace.current, 'Performance Issue');

// Severe - Errors and exceptions (Red)
l.s('Failed to load data', StackTrace.current, 'API Error');

// Custom - Your own log type (Purple)
l.log('Custom event occurred', 'CUSTOM');
```

### Error Handling

Perfect for catching and logging exceptions:

```dart
try {
  await someRiskyOperation();
} catch (e, stackTrace) {
  l.s('Operation failed: $e', stackTrace);
}
```

### Global Error Handler

Catch all uncaught errors in your app:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logbook/logbook.dart';

void main() {
  runZonedGuarded(
    () => runApp(const MyApp()),
    (error, stackTrace) {
      l.s('Uncaught error: $error', stackTrace);
    },
  );
}
```

---

## ⚙️ Configuration

### LogbookConfig

Configure Logbook behavior with `LogbookConfig`:

```dart
Logbook(
  config: LogbookConfig(
    enabled: kDebugMode,                                // Enable only in debug mode
    debugFileName: 'app_logs.csv',                      // CSV export filename
    uri: 'YOUR_SEVER_URI',                              // Optional: Server URI
    multipartFileFields: 'YOUR_MULTIPART_FILE_FIELDS',  // Optional: Multipart file fields
    fontFamily: 'Monospace',                            // Optional: Font family
  ),
  child: child ?? const SizedBox.shrink(),
)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enabled` | `bool` | `kDebugMode` | Enable/disable the logbook overlay |
| `debugFileName` | `String` | `'debug_info.csv'` | Filename for CSV exports to server |
| `uri` | `String?` | `null` | Server URI for remote logging |
| `multipartFileFields` | `String?` | `null` | Multipart file fields for remote logging |
| `fontFamily` | `String` | `'Monospace'` | Font family for the logbook |

---

## 📱 Example App

Check out the [example](./example) directory for a complete working app showcasing all features:

```bash
cd example
flutter run
```

The example app demonstrates:
- All log types
- Async operations logging
- Error handling
- Background timer logs
- Beautiful UI showcasing the package

---

## 🛠️ API Reference

### Global Logger (`l`)

```dart
// Info log
l.i(Object? message);

// Fine/Debug log
l.f(Object? message);

// Config log
l.c(Object? message);

// Warning log
l.w(Object exception, [StackTrace? stackTrace, String? reason]);

// Severe/Error log
l.s(Object exception, [StackTrace? stackTrace, String? reason]);

// Custom log
l.log(Object message, String prefix, {
  StackTrace? stackTrace,
  bool withMilliseconds = false,
});
```

### LogbookConfig

```dart
const LogbookConfig({
  Uri? uri,
  Map<String, String>? multipartFileFields,
  String debugFileName = 'debug_info.csv',
  bool enabled = kDebugMode,
  String fontFamily = 'Monospace',
});
```

### LogBuffer

```dart
// Access the log buffer
LogBuffer.instance.logs; // Get all logs
LogBuffer.instance.clear(); // Clear all logs
LogBuffer.instance.add(logMessage); // Add a log
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  If you find this package useful, give it a ⭐ on <a href="https://github.com/Miracle-Blue/logbook">GitHub</a>!
</p>
