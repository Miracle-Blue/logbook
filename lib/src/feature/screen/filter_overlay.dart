import 'package:flutter/material.dart';

import '../../common/util/logger_colors.dart';
import '../logbook/log_buffer.dart';

/// {@template filter_overlay}
/// FilterOverlay widget.
/// {@endtemplate}
class FilterOverlay extends StatefulWidget {
  /// {@macro filter_overlay}
  const FilterOverlay({
    required this.offset,
    required this.onSelected,
    required this.selectedFilters,
    super.key,
  });

  /// Offset of the filter overlay.
  final Offset offset;

  /// Selected filters.
  final ValueNotifier<Set<String>> selectedFilters;

  /// Callback function that is called when a filter is selected.
  final void Function(String value) onSelected;

  static OverlayEntry? _currentEntry;

  /// Hides the filter overlay.
  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }

  /// Shows the filter overlay.
  static void show(
    BuildContext context, {
    required final Offset offset,
    required final ValueNotifier<Set<String>> selectedFilters,
    required final void Function(String value) onSelected,
  }) {
    _currentEntry?.remove();
    _currentEntry = null;

    final overlayEntry = OverlayEntry(
      builder: (context) => FilterOverlay(
        offset: offset,
        onSelected: onSelected,
        selectedFilters: selectedFilters,
      ),
    );

    _currentEntry = overlayEntry;
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  State<FilterOverlay> createState() => _FilterOverlayState();
}

/// State for widget FilterOverlay.
abstract class FilterOverlayState extends State<FilterOverlay> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }

  /* #endregion */
}

class _FilterOverlayState extends FilterOverlayState {
  @override
  Widget build(BuildContext context) {
    final colors = LoggerColors.of(context);

    return Positioned.fill(
      child: InkWell(
        onTap: FilterOverlay.hide,
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 30,
              left: 8,
              right: 60,
              bottom: 8,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.loggerBackground,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                border: Border.all(
                  color: colors.gray.withValues(alpha: .3),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: 180,
                  child: ValueListenableBuilder(
                    valueListenable: widget.selectedFilters,
                    builder: (context, value, child) => Column(
                      spacing: 4,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: InkWell(
                            onTap: () {
                              widget.onSelected('All');
                              setState(() {});
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: value.contains('All'),
                                  onChanged: null,
                                  tristate: true,
                                  checkColor: colors.consoleWhite,
                                  fillColor: WidgetStateProperty.all(
                                    value.contains('All')
                                        ? colors.brilliantAzure
                                        : Colors.transparent,
                                  ),
                                  overlayColor: WidgetStateProperty.all(
                                    colors.brilliantAzure,
                                  ),
                                  side: BorderSide(
                                    width: 1.5,
                                    color: value.contains('All')
                                        ? colors.brilliantAzure
                                        : colors.gray,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'All',
                                    style: TextStyle(
                                      color: value.contains('All')
                                          ? colors.brilliantAzure
                                          : colors.consoleWhite,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...LogBuffer.instance.logsPrefix.map(
                          (e) => SizedBox(
                            height: 40,
                            child: InkWell(
                              onTap: () {
                                widget.onSelected(e);
                                setState(() {});
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Divider(
                                    color: colors.gray.withValues(alpha: .3),
                                    height: .1,
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Checkbox(
                                          value: value.contains(e),
                                          onChanged: null,
                                          tristate: true,
                                          checkColor: colors.consoleWhite,
                                          fillColor: WidgetStateProperty.all(
                                            value.contains(e)
                                                ? colors.brilliantAzure
                                                : Colors.transparent,
                                          ),
                                          overlayColor: WidgetStateProperty.all(
                                            colors.brilliantAzure,
                                          ),
                                          side: BorderSide(
                                            width: 1.5,
                                            color: value.contains(e)
                                                ? colors.brilliantAzure
                                                : colors.gray,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            e,
                                            style: TextStyle(
                                              color: value.contains(e)
                                                  ? colors.brilliantAzure
                                                  : colors.consoleWhite,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
