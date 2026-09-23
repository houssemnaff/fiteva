---
name: flutter-ui-review
description: Review or build Flutter UI/UX for the Fiteva app — screens, widgets, sheets, theming. Use whenever creating a new screen/widget, redesigning an existing one, or auditing UI consistency, accessibility, responsiveness, dark mode, or animations in this codebase.
---

# Fiteva Flutter UI/UX Review

Checklist and conventions specific to this codebase (`lib/theme/app_theme.dart`, `lib/screens/**`). Use this to build new UI consistently or to review existing UI for drift.

## 1. Design tokens — never hardcode

- Colors: use `Theme.of(context).colorScheme` (`cs.primary`, `cs.secondary`, `cs.surface`, `cs.onSurface`, `cs.onPrimary`) for anything theme-dependent (dark/light). Only reach for `AppTheme.*` constants for brand-fixed colors that must NOT flip with dark mode (workout category colors, onboarding palette).
- Opacity: use `.withValues(alpha: x)`, not the deprecated `.withOpacity(x)`.
- Typography: `GoogleFonts.outfit(...)` for headings/titles/buttons (bold, `w700`-`w800`, tight `letterSpacing` like `-0.2` to `-0.3`), `GoogleFonts.inter(...)` for body/secondary text. Don't introduce a third font family without checking existing screens.
- Spacing/radius: this app favors generous rounded corners (`BorderRadius.circular(14–24)` for cards/sheets/buttons) and soft alpha-blended fills (`color.withValues(alpha: 0.08–0.15)`) over solid borders. Match the surrounding screen's radius scale rather than picking a new one.
- Icons: `lucide_icons_flutter` (`LucideIcons.xxx`), not `Icons.*`, unless matching an existing `Icons.*` usage already in that file (e.g. close buttons).

## 2. Structure conventions

- Screens with a scroll + sticky header use `NestedScrollView` + `SharedAppHeader.sliver(...)` (see `community_screen.dart`) — reuse this pattern instead of a bespoke `AppBar` when the screen has tabs or a hero header.
- Modals/composers use `showModalBottomSheet` with `isScrollControlled: true` and `backgroundColor: Theme.of(context).colorScheme.surface` (or `Colors.transparent` when the sheet itself paints its own rounded container — see `notifications_sheet.dart`).
- Loading states use `Shimmer.fromColors` skeletons built from `cs.surfaceContainerHighest.withValues(alpha: ...)`, matching the real layout's shape (see `_CommunitySkeleton`), not a generic spinner, for list/feed screens.
- Tutorials/onboarding overlays use `tutorial_coach_mark` via `AppTourService.showSectionTutorial` with `SpotlightStep`s bound to `GlobalKey`s — if adding a new primary action/tab/icon to a screen that already has a tour, consider whether it needs a step too.

## 3. Localization (l10n)

- Every user-facing string must go through `AppLocalizations` (`l10n.xxx`) or an inline `isFr`/`l10n.isFrench` ternary — this app is bilingual FR/EN. Never hardcode a French or English string directly in a widget without the ternary or l10n key.
- When adding a new l10n key, check both `l10n/app_localizations_fr.arb` and `_en.arb` (or equivalent) get the entry — a widget compiling with only one locale filled in will crash or show fallback text for the other language.

## 4. State & reactivity

- This app uses `flutter_riverpod`. Read state with `ref.watch` in `build()`, mutate via `ref.read(xProvider.notifier)`. Don't call `ref.watch` inside callbacks (`onTap`, `onPressed`) — use `ref.read` there.
- Optimistic UI updates (join/leave, like, delete) update local state immediately, then sync to Supabase — errors are intentionally swallowed to keep the UI responsive (documented convention, see `CommunityService`/`NotificationsNotifier`). Don't add blocking spinners/error dialogs to these flows unless the user explicitly asks for stricter feedback — that would be an inconsistent UX vs. the rest of the app.

## 5. Responsiveness & accessibility

- Wrap long text (titles, descriptions) so it doesn't overflow on small devices — check `Expanded`/`Flexible` usage inside `Row`s, especially in cards with fixed-width leading icons/avatars.
- Tap targets: interactive `GestureDetector`/icon buttons should be ≥ 40x40 logical pixels (matches the bell icon pattern: `width: 40, height: 40`).
- Respect `MediaQuery.of(context).padding.bottom` (safe area) for bottom sheets and any content pinned to the bottom edge.
- Check contrast: text over `cs.primary`/`cs.secondary` fills must use `cs.onPrimary`/`cs.onSecondary`, not a hardcoded white, so dark mode stays readable.

## 6. When reviewing existing UI

Flag, in order of severity:
1. Hardcoded colors/strings that break dark mode or a language.
2. New patterns that duplicate an existing one (a bespoke bottom sheet header when `SharedAppHeader` or an existing sheet header widget already exists).
3. Missing loading/empty states for a list/async screen (compare against `_CommunitySkeleton` / `NotificationsSheet`'s "Aucune notification..." empty state).
4. Overflow risk on long user-generated content (event titles, usernames, comments).
5. Inconsistent spacing/radius vs. sibling screens in the same tab/section.

Don't flag stylistic preferences that have no working example elsewhere in the app to compare against — ask the user instead of guessing a "correct" convention.
