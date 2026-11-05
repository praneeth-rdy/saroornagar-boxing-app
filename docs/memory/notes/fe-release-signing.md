# fe release signing quirks (2026-11-05)

- `keytool -printcert -jarfile app-release.apk` prints "Not a signed jar file": with Flutter's
  minSdk the APK carries only v2/v3 signatures, no v1 jar signature. Check the certificate with
  `~/Library/Android/sdk/build-tools/36.0.0/apksigner verify --print-certs <apk>` and
  `JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"` on PATH.
- The "key.properties missing" Gradle warning is hidden by `flutter build`; it shows only
  with `-v`.
- `storeFile` resolves through `rootProject.file` (relative to `fe/android/`), not the app
  module's `file()`, which would resolve against `fe/android/app/`.
