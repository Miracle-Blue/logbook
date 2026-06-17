## 0.5.4

- `Logbook.sendLogsToServer` no longer requires a `Logbook` widget to be in scope; it sends using the current (possibly runtime-updated) config

## 0.5.3

- Config can now be changed at runtime via `Logbook.config` (get/set) and observed with `Logbook.configListenable`; the overlay updates live (theme, font, `enabled`, server settings)
- The `Logbook(config: ...)` constructor is unchanged, but the widget's instance `config` field is now private — read the static `Logbook.config` instead

## 0.5.2

- Custom `l.log` prefixes now each render in their own stable, dark-friendly color instead of all magenta
- The per-prefix color is shown consistently in both the console (24-bit color) and the in-app log viewer

## 0.5.1

- Replaced PopupMenuButton filter with a custom overlay-based filter panel
- Replaced raw `Isolate.spawn` with `compute` for CSV generation
- Updated `http` dependency to ^1.6.0

## 0.5.0

- Multi-select log filter with checkboxes and "All" toggle (replaces single-select)
- Scroll-to-bottom floating action button

## 0.4.0

- Added clear logs feature

## 0.3.3

- Log view changed

## 0.3.2

- Pub score fixed

## 0.3.1

- Pub score fixed

## 0.3.0

- Added sendLogsToServer method to Logbook class
- Added throttling for scroll to bottom
- Pub score fixed

## 0.2.1

- Package logo added

## 0.2.0

- Added theme mode support - allows customizing the logbook theme (light, dark, or system)
- Added automatic scroll to bottom when new logs arrive (unless user has scrolled up)
- Added copyWith method for LogbookConfig class

## 0.1.5

- Pub score fixed (The local variable '\_timePad' starts with an underscore)

## 0.1.4

- Error log fixed

## 0.1.3

- Pub score fixed

## 0.1.2

- logs fontSize changed to 11
- add functionality to change font family

## 0.1.1

- Pub score fixed

## 0.1.0

- Initial stable release

## 0.0.1

- Initial release.
