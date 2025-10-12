import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../logbook.dart';
import '../../common/model/console_color.dart';
import '../../common/model/log_message.dart';
import '../../common/util/log_message_to_csv.dart';
import '../../common/util/logger_colors.dart';
import '../data/logbook_repository.dart';
import '../logbook/log_buffer.dart';

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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: LoggerColors.of(context).loggerBackground,
    appBar: AppBar(
      centerTitle: false,
      backgroundColor: LoggerColors.of(context).loggerBackground,
      title: _isSearchEnabled
          ? TextField(
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(border: InputBorder.none),
            )
          : Text(
              'Debug console',
              style: TextStyle(
                color: LoggerColors.of(context).consoleWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
      actions: [
        PopupMenuButton<String>(
          onSelected: _onFilterTap,
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.filter_list_rounded,
            color: selectedFilter == LogViewerScreenState._allFilter
                ? LoggerColors.of(context).consoleWhite
                : LoggerColors.of(context).brilliantAzure,
          ),
          itemBuilder: (context) => filterItems
              .map<PopupMenuEntry<String>>(
                (e) => PopupMenuItem(
                  value: e,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e,
                        style: TextStyle(
                          color: selectedFilter == e
                              ? LoggerColors.of(context).brilliantAzure
                              : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      if (selectedFilter == e)
                        Icon(
                          Icons.check_rounded,
                          color: LoggerColors.of(context).brilliantAzure,
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),

        IconButton(
          onPressed: _onSearchTap,
          icon: Icon(
            Icons.search_rounded,
            color: LoggerColors.of(context).consoleWhite,
          ),
        ),
      ],
    ),
    body: ListenableBuilder(
      listenable: LogBuffer.instance,
      builder: (context, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverList.builder(
              itemCount: logMessages.length,
              itemBuilder: (context, index) {
                final log = logMessages.elementAt(index);

                final child = SelectableText.rich(
                  TextSpan(
                    children: [
                      // Prefix
                      TextSpan(
                        text: '[',
                        style: TextStyle(
                          color: LoggerColors.of(context).brilliantAzure,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      TextSpan(
                        text: log.prefix,
                        style: TextStyle(
                          color: log.color.consoleColorToColor(context),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      TextSpan(
                        text: '] ',
                        style: TextStyle(
                          color: LoggerColors.of(context).brilliantAzure,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),

                      // Timestamp
                      TextSpan(
                        text: '[${log.timestamp}] ',
                        style: TextStyle(
                          color: LoggerColors.of(context).brilliantAzure,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),

                      // Message
                      TextSpan(
                        text: log.message,
                        style: TextStyle(
                          color: log.color.consoleColorToColor(context),
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );

                if (index % 2 == 0) {
                  return ColoredBox(
                    color: LoggerColors.of(context).gray.withAlpha(30),
                    child: child,
                  );
                } else {
                  return child;
                }
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 128)),
          ],
        ),
      ),
    ),
    floatingActionButton: ValueListenableBuilder(
      valueListenable: _isSendingLogToServer,
      builder: (context, isLoading, child) => FloatingActionButton(
        backgroundColor: LoggerColors.of(context).consoleWhite,
        onPressed: onSaveAndSendToServerTap,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (isLoading) {
            true => RepaintBoundary(
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  color: LoggerColors.of(context).loggerBackground,
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
            false => Icon(
              Icons.upload_file,
              color: LoggerColors.of(context).loggerBackground,
            ),
          },
        ),
      ),
    ),
  );
}
