# Task 06 - Release signing with the upload keystore

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-2/`
- **Area:** fe
- **Depends on:** task-05 (runs after the feature packages so the Gradle change never races a smoke build)
- **Worker:** developer (Opus)
- **Tests:** no (the assistant's release build and device install is the check)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
`flutter build apk --release` produces an APK signed with the club's upload keystore, so every
release build installs over the previous one on the owner's device and the same key can later
publish to the Play Store.

## Context the worker needs
- `fe/CLAUDE.md` (Android only, application id still the default, no secrets in the repo).
- The keystore exists at `fe/android/keystore/upload-keystore.jks` and
  `fe/android/key.properties` holds `storePassword`, `keyPassword`, `keyAlias=upload`,
  `storeFile=keystore/upload-keystore.jks` (path relative to `fe/android/`). Both are
  gitignored; never read their values into a report, never copy them anywhere.
- Flutter docs pattern: load `key.properties` in `android/app/build.gradle.kts`, define
  `signingConfigs.create("release")`, use it in `buildTypes.release`.

## Files
- `fe/android/app/build.gradle.kts` - modify - signing config
- `docs/fe/architecture.md` - modify - one row under a "Build" heading: release signing and where the secrets live

## Spec
- At the top of `build.gradle.kts`: read `rootProject.file("key.properties")` into a
  `Properties` object when the file exists.
- `signingConfigs.create("release")` with `keyAlias`, `keyPassword`, `storeFile =
  file(keystoreProperties["storeFile"])` (resolved against `fe/android/`), `storePassword`.
- `buildTypes.release.signingConfig`: the release config when `key.properties` exists, else
  the debug config with a Gradle `logger.warn("key.properties missing: release build is
  debug-signed")`. Keep every other default (`minifyEnabled`, shrink) as the template has it.
- No change to the application id (D-04 stays open), `minSdk`, `targetSdk` or the manifest.

## Out of scope
App bundles, Play Store upload, ProGuard rules, application id, version bumps (the build
number is passed on the command line by the assistant).

## Acceptance criteria
- [ ] `flutter build apk --release --dart-define-from-file=config/prod.json --build-number=1`
      succeeds from `fe/` and the APK's signing certificate has `CN=Saroornagar Boxing Club`
      (`keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk`, keytool
      from `/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/`).
- [ ] With `key.properties` temporarily renamed, the build still succeeds and prints the
      warning; restore the file afterwards and say so.
- [ ] `git status` shows no keystore or properties file.
- [ ] `flutter analyze` unchanged (no Dart touched).

## Verification
The commands above from `fe/`. Report the certificate CN line and the two build outcomes only.
