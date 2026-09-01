# SimBox Adminka — Flutter prototype

Layout prototype of the SimBox admin panel, ported from the HTML Design
Component. Desktop-targeted (Linux / macOS / Windows / web).

    flutter create . --platforms=web,macos,linux,windows   # generate runners
    flutter run -d chrome

## Structure

| File | Role |
| --- | --- |
| `lib/theme.dart` | NativeMind DS tokens + the 16px `Ico` glyph widget (nearest-neighbour, never resampled) |
| `lib/data.dart` | Nav items, action groups, column defs, mock SIM rows, icon mapping |
| `lib/widgets/sidebar.dart` | Left nav; the logo toggles compact (64px, icons only) ↔ full (208px, labels) |
| `lib/widgets/actions_bar.dart` | Title + `Всего: N` + grouped actions in one row; commands open in an overlay sheet |
| `lib/widgets/sim_table.dart` | Dense grid: pinned header band, only the body scrolls, sortable columns, zebra as brand tint |
| `lib/main.dart` | Shell, selection state, command log console |

## Ported behaviour

- Compact/full nav switched by tapping the logo (square ↔ wide asset).
- Actions grouped two-clicks-deep, disabled until rows are selected.
- Action sheet is an overlay — the table does not shift when it opens.
- Header stays pinned; horizontal scroll moves header and body together.
- Zebra: rows brand@3.5% over white, header band 5%, selected row 9%.
- Left-aligned text; stacked cells ranked primary 12 → secondary 10 → tertiary.

## Assets

Copy `assets/imgs/` and the two logos from the project root next to
`pubspec.yaml`. Icons are the original 16×16 GostSimBox glyphs — rendered at
16px with `FilterQuality.none`; any non-integer size blurs them.
