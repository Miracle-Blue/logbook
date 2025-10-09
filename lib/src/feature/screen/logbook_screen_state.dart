part of 'logbook_screen.dart';

/// {@template log_viewer_screen_state}
/// Log viewer screen state.
/// {@endtemplate}
abstract class LogViewerScreenState extends State<LogViewerScreen> {
  late final ScrollController _scrollController;
  late final FocusNode _searchFocusNode;
  late final ValueNotifier<bool> _isSendingLogToTelegram;

  late final ILogbookRepository _logbookRepository;

  bool get sendingLogToTelegramEnabled => widget.config.uri != null;

  static const _allFilter = 'All';
  String selectedFilter = 'All';

  bool _isSearchEnabled = false;
  final List<LogMessage> _searchResults = [];

  List<LogMessage> get logMessages => _searchResults.isEmpty
      ? LogBuffer.instance.logs.toList()
      : _searchResults;

  List<String> get filterItems {
    final items = LogBuffer.instance.logs
        .map<String>((log) => log.prefix)
        .toSet()
        .toList();

    return items
      ..sort()
      ..insert(0, _allFilter);
  }

  void _onSearchTap() {
    setState(() => _isSearchEnabled = !_isSearchEnabled);

    if (_isSearchEnabled) {
      _searchFocusNode.requestFocus();
      selectedFilter = _allFilter;
    }
  }

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

  Future<void> onSaveAndSendToTelegramTap() async {
    if (!sendingLogToTelegramEnabled) {
      l.w('Sending log to telegram is not enabled');

      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 8),
            content: Text(
              'Sending log to telegram is not enabled please set telegram bot token and chat id in logbook config otherwise read logbook documentation for more information',
            ),
          ),
        );

      return;
    }

    if (_isSendingLogToTelegram.value) return;
    _isSendingLogToTelegram.value = true;

    HapticFeedback.selectionClick().ignore();

    try {
      final file = await LogBuffer.instance.toCSVString();

      final bytes = utf8.encode(file);

      await _logbookRepository.sendLog(
        widget.config.uri!,
        bytes,
        fileName: widget.config.debugFileName,
        fields: widget.config.multipartFileFields,
      );
    } on Object catch (e) {
      l.s('Error on save and send to telegram: $e');
    }

    _isSendingLogToTelegram.value = false;
  }

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();

    _logbookRepository = LogbookRepository();

    _scrollController = ScrollController();
    _searchFocusNode = FocusNode();
    _isSendingLogToTelegram = ValueNotifier(false);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _isSendingLogToTelegram.dispose();
    super.dispose();
  }

  /* #endregion */
}
