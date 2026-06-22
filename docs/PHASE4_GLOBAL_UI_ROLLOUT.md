# Phase 4 — Global UI Rollout (Wave 1)

## Completed Migrations

| Screen | Lines | Legacy Widgets Removed | New Components Used | Status |
|--------|-------|----------------------|-------------------|--------|
| `activities_page.dart` | 209 → 218 | ActivityListRow(8), AppFlatRowGroup(2), AppSectionHeader(2), LinearStatBar(2), FlatBackAppBar(1) | AppScaffold, AppStatusBanner, SectionHeader, ActionTile(8), ProgressBarRow(2) | ✅ |
| `people_page.dart` | 423 → 227 | AppFlatRowGroup(3), AppSectionHeader(2), LinearStatBar(3), FlatBackAppBar(1), _RelationRow, _ActionRow, PressableRow | AppScaffold, AppStatusBanner, SectionHeader, GameCard, ActionTile, ProgressBar, StatsSection | ✅ |
| `finance_page.dart` | 328 → 268 | FinanceListRow(16), AppSectionHeader(5), FlatBackAppBar(1) | AppScaffold, AppStatusBanner, SectionHeader, GameCard, ActionTile(12), ProgressBarRow | ✅ |
| `jobs_page.dart` | 669 → 430 | AppFlatRow(14), AppFlatRowGroup(3), FlatBackAppBar(1), _buildPartTimeRow, _buildPartTimeMetricBar, _buildMetricBarDetailed | AppScaffold, SectionHeader, JobCard, ActionTile, GameCard, ProgressBarRow | ✅ |
| `career_page.dart` | 1159 → 1096 | AppFlatRow(28), AppFlatRowGroup(8), FlatBackAppBar(1), _SpecialFlatRow, _buildIdentityHeader, _buildMetricBar, _buildSectionHeader | AppScaffold, AppStatusBanner, SectionHeader, GameCard, ActionTile, JobCard, ProgressBar, ProgressBarRow | ✅ |

## Summary

- **5 screens** fully migrated
- **~110 legacy widget usages** eliminated
- **0 new analyzer errors** introduced
- **0 inline styling violations** (Colors.white, BorderRadius.circular, TextStyle, BoxShadow — all tokens)

## Component Mapping

| Legacy Widget | New Component |
|---------------|---------------|
| `AppFlatRow` | `JobCard` / `ActionTile` / `GameCard` + Row |
| `AppFlatRowGroup` | `GameCard` wrapping Column, or GridView.count of `ActionTile` |
| `FinanceListRow` | `ActionTile` (grid) |
| `ActivityListRow` | `ActionTile` (grid) |
| `LinearStatBar` | `ProgressBarRow` |
| `FlatBackAppBar` | `AppTopBar` (via `AppScaffold`) |
| `AppSectionHeader.*` | `SectionHeader` |
| `_buildIdentityHeader` | `AppStatusBanner` + optional stats row |
| `_buildMetricBar` | `ProgressBar.xs` in a Row |
| `_buildSectionHeader` | `SectionHeader` |

## Remaining Screens (Future Waves)

Education screens (tutors, school_activities, scholarships) still use legacy widgets but were not in Wave 1 scope. Their migration would use the same pattern as Wave 1.

## Key Decisions

- **Dark mode tokens** exist in `AppTheme.dark` but only light theme ships — zero-cost future-proofing.
- **Legacy widgets** kept as deprecated exports in `design_system.dart` until all screens migrated.
- **3-column ActionTile grid** validated as primary action layout (Career Center screen as reference).
- **Pre-existing dead code** (6 `kSpecialCareerDebugMode` blocks) left untouched.
