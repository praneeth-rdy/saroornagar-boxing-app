# Task NN - <short title>

- **Run:** `.claude/handoffs/<YYYY-MM-DD>-<slug>/`
- **Area:** fe | be
- **Depends on:** none | task-NN
- **Worker:** developer (Opus) | assistant (Sonnet)
- **Tests:** yes (assistant) | yes (developer) | no
- **Schema change approved by the owner:** <date and the words used> | n/a (be packages)
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_<name>.sql` | n/a

## Goal
One paragraph. What the coach, the trainee or the visitor gets when this is done.

## Context the worker needs
- The area's `CLAUDE.md` sections and `docs/<area>/architecture.md` rows that matter, and why.
  No code dumps.
- Any `docs/memory/notes/` file that bears on this change, named explicitly.
- fe packages: the server functions (`rpc()` names, parameters, SQLSTATEs) relied on, with
  the migration file that defines them.
- Which non-negotiable rules this change brushes against and how the spec respects them.

## Files
- `<area>/<path>` - create | modify - what changes in one line
- (only these files; anything else is out of scope)

## Spec
Precise. fe: signatures, provider names, routes, UI behaviour per state (loading / empty /
error / permission denied / retry), the mock repository change that mirrors a server rule, any
new `AppConfig` key. be: tables with columns and constraints, policies by name with
`using` / `with check`, revokes, function signatures with state checks in order and every
`private.fail` call with its SQLSTATE, indexes, pgTAP assertions. If there is a decision to
make, make it here; the worker must not choose.

## App impact (be packages)
The `rpc()` names, parameters, return shapes, SQLSTATEs and rules the app must mirror. This
becomes the fe package.

## Out of scope
Tempting adjacent changes the worker must NOT make.

## Acceptance criteria
- [ ] Checkable statements, each verifiable by a test or by reading the diff.
- [ ] fe: mock and Supabase repositories behave the same way; `flutter analyze` adds no issues.
- [ ] be: RLS enabled with named policies and pgTAP proof of denials; `supabase test db`
      passes.

## Verification
Commands to run and/or tests to write (what the assistant works from when Tests: yes).
fe packages check formatting with `dart format --output=none --set-exit-if-changed <touched
files>` (never a bare `dart format lib test`, which rewrites untouched files).
