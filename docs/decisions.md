# Decisions

Newest first. Short: the decision, the reason, the alternatives considered.

## 2026-11-05

- **Presence-only attendance.** Coaches tap only the students who are present; in a session
  with at least one mark everyone unmarked counts as absent; a session with no marks is
  ignored in every count (class not held or attendance not taken). A mistaken mark is undone
  with `unmark_attendance` and a whole session cleared with `reset_session_attendance`, both
  behind a confirmation dialog. Reason: less tapping and no false absents for days with no
  class (owner, "user need not manually mark absent"). Alternatives dropped: explicit absent
  marking and a "mark the remaining absent" action.

- **Roll numbers: numeric, chosen in the form, unique among active students.** The form
  suggests the smallest unused number (gaps first, else highest + 1) and staff may change
  it; the Today roster and the Students list are ordered by roll number. Reason: students
  call out a short number at roll call, and a left student's number can be given to a new
  one (owner, "unique among the active students ... First filling the gaps"). Alternative
  dropped: permanent sequence numbers that are never reused (the first cut, run-3 task-15).

- **Attendance reporting: classes attended, grouped by date.** Monthly attendance shows how
  many classes each student attended that month, with no target or total-held figure;
  tapping a student opens their log. Logs are grouped by date, each date naming the sessions
  attended (morning, evening, extra with its time). A student made inactive keeps that
  month's marks in the monthly summary; the roster and fee status list stay active-only
  (B-06). Reason: owner, "Let's not show the target number sessions"; one row per date reads
  faster than one card per session. Alternative dropped: per-session rows and an
  attended-of-held ratio.

- **Fees: amount is a choice of 500 or 800.** 500 per month for juniors (under 15), 800 for
  seniors (15 and above), picked from a two-value choice on a compact record-payment screen;
  the server's `private.fee_tier_amount` returns the tier, while `record_fee_payment` still
  accepts any amount from 1 to 100000 (partial payments). Reason: owner, "Let's also have the amount as a
  dropdown of 500 or 800". Alternatives dropped: a free amount field and the 1000 senior
  tier from interview round 4.

- **"Student" in every user-facing string; code and tables keep `trainee`.** Server messages
  were reworded too (B-12). Reason: the owner renamed the term; renaming tables, functions,
  files and providers would be churn with no visible benefit and a risky migration.

- **Forgot password: built, entry point hidden.** The emailed 6-digit code flow (screens,
  routes) stays in the app but the "Forgot password?" link is removed from sign-in; admins
  reset passwords from the Staff screen. Reason: owner, "Ignore reset/forgot password flow
  for now. We can do it offline."; it also drops the dependency on editing the hosted reset
  email template ({{ .Token }}). Supersedes the "forgot password by emailed code" part of the
  sign-in decision below. Alternative: ship the flow and edit the dashboard template.

- **Android identity: application id `com.saroornagarboxing.app`, label "Saroornagar
  Boxing".** Release builds are signed with an upload keystore under `fe/android/keystore/`
  and `fe/android/key.properties` (both gitignored, passwords in `creds.md`; back it up, it
  cannot be regenerated). Decided before the first share because changing the application
  id or the key later forces every user to uninstall and reinstall. Alternatives dropped:
  `com.example.saroornagar_boxing` (scaffold default) and the label "Boxing Club".

- **Distribution: sideloaded APK from the owner's phone; no Play Store yet.** Every landed
  app run is built in release mode (build number = `git rev-list --count HEAD`), installed
  on the owner's device over adb and copied to
  `/sdcard/Download/saroornagar-boxing-<build>.apk`, older copies deleted; the owner shares
  that file with the coaches. Build 41 is the first shared release. Reason: a club-sized
  user base does not justify Play Console setup for release 1. Alternative deferred: Play
  Store internal testing.

- **Hosted applies go through the MCP `apply_migration`, on the owner's word.** The hosted
  migration history therefore carries MCP timestamps, not the file names (B-10: run
  `supabase migration repair` before any `db push`). The permission classifier sometimes
  blocks an apply; the owner then says "retry now" and the same apply is repeated
  (`docs/be/architecture.md` Hosted applies). Alternative: `npx supabase db push` (kept as a
  fallback).

- **Workers get packages by direct `Agent` dispatch when the owner chats mid-run.** The
  `tiered-build` workers treat the latest chat message as the request and return BLOCKED
  for a package that does not match it (`docs/memory/notes/workflow-relayed-request.md`).
  Alternative not yet done: make `tiered-build.js` quote the originating request in every
  prompt.

- **Hosted data changes taken on the owner's word, through the MCP.** Test attendance marks
  cleared and one test student removed; the phone admin deleted and the admin
  re-created by email (login in `creds.md`); the owner's own test student set to roll 10.
  Reason: release 1 starts with clean data; no data is deleted without the owner's
  instruction for it.

- **Logo: L5a Classic badge** (owner's pick from the logo canvas
  https://claude.ai/artifact/FL6oyLDsUSpT7RSx7hQcbb; source `docs/design/logos/project/
  L5a-Classic.dc.html`): double ring, "SAROORNAGAR BOXING" on the upper arc, three dots on
  the lower arc, a blue glove at the centre; no "Club" anywhere. The app icon and small
  uses carry only the glove emblem, because ring text is unreadable below 48 px. Masters
  live in `docs/design/logos/final/`, app copies under `fe/assets/brand/`.

- **Staff sign in by email and password; forgot password by emailed code.** Phone sign-in
  needed the hosted Phone provider and had no self-service reset; email auth is on by
  default and the recovery OTP needs no deep link. The built-in sender's free-tier rate
  limit is accepted for a club; custom SMTP is a later decision. Alternative kept out: a
  recovery link with a custom URL scheme (needs redirect allow-listing and app links).

- **Design direction A, Ivory and Graphite** (owner's pick from the canvas
  https://claude.ai/artifact/FCyab964t4z3EBViU17TeE, files in `docs/design/directions/`):
  ground #F5F5F7, surface #FFFFFF, ink #1D1D1F, muted #6E6E73, accent #0A5FD6, Inter, radii
  12 and 16, 20 px gutters, no shadows, accent only on the action and the selected state.
  Alternatives B (dark), C (editorial), D (sporty) stay on the canvas as references.

- **Monorepo with `fe/`, `be/`, `docs/`.** One repository instead of the sibling-repo
  workspace used on the owner's other project: a single club app with one backend does not
  need separate deploy cadences. The `.claude/` wiring is committed at the root, not
  symlinked.
- **Running memory lives under `docs/memory/`.** Keeps the owner's three-folder layout while
  preserving the settled-vs-moving split (`docs/README.md`).
- **Commits carry the `Co-Authored-By` trailer** (owner's instruction for this project; the
  other project omits trailers).
- **No deploy-on-push for the backend.** The free tier has no Supabase branching or GitHub
  integration; migrations are applied to hosted on the owner's say-so through the MCP or
  `npx supabase db push`.
- **Local Supabase ports 563xx** so the stack can run beside the owner's other project
  (553xx) and the CLI default (543xx).
- **SQLSTATE prefix `BX`** (`BXVAL`, `BXPRM`, `BXNTF`, `BXDUP`) so the codes cannot be
  confused with the other project's `BR` codes when both are open.
