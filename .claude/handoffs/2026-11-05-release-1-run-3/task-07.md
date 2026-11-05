# Task 07 - Brand assets from L5a Classic: launcher icon and in-app mark

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** fe
- **Depends on:** task-06
- **Worker:** developer (Opus)
- **Tests:** yes (assistant: proofs of the sign-in and trial screens; release build)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a
- **Owner request this serves:** "Let's use L5a classic" (2026-11-05), decision D-05.

## Goal
The app carries the club's chosen logo: the glove emblem as the Android launcher icon
(adaptive), and the full badge on the sign-in and public trial screens.

## Context the worker needs
`fe/CLAUDE.md`; `docs/decisions.md` (Logo); the source artboard
`docs/design/logos/project/L5a-Classic.dc.html` (inline SVG, viewBox 0 0 100 100, palette ink
#1D1D1F, accent #0A5FD6, ivory #F5F5F7, white). The sign-in screen
(`features/auth/presentation/sign_in_screen.dart`) and the trial form
(`features/trials/presentation/book_trial_screen.dart`) currently open with an `Eyebrow`.

## Files
- `docs/design/logos/final/badge.svg`, `emblem.svg` - create - standalone SVG masters extracted from the artboard (full badge; glove emblem alone)
- `docs/design/logos/final/{icon-foreground-1024.png,icon-background-1024.png,icon-1024.png}` - create - rendered PNGs (headless Chrome or `rsvg-convert`, whichever exists; say which)
- `fe/assets/brand/badge.png`, `badge@2x.png`, `badge@3x.png` (`fe/assets/brand/2.0x/`, `3.0x/` per Flutter's convention) - create - the badge at 160 logical px
- `fe/pubspec.yaml` - modify - `assets/brand/`; dev dependency `flutter_launcher_icons` (latest stable, record the version) with its config block
- `fe/android/app/src/main/res/mipmap-*/`, `res/mipmap-anydpi-v26/`, `res/values/colors.xml` as the generator writes them - create/modify
- the two screens - modify - badge above the title
- `docs/fe/architecture.md` - modify - Build and assets rows

## Spec
- Launcher icon (adaptive): background a flat accent `#0A5FD6` square; foreground the glove
  emblem in white, centred, occupying about 60 percent of the safe area (the generator's
  `adaptive_icon_foreground` expects the 1024 PNG with padding). Legacy icon: the same on a
  rounded accent square. Run `dart run flutter_launcher_icons`. Android only.
- Sign-in and trial screens: a centred `Image.asset('assets/brand/badge.png', width: 120)`
  (semantic label "Saroornagar Boxing") above the existing eyebrow and title, with
  `AppSpacing.xl` below it. Nothing else moves.
- No new runtime dependency (PNG assets, not SVG rendering).

## Out of scope
Splash screen, iOS, Play Store listing, changing the app name.

## Acceptance criteria
- [ ] `flutter analyze` 0 issues; `dart format` clean; suite passes.
- [ ] `aapt dump badging` on a debug or release APK shows the launcher icon resources; the
      generated mipmaps are committed.
- [ ] Proofs (assistant): `sign_in_empty` and `book_trial_empty` re-rendered with the badge.
- [ ] SVG masters and PNGs exist under `docs/design/logos/final/`.

## Verification
From `fe/`: `dart run flutter_launcher_icons`, `flutter analyze`, `flutter test`, `flutter test test/proofs`, `flutter build apk --debug`.
