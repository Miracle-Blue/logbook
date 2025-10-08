part of 'logbook_screen.dart';

/// {@template log_viewer_screen_state}
/// Log viewer screen state.
/// {@endtemplate}
abstract class LogViewerScreenState extends State<LogViewerScreen> {
  late final ScrollController _scrollController;
  late final FocusNode _searchFocusNode;
  late final ValueNotifier<bool> _isSendingLogToTelegram;

  bool get sendingLogToTelegramEnabled =>
      (widget.config.telegramBotToken != null &&
          widget.config.telegramBotToken!.isNotEmpty) &&
      (widget.config.telegramChatId != null &&
          widget.config.telegramChatId!.isNotEmpty);

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

  /// Writes a CSV file using an isolate for processing
  Future<String> listToCSVString({
    required List<List<Object?>> rows,
    bool addBomForExcel = true,
  }) async {
    final receivePort = ReceivePort();

    try {
      // Spawn isolate
      await Isolate.spawn(_listToCSV, [receivePort.sendPort, rows]);

      // Wait for the CSV string with timeout
      final csv = await receivePort.first.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('CSV generation timed out'),
      );

      return '\uFEFF$csv';
    } finally {
      receivePort.close();
    }
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
      final file = await listToCSVString(
        rows: [
          ['prefix', 'timestamp', 'message'],
          ...LogBuffer.instance.logs.map(
            (log) => [log.prefix, log.timestampUtc, log.message],
          ),
        ],
      );

      final bytes = utf8.encode(file);

      final uri = Uri.tryParse(
        '${Constants.telegramBaseUrl}/bot${widget.config.telegramBotToken}/sendDocument',
      );

      if (uri == null) throw Exception('Invalid URI');

      final request = http.MultipartRequest('POST', uri)
        ..fields['chat_id'] = widget.config.telegramChatId ?? ''
        ..files.add(
          http.MultipartFile.fromBytes(
            'document',
            bytes,
            filename: 'debug_info.csv',
          ),
        );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final responseBody = json.decode(response.body);

      l.i('Response: $responseBody');
    } on Object catch (e) {
      l.s('Error on save and send to telegram: $e');
    }

    _isSendingLogToTelegram.value = false;
  }

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
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

/// Converts a list of rows to CSV format in an isolate
///
/// Usage example:
/// ```dart
/// await Isolate.spawn(_listToCSV, [receivePort.sendPort, rows]);
/// ```
@pragma('vm:entry-point')
void _listToCSV(List<Object> args) {
  final receivePort = args[0] as SendPort;
  final rows = args[1] as List<List<Object?>>? ?? [];

  final buffer = StringBuffer();
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];

    for (var j = 0; j < row.length; j++) {
      // Escape values containing commas, quotes, or newlines
      final value = row[j]?.toString() ?? '';

      if (value.contains(',') || value.contains('"') || value.contains('\n')) {
        buffer.write('"${value.replaceAll('"', '""')}"');
      } else {
        buffer.write(value);
      }

      if (j < row.length - 1) buffer.write(',');
    }
    if (i < rows.length - 1) buffer.write('\n');
  }

  receivePort.send(buffer.toString());
}
