import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/model/logbook_config.dart';
import '../../common/util/logger_colors.dart';
import '../screen/logbook_screen.dart';

part 'logbook_state.dart';

/// {@template LogViewerWidget}
/// LogViewerWidget widget.
/// {@endtemplate}
class Logbook extends StatefulWidget {
  /// {@macro LogViewerWidget}
  const Logbook({required this.child, this.config, super.key});

  /// {@macro logbook_config}
  final LogbookConfig? config;

  /// {@macro child}
  final Widget child;

  @override
  State<Logbook> createState() => _LogbookState();
}

/// State for widget [LogbookState].
class _LogbookState extends LogbookState {
  @override
  Widget build(BuildContext context) => widget.config?.enabled ?? false
      ? LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min<double>(
              400,
              constraints.biggest.width * 0.99,
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
                                      pages: [
                                        MaterialPage(
                                          child: LogViewerScreen(
                                            config: config,
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
                                  color: LoggerColors.of(context).consoleWhite,
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(16),
                                  ),
                                  elevation: 0,
                                  child: InkWell(
                                    onTap: _controller.toggle,
                                    borderRadius: const BorderRadius.horizontal(
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
                ],
              ),
            );
          },
        )
      : widget.child;
}
