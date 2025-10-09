# 📚 Logbook

<p align="center">
  <img src="https://img.shields.io/pub/v/logbook.svg" alt="Pub Version">
  <img src="https://img.shields.io/badge/flutter-%3E%3D3.8.0-blue.svg" alt="Flutter Version">
  <img src="https://imThe first public release of Logbook - a powerful logging package for Flutter applications.g.shields.io/badge/license-MIT-green.svg" alt="License">
</p>

A powerful, elegant, and developer-friendly logging package for Flutter applications. Logbook provides an intuitive overlay UI for viewing logs in real-time, with support for different log levels, color coding, and optional Telegram integration for remote debugging.

<div style="display: flex; flex-direction: row; flex-wrap: wrap; gap: 10px;">
  <img src="https://github.com/Miracle-Blue/logbook/raw/main/screenshots/screenshot_1.png" width="200" alt="Logbook Overview">
  <img src="https://github.com/Miracle-Blue/logbook/raw/main/screenshots/screenshot_2.png" width="200" alt="Logbook filter">
  <img src="https://github.com/Miracle-Blue/logbook/raw/main/screenshots/screenshot_3.png" width="200" alt="Logbook filter">
  <img src="https://github.com/Miracle-Blue/logbook/raw/main/screenshots/screenshot_4.png" width="200" alt="Logbook search">
</div>

---

## ✨ Features

- 🎨 **Beautiful UI Overlay** - Slide-in panel with color-coded logs
- 📊 **Multiple Log Levels** - Fine, Config, Info, Warning, Severe, and Custom
- 🌈 **Color-Coded Logs** - Easy visual identification of log types
- 🔍 **Real-Time Viewing** - See logs as they happen in your app
- 📱 **Telegram Integration** - Send logs to Telegram for remote debugging
- 💾 **CSV Export** - Export logs for analysis
- 🎯 **Type-Safe API** - Strongly typed with full null-safety support
- 🚀 **Lightweight** - Minimal performance impact
- 🔧 **Configurable** - Enable/disable in different environments
- 📦 **No Dependencies** - Only depends on Flutter SDK and http package

---

## 📦 Installation

Add `logbook` to your `pubspec.yaml`:

```yaml
dependencies:
  logbook: ^0.0.1
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
    enabled: kDebugMode,              // Enable only in debug mode
    debugFileName: 'app_logs.csv',    // CSV export filename
    telegramBotToken: 'YOUR_BOT_TOKEN',  // Optional: Telegram bot token
    telegramChatId: 'YOUR_CHAT_ID',      // Optional: Telegram chat ID
  ),
  child: child ?? const SizedBox.shrink(),
)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enabled` | `bool` | `kDebugMode` | Enable/disable the logbook overlay |
| `debugFileName` | `String` | `'debug_info.csv'` | Filename for CSV exports |
| `telegramBotToken` | `String?` | `null` | Telegram bot token for remote logging |
| `telegramChatId` | `String?` | `null` | Telegram chat ID to send logs to |

### Environment-Specific Configuration

```dart
// Development
const devConfig = LogbookConfig(
  enabled: true,
  debugFileName: 'dev_logs.csv',
);

// Production (disabled)
const prodConfig = LogbookConfig(
  enabled: false,
);

// Use based on environment
Logbook(
  config: kDebugMode ? devConfig : prodConfig,
  child: child,
)
```

---

## 🎨 Log Types Reference

### Fine (`l.f`)
**Purpose:** Detailed debugging information
**Color:** Black
**Use Case:** Verbose logs, method entry/exit, variable values

```dart
l.f('Fetching user profile for ID: $userId');
l.f('Response received: ${response.statusCode}');
```

### Config (`l.c`)
**Purpose:** Configuration and setup information
**Color:** Green
**Use Case:** App initialization, configuration values, feature flags

```dart
l.c('API base URL: ${Config.apiUrl}');
l.c('Feature X enabled: ${FeatureFlags.featureX}');
```

### Info (`l.i`)
**Purpose:** General informational messages
**Color:** Blue
**Use Case:** User actions, state changes, important events

```dart
l.i('User logged in: ${user.email}');
l.i('Payment processed successfully');
```

### Warning (`l.w`)
**Purpose:** Potential issues that don't prevent operation
**Color:** Yellow/Orange
**Use Case:** Deprecated API usage, slow performance, recoverable errors

```dart
l.w('API response time exceeded 3 seconds');
l.w(Exception('Retrying failed request'), StackTrace.current);
```

### Severe (`l.s`)
**Purpose:** Serious errors and exceptions
**Color:** Red
**Use Case:** Exceptions, failed operations, critical errors

```dart
l.s('Failed to connect to database', stackTrace);
l.s(Exception('Payment failed'), StackTrace.current, 'Critical');
```

### Custom (`l.log`)
**Purpose:** Custom log types for specific needs
**Color:** Purple
**Use Case:** Analytics events, business logic tracking, custom categories

```dart
l.log('User completed onboarding', 'ANALYTICS');
l.log('Feature flag toggled: $flagName', 'FEATURE_FLAG');
```

---

## 🚀 Advanced Features

### Telegram Integration

Send logs to a Telegram bot for remote debugging:

#### 1. Create a Telegram Bot

