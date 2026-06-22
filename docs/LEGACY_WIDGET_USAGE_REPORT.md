# Legacy Widget Usage Report

Generated: 2026-06-22

## Widget Deletion Status

| Widget | Former Usage | Files Using It | Deleted? | Status |
|--------|-------------|----------------|----------|--------|
| `EducationAppBar` | 3 | tutors, school_activities, scholarships | ✅ Deleted | All usage migrated to AppTopBar |
| `FlatBackAppBar` | 0 | — | ✅ Deleted | Already unused before Wave 2 |
| `AppFlatRow` | 3 | tutors, school_activities, scholarships | ✅ Deleted | All usage migrated to inline Row |
| `AppFlatRowGroup` | 9 | tutors(2), school_activities(4), scholarships(3) | ✅ Deleted | All usage migrated to GameCard |
| `AppSectionHeader` | 0 | — | ✅ Deleted | All usage migrated to SectionHeader |
| `FinanceListRow` | 0 | — | ✅ Deleted | Already unused (Wave 1) |
| `ActivityListRow` | 0 | — | ✅ Deleted | Already unused (Wave 1) |
| `PressableRow` | 0 | — | ✅ Deleted | Already unused (Wave 1) |
| `LinearStatBar` | 0 | — | ✅ Deleted | Already unused (Wave 1) |
| `BondBar` | 0 | — | ✅ Deleted | Already unused (from design_system.dart) |

## Widgets Remaining (Wave 3 Targets)

| Widget | Usages | Files | Notes |
|--------|--------|-------|-------|
| `GameRow(` | 3 | home_page(2), create_character(1) | Pending: Business/Organizations screens |
| `RowGroup(` | 2 | home_page(1), create_character(1) | Pending: Business/Organizations screens |
| `SectionLabel(` | 13 | design_system(1), create_character(5), market_page(2), legacy_page(6) | Pending: Business/Organizations screens |
| `StatBar(` | 8 | home_page(4), design_system(4), service_record_section(4) | Pending: home_page redesign |

## Legacy Patterns Remaining (Including Styling)

| Pattern | Count | Screens |
|---------|-------|---------|
| `GoogleFonts.lexend` | 145 | 31 |
| `EdgeInsets.symmetric` | 73 | 29 |
| `Colors.white` | 61 | 19 |
| `SectionLabel(` | 13 | 3 |
| `StatBar(` | 8 | 2 |
| `EdgeInsets.all` | 17 | 11 |
| `BorderRadius.circular` | 16 | 12 |
| `GameRow(` | 3 | 2 |
| `RowGroup(` | 2 | 2 |
| `Colors.grey` | 1 | 1 |
| `BoxShadow(` | 1 | 1 |

## Files Deleted
- `lib/widgets/common_widgets.dart` (683 lines, entire file)
- `lib/screens/career/special_careers/politician/widgets/politician_header.dart`
- `lib/screens/career/special_careers/politician/widgets/politician_stat_bars.dart`
- `lib/screens/career/special_careers/politician/widgets/politician_navigation_section.dart`
