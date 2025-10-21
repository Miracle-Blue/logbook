part of 'logbook_screen.dart';

/// {@template log_viewer_screen_state}
/// Log viewer screen state.
/// {@endtemplate}
abstract class LogViewerScreenState extends State<LogViewerScreen> {
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

  /// All filter
  static const _allFilter = 'All';

  /// Selected filter
  String selectedFilter = 'All';

  /// Is search enabled
  bool _isSearchEnabled = false;

  /// Is user scrolled
  bool _isUserScrolled = false;

  /// Search results
  final List<LogMessage> _searchResults = [];

  /// Log messages
  List<LogMessage> get logMessages => _searchResults.isEmpty
      ? LogBuffer.instance.logs.toList()
      : _searchResults;

  /// Filter items
  List<String> get filterItems {
    final items = LogBuffer.instance.logs
        .map<String>((log) => log.prefix)
        .toSet()
        .toList();

    return items
      ..sort()
      ..insert(0, _allFilter);
  }

  /// Method that handles the search tap
  void _onSearchTap() {
    setState(() => _isSearchEnabled = !_isSearchEnabled);

    if (_isSearchEnabled) {
      _searchFocusNode.requestFocus();
      selectedFilter = _allFilter;
    }
  }

  /// Method that handles the search changed
  void _onSearchChanged(String value) {
    final query = value.trim();

    if (query.isEmpty) {
      _searchResults.clear();
    } else {
      final lower = query.toLowerCase();

      final matches = LogBuffer.instance.logs.where(
        (log) =>
            log.message.toLowerCase().contains(lower) ||
            log.prefix.toLowerCase().contains(lower) ||
            log.timestamp.toString().toLowerCase().contains(lower),
      );

      _searchResults
        ..clear()
        ..addAll(matches);
    }

    setState(() {});
  }

  /// Method that handles the filter tap
  void _onFilterTap(String value) {
    selectedFilter = value;

    if (selectedFilter == _allFilter) {
      _searchResults.clear();
    } else {
      _searchResults
        ..clear()
        ..addAll(
          LogBuffer.instance.logs.where((log) => log.prefix == selectedFilter),
        );
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

  void _scrollToBottomListener() {
    if (_scrollController.hasClients && !_isUserScrolled) {
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
              'Sending log to server is not enabled please set server uri (optional: multipart file fields) in logbook config otherwise read logbook documentation for more information',
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

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _searchFocusNode = FocusNode();
    _isSendingLogToServer = ValueNotifier(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    LogBuffer.instance.addListener(_scrollToBottomListener);
  }

  @override
  void dispose() {
    LogBuffer.instance.removeListener(_scrollToBottomListener);

    _searchFocusNode.dispose();
    _scrollController.dispose();
    _isSendingLogToServer.dispose();

    super.dispose();
  }

  /* #endregion */
}
