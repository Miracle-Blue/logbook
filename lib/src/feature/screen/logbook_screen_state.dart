part of 'logbook_screen.dart';

/// {@template log_viewer_screen_state}
/// Log viewer screen state.
/// {@endtemplate}
abstract class LogViewerScreenState extends State<LogViewerScreen> {
  /// Throttling for scroll to bottom
  late final Throttling<void> _scrollToBottomThrottling;

  /// Throttling for logs changed
  late final Throttling<void> _logsChangedThrottling;

  /// Font family
  String get fontFamily => widget.config.fontFamily;

  /// Scroll controller
  late final ScrollController _scrollController;

  /// Search focus node
  late final FocusNode _searchFocusNode;

  /// Is sending log to server
  late final ValueNotifier<bool> _isSendingLogToServer;

  /// Sending log to server enabled
  bool get sendingLogToServerEnabled => widget.config.uri != null;

  /// Selected filter — Set for O(1) lookups
  Set<String> selectedFilter = {};

  /// Whether the user has explicitly interacted with the filter
  bool _filterInteracted = false;

  /// Is search enabled
  bool _isSearchEnabled = false;

  /// Is user scrolled
  bool _isUserScrolled = false;

  /// Consumed logs count
  int _consumedLogsCount = 0;

  /// Log messages
  late final ValueNotifier<List<LogMessage>> activeLogMessages;

  /// Search query
  String _searchQuery = '';

  /// Debounce timer for search input
  Timer? _searchDebounce;

  /// Whether all available prefixes are selected
  bool get _isAllSelected {
    final allPrefixes = LogBuffer.instance.logsPrefix;
    return allPrefixes.isNotEmpty && allPrefixes.every(selectedFilter.contains);
  }

  /// Log messages filtered by prefix and search query.
  /// Cache the result in a local variable — do not
  /// call this getter more than once per frame.
  List<LogMessage> get logMessages {
    var messages = activeLogMessages.value;

    if (selectedFilter.isNotEmpty) {
      messages = messages
          .where((log) => selectedFilter.contains(log.prefix))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      messages = messages
          .where(
            (log) =>
                log.message.toLowerCase().contains(lower) ||
                log.prefix.toLowerCase().contains(lower) ||
                log.timestamp.toString().toLowerCase().contains(lower),
          )
          .toList();
    }

    return messages;
  }

  /// Method that handles the logs changed listener
  void _onLogsChangedListener() => _logsChangedThrottling.throttle(() {
    final newLogs = LogBuffer.instance
        .logsSince(_consumedLogsCount)
        .toList(growable: false);
    _consumedLogsCount = LogBuffer.instance.totalLogsCount;

    if (newLogs.isEmpty) return;

    if (!_filterInteracted) {
      final newPrefixes = LogBuffer.instance.logsPrefix.where(
        (p) => !selectedFilter.contains(p),
      );
      if (newPrefixes.isNotEmpty) selectedFilter.addAll(newPrefixes);
    }

    final current = activeLogMessages.value;
    final combined = [...current, ...newLogs];

    if (combined.length > LogBuffer.bufferLimit) {
      activeLogMessages.value = combined.sublist(
        combined.length - LogBuffer.bufferLimit,
      );
    } else {
      activeLogMessages.value = combined;
    }
  });

  /// Method that handles the search tap
  void _onSearchTap() {
    setState(() {
      _isSearchEnabled = !_isSearchEnabled;
      if (!_isSearchEnabled) _searchQuery = '';
    });

    if (_isSearchEnabled) {
      _searchFocusNode.requestFocus();
      selectedFilter = LogBuffer.instance.logsPrefix.toSet();
    }
  }

  /// Handles search input — debounced to avoid
  /// per-keystroke rebuilds.
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), () {
      setState(() => _searchQuery = value.trim());
    });
  }

  /// Method that handles the filter tap
  void _onFilterTap(String value) {
    _filterInteracted = true;

    if (value == 'All') {
      if (_isAllSelected) {
        selectedFilter.clear();
      } else {
        selectedFilter = LogBuffer.instance.logsPrefix.toSet();
      }
    } else {
      if (selectedFilter.contains(value)) {
        selectedFilter.remove(value);
      } else {
        selectedFilter.add(value);
      }
    }

    setState(() {});
  }

  /// Method that handles scroll notifications to track user scroll position
  bool _onScrolled(ScrollUpdateNotification notification) {
    if (notification.metrics.pixels <
        notification.metrics.maxScrollExtent - 100) {
      _isUserScrolled = true;
    } else if (notification.metrics.pixels ==
        notification.metrics.maxScrollExtent) {
      _isUserScrolled = false;
    }
    return true;
  }

  /// Method that handles the scroll to bottom listener
  void _scrollToBottomListener() => _scrollToBottomThrottling.throttle(() {
    if (_scrollController.hasClients && !_isUserScrolled) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  });

  /// Method that handles the scroll to bottom tap
  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Method that handles the save and send to server tap
  Future<void> onSaveAndSendToServerTap() async {
    if (!sendingLogToServerEnabled) {
      l.w('Sending log to server is not enabled');

      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 8),
            content: Text(
              'Sending log to server is not enabled please set server uri '
              '(optional: multipart file fields) in logbook config otherwise '
              'read logbook documentation for more information',
            ),
          ),
        );

      return;
    }

    if (_isSendingLogToServer.value) return;
    _isSendingLogToServer.value = true;

    HapticFeedback.selectionClick().ignore();

    await LogBuffer.instance.sendLogsToServer(
      uri: widget.config.uri,
      debugFileName: widget.config.debugFileName,
      multipartFileFields: widget.config.multipartFileFields,
    );

    _isSendingLogToServer.value = false;
  }

  /// Method that clears the active logs
  void _onClearLogsTap() => activeLogMessages.value = [];

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();

    _scrollToBottomThrottling = Throttling<void>(
      duration: const Duration(milliseconds: 500),
    );
    _logsChangedThrottling = Throttling<void>(
      duration: const Duration(milliseconds: 300),
    );

    _scrollController = ScrollController();
    _searchFocusNode = FocusNode();
    _isSendingLogToServer = ValueNotifier(false);

    activeLogMessages = ValueNotifier(<LogMessage>[]);

    LogBuffer.instance
      ..addListener(_scrollToBottomListener)
      ..addListener(_onLogsChangedListener);
  }

  @override
  void dispose() {
    LogBuffer.instance
      ..removeListener(_onLogsChangedListener)
      ..removeListener(_scrollToBottomListener);

    _searchDebounce?.cancel();
    _isSendingLogToServer.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();

    _logsChangedThrottling.close();
    _scrollToBottomThrottling.close();

    super.dispose();
  }

  /* #endregion */
}