1. Message [@BotFather](https://t.me/botfather) on Telegram
2. Send `/newbot` and follow instructions
3. Copy your bot token

#### 2. Get Your Chat ID

1. Start a chat with your bot
2. Send any message
3. Visit: `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
4. Find your `chat_id` in the response

#### 3. Configure Logbook

```dart
Logbook(
  config: LogbookConfig(
    enabled: true,
    telegramBotToken: '123456789:ABCdefGHIjklMNOpqrsTUVwxyz',
    telegramChatId: '987654321',
  ),
  child: child,
)
```

Now you can send logs to Telegram and export them as CSV files!

### CSV Export

Logs can be exported as CSV files for analysis:

- The filename is configurable via `debugFileName` in `LogbookConfig`
- Format: `[PREFIX] [TIMESTAMP] MESSAGE`
- Can be sent via Telegram for remote access

---

## 🎯 Best Practices

### 1. Use Appropriate Log Levels

```dart
// ✅ Good
l.i('User action: Clicked checkout button');
l.w('API response time: ${duration.inMilliseconds}ms');
l.s('Payment failed: $errorMessage', stackTrace);

// ❌ Bad
l.i('Variable x = $x'); // Too verbose for info
l.s('Button clicked');  // Not a severe error
```

### 2. Include Context

```dart
// ✅ Good
l.i('User ${user.id} updated profile: ${changes.keys.join(", ")}');

// ❌ Bad
l.i('Profile updated');
```

### 3. Log Meaningful Information

```dart
// ✅ Good
l.w(
  'Network request failed: ${response.statusCode}',
  StackTrace.current,
  'Endpoint: $endpoint',
);

// ❌ Bad
l.w('Error');
```

### 4. Don't Log Sensitive Information

```dart
// ✅ Good
l.i('User authenticated: ${user.id}');

// ❌ Bad - NEVER DO THIS
l.i('Login: ${user.email}, Password: ${user.password}');
```

### 5. Clean Up in Production

```dart
// Always disable in production builds
Logbook(
  config: LogbookConfig(
    enabled: kDebugMode, // Only enabled in debug mode
  ),
  child: child,
)
```

### 6. Use Descriptive Custom Logs

```dart
// ✅ Good
l.log('User completed level 5', 'GAME_EVENT');
l.log('A/B Test variant B shown', 'ANALYTICS');

// ❌ Bad
l.log('Event', 'EVENT');
```

---

## 🖥️ Viewing Logs

### In-App Overlay

1. **Open**: Tap the small handle on the left side of the screen
2. **Navigate**: Scroll through logs
3. **Filter**: Use the filter options (if available)
4. **Close**: Tap the handle again or tap outside the panel

### Console Output

All logs are also printed to the debug console with:
- Timestamps
- Color coding
- Stack traces (when provided)

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

## 🤔 FAQ

### Q: Does Logbook affect performance?

**A:** Logbook has minimal performance impact. Logs are buffered efficiently and the UI overlay only renders when opened. In production (when `enabled: false`), there's virtually no overhead.

### Q: Can I use Logbook in production?

**A:** While you can, it's recommended to disable it in production builds by setting `enabled: false` or `enabled: kDebugMode`.

### Q: How many logs can be stored?

**A:** The log buffer has a limit of 65,536 messages (64KB). Older logs are automatically removed when this limit is reached.

### Q: Can I customize the log colors?

**A:** Currently, log colors are predefined. Custom color support may be added in future versions.

### Q: Does it work on all platforms?

**A:** Yes! Logbook works on iOS, Android, Web, macOS, Linux, and Windows.

---

## 🐛 Troubleshooting

### Logs not appearing

1. Check that `enabled: true` in `LogbookConfig`
2. Verify you're running in debug mode if using `enabled: kDebugMode`
3. Make sure the `Logbook` widget is wrapping your app

### Overlay not visible

1. Ensure your app has `MaterialApp` or `CupertinoApp`
2. Check that there are no full-screen overlays blocking the handle
3. Try restarting the app

### Telegram logs not sending

1. Verify your bot token is correct
2. Ensure your chat ID is accurate
3. Check your internet connection
4. Make sure you've started a chat with your bot

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
  String? telegramBotToken,
  String? telegramChatId,
  String debugFileName = 'debug_info.csv',
  bool enabled = kDebugMode,
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

### Development Setup

```bash
# Clone the repository
git clone https://github.com/Miracle-Blue/logbook.git

# Navigate to the project
cd logbook

# Get dependencies
flutter pub get

# Run tests
flutter test

# Run example app
cd example
flutter run
```

### Guidelines

- Follow the existing code style
- Add tests for new features
- Update documentation
- Keep commits focused and descriptive

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Ravshan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 🙏 Acknowledgments

- Thanks to all contributors
- Inspired by the need for better debugging tools in Flutter
- Built with ❤️ for the Flutter community

---

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/Miracle-Blue/logbook/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/Miracle-Blue/logbook/discussions)
- 📧 **Email**: Contact the maintainers

---

## 🗺️ Roadmap

- [ ] Log filtering by type
- [ ] Search functionality
- [ ] Export logs to file
- [ ] Custom color schemes
- [ ] Performance metrics
- [ ] Network request logging
- [ ] Screenshot capture with logs
- [ ] Dark/Light theme toggle

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/Miracle-Blue">Ravshan</a>
</p>

<p align="center">
  If you find this package useful, please give it a ⭐ on <a href="https://github.com/Miracle-Blue/logbook">GitHub</a>!
</p>
