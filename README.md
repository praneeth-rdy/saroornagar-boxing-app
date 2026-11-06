# Saroornagar boxing club app

People management app for a boxing club in Saroornagar: coaches take, view and manage trainee
attendance, and people book trial sessions. Android app in Flutter, Supabase (free tier) as
the only backend. One repository, three areas:

| Folder | Holds |
|---|---|
| `fe/` | The Flutter app (Android). `fe/CLAUDE.md` has its rules, commands and code guidelines. |
| `be/` | The Supabase backend: `supabase/` migrations, RLS, functions, pgTAP, seed, local config. `be/CLAUDE.md` has its rules. |
| `docs/` | Product reference, architecture maps, backlog, decisions, review log, and the running memory (`docs/memory/`). `docs/README.md` has the protocol. |

## State

Release 1 shipped on 2026-11-05 as a sideloaded APK ("Saroornagar Boxing", application id
`com.saroornagarboxing.app`; build 41 is the first build shared with the coaches). Staff sign
in by email and password. Today is the roll call: coaches tap the students present in the
morning, evening or an extra session, ordered by roll number, with confirmed undo and
session reset. Students holds the roster (roll numbers, details, active or inactive, a
date-grouped attendance log, fee history). Trials lists the visits guests book, without an
account, through the public form linked from sign-in. Fees: staff record cash or UPI
payments (500 junior, 800 senior) on the student. More holds the reports (fee status,
monthly attendance as classes attended) and, for admins, Staff (create, reset password,
block). The backend is one hosted Supabase project with 12 migrations and the
`admin-staff` Edge Function.

Where to look:

- `docs/product.md`: what the product is and what the owner confirmed.
- `docs/decisions.md`: why things are the way they are (read this first for the why).
- `docs/memory/current.md`: where the work stands now and what is blocked.
- `docs/memory/instructions.md`: every owner instruction, dated, with where it was applied.

### Release and install

After every landed app run (`.claude/CLAUDE.md` Toolchain), from `fe/`, with the upload
keystore in `fe/android/keystore/` and `fe/android/key.properties` (gitignored, passwords in
`creds.md`):

```bash
flutter build apk --release --dart-define-from-file=config/prod.json \
  --build-number=$(git rev-list --count HEAD)

# check the signing certificate (the APK has v2/v3 signatures only; keytool cannot read it)
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" \
  ~/Library/Android/sdk/build-tools/36.0.0/apksigner verify --print-certs \
  build/app/outputs/flutter-apk/app-release.apk

# install on the connected device
ADB=~/Library/Android/sdk/platform-tools/adb
$ADB install -r build/app/outputs/flutter-apk/app-release.apk

# replace the shareable copy in Downloads (older copies are deleted every time)
BUILD=$(git rev-list --count HEAD)
$ADB shell 'rm -f /sdcard/Download/saroornagar-boxing-*.apk /sdcard/Download/boxing-club-*.apk'
$ADB push build/app/outputs/flutter-apk/app-release.apk \
  /sdcard/Download/saroornagar-boxing-$BUILD.apk
$ADB shell monkey -p com.saroornagarboxing.app -c android.intent.category.LAUNCHER 1
```

The owner shares `/sdcard/Download/saroornagar-boxing-<build>.apk` from the phone; there is
no Play Store listing yet.

## Run

```bash
# app (from fe/)
flutter pub get
flutter run --dart-define-from-file=config/dev.json   # needs SUPABASE_URL and SUPABASE_ANON_KEY filled in
flutter analyze && flutter test

# backend checks (from be/; Docker Desktop running, Node via nvm)
source ~/.zshrc
npx supabase start -x vector,logflare,studio          # API :56321, DB :56322, Mailpit :56324
npx supabase db reset && npx supabase test db
```

`fe/config/dev.json` and `fe/config/prod.json` hold the project URL and the publishable key
only, passed in with `--dart-define-from-file`. No other credential goes into the repo.

## Working on it with Claude Code

Open the repo root. `.claude/CLAUDE.md` carries the workspace rules: work on the checked-out
branch, commit at checkpoints with the co-author trailer and push, a three-tier model split
(Fable plans and reviews, Opus implements, Sonnet tests and smoke-checks), handoff packages
under `.claude/handoffs/`, the `/build` skill and the `tiered-build` workflow. Copy
`.mcp.json.example` to `.mcp.json` for the Supabase MCP (add `&project_ref=<ref>` once the
hosted project exists) and install the Supabase skills with `npx skills add
supabase/agent-skills`.
