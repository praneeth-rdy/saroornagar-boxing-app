# Current state

Last updated 2026-11-05 (afternoon). Session history is in `log.md`; this file is the snapshot.

## Where the product stands

Scaffold only. Requirements interview in progress (`docs/product.md`, Open questions). The
design-directions canvas (https://claude.ai/artifact/FCyab964t4z3EBViU17TeE) awaits the
owner's pick (D-01). No app code beyond the Flutter template, no migrations, no hosted
Supabase project.

| Area | State |
|---|---|
| `fe/` | `flutter create --empty`, Android only, package `saroornagar_boxing`, application id still the Flutter default (D-04). Lint rules set. `config/dev.json` and `prod.json` empty. |
| `be/` | `supabase init` with ports 563xx; no migrations. |
| `docs/` | Protocol, product (confirmed vs open), backlog, decisions, empty architecture maps. |
| `.claude/` | Workspace rules, developer and assistant agents, `/build` skill, `tiered-build` workflow, handoff template. Supabase skills installed (gitignored). |

## Toolchain on this Mac (observed 2026-11-05)

Flutter 3.47.7 with the Android SDK 36; Docker Desktop running; Node through nvm (shells start
with `source ~/.zshrc`); `npx supabase` 3.0.0, **not logged in** (`supabase login` or the MCP
OAuth is the owner's step); no `gh`. Xcode incomplete (irrelevant, Android only).

## Blocked on the owner

1. Hosted Supabase project `qgqmnaxdxuezjlexlfpw` (region ap-northeast-1, Tokyo; created by the owner
   2026-11-05). Publishable key in `fe/config/*.json`. CLI logged in and `be/` linked (2026-11-05). Still needed: the DB password (for `db push`), MCP approval after a relaunch. Credentials live in `creds.md` (gitignored).
2. Remaining open points in `docs/product.md` (DOB on the trainee record, trial slot
   details, Android application id, first admin creation).
3. Approval of the first schema proposal (sent in chat 2026-11-05).
4. (settled) Credentials in the gitignored `creds.md` at the repo root.

## Resume checklist

1. Interview rounds 1 to 4 done; design A chosen; release 1 = guest trial booking + staff
   app, no trainee view.
2. Next: schema approval, then run 1 packages (be: identity, trainees, sessions, attendance,
   trial bookings, fee payments; fe: theme A, sign-in, Today, roster, trials, fees) through
   the `tiered-build` workflow (standing opt-in).
