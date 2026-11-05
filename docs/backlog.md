# Backlog

Prioritised work with status. IDs: `S-nn` setup, `A-nn` app (`fe`), `B-nn` backend (`be`),
`D-nn` open decisions. Status: todo | in progress | done (date) | blocked (on what).

## Setup

| ID | Item | Status |
|---|---|---|
| S-01 | Monorepo scaffold: `fe/` (Flutter, Android), `be/` (supabase init), `docs/`, `.claude/` with the tiered workflow | done (2026-11-05) |
| S-02 | Design directions canvas for the owner to pick from | done (2026-11-05), decision pending (D-01) |
| S-03 | Requirements interview, broad to narrow, recorded in `product.md` | in progress |
| S-04 | Hosted Supabase project: fill `fe/config/*.json`, add `project_ref` to `.mcp.json`, link the CLI | blocked on the owner (project ref, publishable key, access token or `supabase login`) |
| S-05 | Android application id | blocked (D-04) |

## Open decisions

| ID | Decision | Options | Status |
|---|---|---|---|
| D-01 | Design direction | A Ivory and Graphite | decided 2026-11-05 |
| D-02 | First scope | Guest trial booking + coach/staff/admin app; no trainee view | decided 2026-11-05 |
| D-03 | Hosted Supabase project | Owner creates it and shares the project ref and publishable key | decided 2026-11-05, waiting on the owner |
| D-04 | Android application id (currently the Flutter default `com.example.saroornagar_boxing`) | | open |
