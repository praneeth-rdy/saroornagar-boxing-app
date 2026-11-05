# Task 19 - Android application id com.saroornagarboxing.app

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** fe
- **Worker:** developer (Opus)
- **Tests:** no (the assistant's release build and install is the check)
- **Owner request this serves:** "let's have com.saroornagarboxing.app" (2026-11-05), decision D-04.

## Spec
- `fe/android/app/build.gradle.kts`: `namespace` and `applicationId` become
  `com.saroornagarboxing.app`.
- Move `MainActivity.kt` to `fe/android/app/src/main/kotlin/com/saroornagarboxing/app/
  MainActivity.kt` with `package com.saroornagarboxing.app`; delete the old
  `com/example/saroornagar_boxing` folder.
- Check every manifest (`main`, `debug`, `profile`) and the launcher icon XML for references to
  the old package; none should remain (`grep -rn "saroornagar_boxing" fe/android` returns only
  nothing or the Flutter-generated `.gradle`/build caches).
- `fe/CLAUDE.md`: the sentence saying the id is still the Flutter default becomes
  "Application id: `com.saroornagarboxing.app` (owner, 2026-11-05)". `docs/fe/architecture.md`
  Build row.

## Acceptance criteria
- [ ] `flutter build apk --debug` succeeds; `aapt dump badging` on it shows
      `package: name='com.saroornagarboxing.app'` and the label "Saroornagar Boxing".
- [ ] `flutter analyze` unchanged.
