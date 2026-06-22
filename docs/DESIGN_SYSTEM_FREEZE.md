# DESILIFE Design System Freeze

> Generated after Phase 4C migration completion.
> This document defines the approved design system boundary. No new UI patterns, widgets, or tokens may be introduced without explicit approval.

---

## Approved Components

| Component | Source | Purpose |
|---|---|---|
| `AppScaffold` | `widgets/core/app_scaffold.dart` | Standard page layout with top bar and scrollable body |
| `AppTopBar` | `widgets/core/app_top_bar.dart` | Navigation bar with back button, title, subtitle, trailing |
| `AppCard` | `widgets/core/app_card.dart` | Generic bordered card with optional left accent |
| `AppStatusBanner` | `widgets/core/app_status_banner.dart` | Status header with label, title, subtitle, trailing |
| `GameCard` | `widgets/game/game_card.dart` | Rounded card with shadow, optional accent, pressable variant |
| `ProgressBar` | `widgets/game/progress_bar.dart` | Horizontal progress bar (sm, xs variants) |
| `ProgressBarRow` | `widgets/game/progress_bar.dart` | Label + progress bar + percentage row |
| `ActionTile` | `widgets/game/action_tile.dart` | Grid action tile with emoji, label, rewards, lock state |
| `JobCard` | `widgets/game/job_card.dart` | Job listing card with company, salary, lock state |
| `SectionHeader` | `widgets/game/section_header.dart` | Section title with optional icon, action label |
| `StatsSection` | `widgets/game/stats_section.dart` | Stats section with title, icon, stat items |
| `TimelineTile` | `widgets/game/timeline_tile.dart` | Timeline entry with state (completed/active/locked) |
| `StatusChip` | `widgets/game/status_chip.dart` | Status badge (active, retired, locked, etc.) |
| `LockedOverlay` | `widgets/game/locked_overlay.dart` | Locked content overlay with requirement text |
| `GameEngine` | `core/engine.dart` | Core game logic engine |
| `formatMoney` | `core/design_system.dart` | Currency formatting (₹, en_IN) |
| `shortMoney` | `core/design_system.dart` | Abbreviated currency (1K, 1L, 1Cr) |
| `cleanText` | `core/design_system.dart` | Text sanitization |

---

## Approved Tokens

### Colors (`core/design_system.dart` — class `AppColors`)

| Token | Hex | Usage |
|---|---|---|
| `background` | `#F4F4F4` | Page background |
| `surface` | `#FFFFFF` | Cards, containers, sheets |
| `primary` | `#1E9E54` | Primary actions, accents, active state |
| `warning` | `#E5A100` | Warnings, caution |
| `error` | `#D9534F` | Errors, destructive actions |
| `textPrimary` | `#1F1F1F` | Primary text |
| `textSecondary` | `#707070` | Secondary/muted text |
| `outline` | `#D8D8D8` | Borders, dividers |
| `divider` | `#E5E5EA` | Light dividers |
| `dividerLight` | `#F2F2F7` | Extra light dividers |
| `success` | `#1E9E54` | Success states (alias of primary) |
| `danger` | `#D9534F` | Danger states (alias of error) |
| `info` | `#1E9E54` | Info states (alias of primary) |
| `textMuted` | `#D1D1D6` | Muted hint text |
| `iconBg` | `#F2F2F7` | Icon backgrounds |
| `darkBg` | `#1C1C1E` | Dark backgrounds |

### Typography (`core/design_system.dart` — class `AppTextStyles`)

| Token | Font | Size/Weight | Usage |
|---|---|---|---|
| `displayLg` | Lexend | 32/700 | Page titles |
| `displayMd` | Lexend | 24/700 | Section titles |
| `headlineSm` | Lexend | 20/700 | Card titles |
| `bodyLg` | Inter | 16/400 | Body text |
| `bodyMd` | Inter | 14/400 | Body text (compact) |
| `labelBold` | Inter | 12/700 | Labels, buttons |
| `labelSm` | Inter | 11/500 | Small labels |
| `financial` | Lexend | 24/900 | Financial values |
| `financialSmall` | Lexend | 16/800 | Small financial values |

