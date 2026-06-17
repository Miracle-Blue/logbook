import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../../logbook.dart';
import '../../common/util/logger_colors.dart';
import '../screen/logbook_screen.dart';
import 'log_buffer.dart';

part 'logbook_state.dart';

/// {@template LogViewerWidget}
/// LogViewerWidget widget.
/// {@endtemplate}
class Logbook extends StatefulWidget {
  /// {@macro LogViewerWidget}
  const Logbook({
    required this.child,
    LogbookConfig config = const LogbookConfig(),
    super.key,
  }) : _initialConfig = config;

  /// The configuration applied when the overlay first mounts.
  ///
  /// After mount, read or change the config at runtime via [Logbook.config].
  final LogbookConfig _initialConfig;

  /// The child widget to be displayed.
  ///
  /// Logbook will be displayed on top of this widget as an overlay.
  final Widget child;

  /// Single source of truth for the live config. Seeded from the constructor
  /// at mount; changed at runtime via [config].
  static final ValueNotifier<LogbookConfig> _configNotifier =
      ValueNotifier<LogbookConfig>(const LogbookConfig());

  /// The current Logbook configuration.
  ///
  /// The constructor sets the initial value; assign here to change it at any
  /// time and the overlay updates live, e.g.:
  /// `Logbook.config = Logbook.config.copyWith(themeMode: ThemeMode.dark);`
  static LogbookConfig get config => _configNotifier.value;

  static set config(LogbookConfig value) => _configNotifier.value = value;

  /// Read-only listenable view of [config] for reacting to runtime changes.
  static ValueListenable<LogbookConfig> get configListenable => _configNotifier;

  /// State of the logbook widget.
  static LogbookState stateOf(BuildContext context) =>
      context.findAncestorStateOfType<LogbookState>() ??
      (throw ArgumentError(
        'Out of scope, not found widget state '
        'a $LogbookState of the exact type out_of_scope',
      ));

  /// Sends the logs to the server.
  static Future<void> sendLogsToServer(BuildContext context) async {
    final config = _configNotifier.value;

    await LogBuffer.instance.sendLogsToServer(
      uri: config.uri,
      debugFileName: config.debugFileName,
      multipartFileFields: config.multipartFileFields,
    );
  }

  @override
  State<Logbook> createState() => _LogbookState();
}

/// State for widget [LogbookState].
class _LogbookState extends LogbookState {
  @override
  Widget build(BuildContext context) => !Logbook.config.enabled
      ? widget.child
      : LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min<double>(
              400,
              constraints.biggest.width * 0.97,
            );

            return GestureDetector(
              onHorizontalDragUpdate: dismissed.value
                  ? null
                  : (details) => onHorizontalDragUpdate(details, width),
              onHorizontalDragEnd: dismissed.value ? null : onHorizontalDragEnd,
              child: Stack(
                children: <Widget>[
                  widget.child,

                  // Semi-transparent barrier behind the overlay when open
                  if (!dismissed.value)
                    AnimatedModalBarrier(
                      color: _controller.drive(
                        ColorTween(
                          begin: Colors.transparent,
                          end: Colors.black.withAlpha(127),
                        ),
                      ),
                      dismissible: true,
                      semanticsLabel: 'Dismiss',
                      onDismiss: _controller.reverse,
                    ),

                  PositionedTransition(
                    rect: _controller.drive(
                      RelativeRectTween(
                        begin: RelativeRect.fromLTRB(
                          handleWidth - width,
                          0,
                          constraints.biggest.width - handleWidth,
                          0,
                        ),
                        end: RelativeRect.fromLTRB(
                          0,
                          0,
                          constraints.biggest.width - width,
                          0,
                        ),
                      ),
                    ),
                    child: Theme(
                      data:
                          switch (Logbook.config.themeMode) {
                            ThemeMode.light => ThemeData.light(),
                            ThemeMode.dark => ThemeData.dark(),
                            _ => Theme.of(context),
                          }.copyWith(
                            textTheme: Theme.of(context).textTheme.apply(
                              fontFamily: Logbook.config.fontFamily,
                            ),
                          ),
                      child: SizedBox(
                        width: width,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Visibility(
                                visible: !dismissed.value,
                                maintainState: true,
                                maintainAnimation: false,
                                maintainSize: false,
                                maintainInteractivity: false,
                                maintainSemantics: false,
                                child: Material(
                                  elevation: 0,
                                  child: DefaultSelectionStyle(
                                    child: ScaffoldMessenger(
                                      child: HeroControllerScope.none(
                                        child: Navigator(
                                          pages: <Page<void>>[
                                            MaterialPage<void>(
                                              child: LogViewerScreen(
                                                config: Logbook.config,
                                              ),
                                            ),
                                          ],
                                          onDidRemovePage: (page) =>
                                              log('ON DID REMOVE PAGE'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Stack(
                              children: [
                                Align(
                                  child: SizedBox(
                                    width: handleWidth,
                                    height: 64,
                                    child: Material(
                                      color: LoggerColors.of(
                                        context,
                                      ).consoleWhite,
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            right: Radius.circular(16),
                                          ),
                                      elevation: 0,
                                      child: InkWell(
                                        onTap: _controller.toggle,
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                              right: Radius.circular(16),
                                            ),
                                        child: Center(
                                          child: RotationTransition(
                                            turns: _controller.drive(
                                              Tween<double>(begin: 0, end: 0.5),
                                            ),
                                            child: Icon(
                                              Icons.chevron_right,
                                              size: 18,
                                              color: LoggerColors.of(
                                                context,
                                              ).loggerBackground,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
}
