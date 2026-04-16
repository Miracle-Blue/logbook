import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../logbook.dart';
import '../../common/model/console_color.dart';
import '../../common/model/log_message.dart';
import '../../common/util/logger_colors.dart';
import '../../common/util/throttling.dart';
import '../logbook/log_buffer.dart';
import 'filter_overlay.dart';

part 'logbook_screen_state.dart';

/// {@template log_viewer_screen}
/// Log viewer screen.
/// {@endtemplate}
class LogViewerScreen extends StatefulWidget {
  /// {@macro log_viewer_screen}
  const LogViewerScreen({required this.config, super.key});

  /// {@macro logbook_config}
  final LogbookConfig config;

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

/// State for [LogViewerScreen].
class _LogViewerScreenState extends LogViewerScreenState {
  @override
  Widget build(BuildContext context) {
    final colors = LoggerColors.of(context);

    return Scaffold(
      backgroundColor: colors.loggerBackground,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: colors.loggerBackground,
        title: _isSearchEnabled
            ? TextField(
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(border: InputBorder.none),
                style: TextStyle(
                  color: colors.consoleWhite,
                  letterSpacing: -0.5,
                ),
              )
            : Text(
                'Debug console',
                style: TextStyle(
                  color: colors.consoleWhite,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                final offset = (context.findRenderObject() as RenderBox?)
                    ?.localToGlobal(Offset.zero);

                FilterOverlay.show(
                  context,
                  offset: offset ?? Offset.zero,
                  selectedFilters: selectedFilter,
                  onSelected: _onFilterTap,
                );
              },
              icon: Icon(
                Icons.filter_list_rounded,
                color: selectedFilter.value.isNotEmpty
                    ? colors.brilliantAzure
                    : colors.consoleWhite,
              ),
            ),
          ),

          IconButton(
            onPressed: _onSearchTap,
            icon: Icon(Icons.search_rounded, color: colors.consoleWhite),
          ),

          IconButton(
            onPressed: _onClearLogsTap,
            icon: Icon(
              Icons.delete_outline_outlined,
              color: colors.consoleWhite,
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: activeLogMessages,
        builder: (context, child) {
          final filteredLogs = logMessages;

          return NotificationListener<ScrollUpdateNotification>(
            onNotification: _onScrolled,
            child: Scrollbar(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverList.builder(
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        final logColor = log.color.toColor(colors);

                        final child = SelectableText.rich(
                          style: const TextStyle(height: 0),
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '[${log.prefix}]',
                                style: TextStyle(
                                  color: logColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: '[${log.timestamp}] ',
                                style: TextStyle(
                                  color: colors.brilliantAzure,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: log.message,
                                style: TextStyle(
                                  color: logColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        );

                        if (index.isEven) {
                          return ColoredBox(
                            color: colors.gray.withAlpha(30),
                            child: child,
                          );
                        }
                        return child;
                      },
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 128)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 8,
        children: [
          ValueListenableBuilder(
            valueListenable: _isSendingLogToServer,
            builder: (context, isLoading, child) => FloatingActionButton(
              backgroundColor: colors.consoleWhite,
              onPressed: onSaveAndSendToServerTap,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: switch (isLoading) {
                  true => RepaintBoundary(
                    child: SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        color: colors.loggerBackground,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  false => Icon(
                    Icons.upload_file,
                    color: colors.loggerBackground,
                  ),
                },
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: colors.consoleWhite,
            onPressed: scrollToBottom,
            child: Icon(
              Icons.arrow_downward_rounded,
              color: colors.loggerBackground,
            ),
          ),
        ],
      ),
    );
  }
}