### Spacing (`core/design_system.dart` — class `AppSpacing`)

| Token | Value | Usage |
|---|---|---|
| `xs` | 4 | Tiny gaps |
| `sm` | 8 | Small gaps |
| `md` | 16 | Standard gaps |
| `lg` | 24 | Large gaps |
| `xl` | 32 | Section gaps |
| `cardGap` | 12 | Between card elements |
| `containerPadding` | 16 | Standard container padding |

### Border Radius (`core/design_system.dart` — class `AppBorderRadius`)

| Token | Value | Usage |
|---|---|---|
| `sm` | 4 | Small elements |
| `md` | 8 | Buttons, inputs |
| `lg` | 8 | Cards (same as md) |
| `xl` | 10 | Large cards |
| `full` | 9999 | Circular elements |

### Shadows (`core/design_system.dart` — class `AppShadows`)

| Token | Usage |
|---|---|
| `card` | Standard card shadow |

### Animation (`core/app_animations.dart` — class `AppAnimations`)

| Token | Usage |
|---|---|
| `fast` | Quick transitions |
| `normal` | Standard transitions |
| `slow` | Emphasis transitions |
| `tap` | Press feedback duration |

---

## Forbidden Patterns

### Widgets — DO NOT USE

- `GameRow` — deleted; use `InkWell` inside `GameCard` or `ActionTile`
- `RowGroup` — deleted; use `GameCard(padding: EdgeInsets.zero)` with `Column`
- `SectionLabel` — deleted; use `SectionHeader`
- `StatBar` — deleted; use `ProgressBarRow`
- `VitalsSection` — deleted; use `StatsSection`
- `AppPage` — deleted; use `AppScaffold`
- `AppTopBar` (in `design_system.dart`) — deleted; use `widgets/core/app_top_bar.dart`
- `BondBar` — deleted; use custom text rendering
- `common_widgets.dart` — file deleted

### Patterns — DO NOT USE

- `GoogleFonts.lexend(` — use `AppTextStyles.*` instead
- `GoogleFonts.inter(` — use `AppTextStyles.*` instead
- `Colors.white` — use `AppColors.surface` instead
- `Colors.black` — use `Colors.black` only for overlay backgrounds
- `Colors.grey` — use `AppColors.textSecondary` or `AppColors.outline` instead
- `Color(0xFF...)` — use `AppColors.*` instead (except domain-specific colors like gain/loss)
- `BorderRadius.circular(` — use `AppBorderRadius.*` instead
- `BoxShadow(` — use `AppShadows.card` instead
- `EdgeInsets.all(` — use `EdgeInsets.all(AppSpacing.*)` instead
- `EdgeInsets.only(` — use `EdgeInsets.only(/* AppSpacing */)` instead
- `EdgeInsets.fromLTRB(` — use `EdgeInsets.fromLTRB(/* AppSpacing */)` instead
- `EdgeInsets.symmetric(` — use `AppSpacing.*` values instead
- Direct hex colors in widgets — use `AppColors.*` instead

---

## Migration Notes

1. `Colors.white` on `CircularProgressIndicator` is acceptable (inherits widget color contract)
2. `Colors.black` on root `Container` wrapping `home_page.dart` is intentional (portal layering)
3. Domain-specific colors (stock gain/loss green/red) may remain as hex when no `AppColors` equivalent exists
4. `Scaffold(backgroundColor: AppColors.background)` is preferred over `AppScaffold` when custom layout (Stack, ConstrainedBox) is required
5. The `design_system.dart` file must remain **tokens only** — no legacy UI widgets

---

## Extension Policy

To add a new component or token:

1. Must be generic enough for 3+ use cases
2. Must be added to the appropriate `widgets/` subdirectory
3. Must use only approved tokens
4. Must have a corresponding entry in this document
5. Must pass `flutter analyze` with 0 errors

---

*DESILIFE UI is now fully migrated to a single, unified design system.*
