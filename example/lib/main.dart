import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logbook/logbook.dart';

void main() => runZonedGuarded(() => runApp(const MyApp()), l.s);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Logbook Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    themeMode: ThemeMode.system,
    home: const LogbookDemo(),
    builder: (context, child) => Logbook(
      config: LogbookConfig(
        enabled: kDebugMode,
        debugFileName: '${DateTime.now().toIso8601String()}.csv',
        telegramBotToken: '',
        telegramChatId: '',
      ),
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

class LogbookDemo extends StatefulWidget {
  const LogbookDemo({super.key});

  @override
  State<LogbookDemo> createState() => _LogbookDemoState();
}

class _LogbookDemoState extends State<LogbookDemo> {
  int _actionCount = 0;
  Timer? _backgroundTimer;
  bool _isProcessing = false;

  void _performAction() {
    _actionCount++;

    l.i('User action performed - Count: $_actionCount');
    l.f('Action details: timestamp=${DateTime.now().toIso8601String()}');

    setState(() {});
  }

  Future<void> _simulateAsyncOperation() async {
    setState(() => _isProcessing = true);
    l.i('Starting async operation...');

    try {
      l.f('Processing step 1/3');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      l.f('Processing step 2/3');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      l.f('Processing step 3/3');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      l.i('Async operation completed successfully');
    } on Object catch (e) {
      l.s('Error during async operation: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _triggerWarning() {
    l.w('Warning: This is a simulated warning message');
    l.w('User triggered warning action - this might need attention');
  }

  void _triggerError() {
    try {
      l.i('Attempting operation that will fail...');
      throw Exception('Simulated error for demonstration');
    } on Object catch (e, stackTrace) {
      l.s('Error occurred: $e');
      l.s('StackTrace: $stackTrace');
    }
  }

  void _logCustomType() {
    l.log('This is a custom log type message', 'CUSTOM');
    l.c('Configuration: Using custom log types for special events');
  }

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    l.i('App initialized - Logbook demo started');

    // Simulate background activity
    _backgroundTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => l.f('Background timer tick #${timer.tick}'),
    );
  }

  @override
  void dispose() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    l.i('App disposed - Logbook demo ended');

    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logbook Demo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.book_rounded,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Logbook Package Demo',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Interact with the buttons below to generate different types of logs.\nOpen the Logbook overlay to view them!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Card
              Card(
                elevation: 2,
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Actions Performed',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_actionCount',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons Section
              Text(
                'Log Types',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Info Log
              _LogActionButton(
                icon: Icons.info_outline,
                label: 'Info Log',
                description: 'General information messages',
                color: Colors.blue,
                onPressed: _performAction,
              ),
              const SizedBox(height: 12),

              // Fine Log
              _LogActionButton(
                icon: Icons.bug_report_outlined,
                label: 'Fine Log',
                description: 'Detailed debugging information',
                color: Colors.green,
                onPressed: () {
                  l.f('Fine log generated - detailed debug info');
                  _actionCount++;
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),

              // Warning Log
              _LogActionButton(
                icon: Icons.warning_amber_outlined,
                label: 'Warning Log',
                description: 'Potential issues or warnings',
                color: Colors.orange,
                onPressed: () {
                  _triggerWarning();
                  _actionCount++;
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),

              // Error Log
              _LogActionButton(
                icon: Icons.error_outline,
                label: 'Error Log',
                description: 'Severe errors and exceptions',
                color: Colors.red,
                onPressed: () {
                  _triggerError();
                  _actionCount++;
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),

              // Custom Log
              _LogActionButton(
                icon: Icons.star_outline,
                label: 'Custom Log',
                description: 'Custom log types for special cases',
                color: Colors.purple,
                onPressed: () {
                  _logCustomType();
                  _actionCount++;
                  setState(() {});
                },
              ),
              const SizedBox(height: 24),

              // Async Operation
              Text(
                'Advanced Operations',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              FilledButton.icon(
                onPressed: _isProcessing ? null : _simulateAsyncOperation,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  _isProcessing ? 'Processing...' : 'Simulate Async Operation',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Instructions
              Card(
                elevation: 1,
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How to View Logs',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Look for the Logbook icon on your screen\n'
                        '• Tap it to open the log viewer\n'
                        '• Filter logs by type\n'
                        '• View detailed information for each log entry',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogActionButton extends StatelessWidget {
  const _LogActionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
