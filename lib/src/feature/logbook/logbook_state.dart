part of 'logbook.dart';

/// {@template logbook_state}
/// Logbook state.
/// {@endtemplate}
abstract class LogbookState extends State<Logbook>
    with SingleTickerProviderStateMixin {
  /// Animation controller
  late final AnimationController _controller;

  /// Dismissed
  late final ValueNotifier<bool> dismissed;

  /// Handle width
  final double handleWidth = 16;

  /// Config
  LogbookConfig get config => widget.config ?? const LogbookConfig();

  /// Method that handles the horizontal drag update
  void onHorizontalDragUpdate(DragUpdateDetails details, double width) {
    if (dismissed.value) return;

    final delta = details.delta.dx;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isLtr = Directionality.of(context) == TextDirection.ltr;

    if (dismissed.value && (isRtl ? delta < 0 : delta > 0) ||
        !dismissed.value && (isRtl ? delta > 0 : delta < 0)) {
      final newValue = _controller.value + delta / width * (isRtl ? -1 : 1);
      _controller.value = newValue.clamp(0.0, 1.0);
    }

    if (dismissed.value && (isLtr ? delta < 0 : delta > 0) ||
        !dismissed.value && (isLtr ? delta > 0 : delta < 0)) {
      final newValue = _controller.value - delta / width * (isLtr ? -1 : 1);
      _controller.value = newValue.clamp(0.0, 1.0);
    }
  }

  /// Method that handles the horizontal drag end
  void onHorizontalDragEnd(DragEndDetails details) {
    if (dismissed.value) return;

    final velocity = details.primaryVelocity ?? 0;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if ((isRtl ? -velocity : velocity) > 300 || _controller.value > 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  /// Method that handles the animation status changed
  void _onStatusChanged(AnimationStatus status) => switch (status) {
    _ when !mounted => null,
    AnimationStatus.dismissed => () {
      if (dismissed.value) return;
      setState(() => dismissed.value = true);
    }(),
    _ => () {
      if (!dismissed.value) return;
      setState(() => dismissed.value = false);
    }(),
  };

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    dismissed = ValueNotifier(true);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener(_onStatusChanged);
  }

  @override
  void didUpdateWidget(covariant Logbook oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onStatusChanged)
      ..dispose();

    super.dispose();
  }

  /* #endregion */
}
