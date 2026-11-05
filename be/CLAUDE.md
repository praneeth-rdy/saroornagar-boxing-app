# Boxing club backend (Supabase)

The server side of the boxing club app. This folder holds the Postgres schema, RLS policies,
the functions the app calls with `rpc()`, pgTAP tests, local seed data, auth templates and the
local-stack config, all under `supabase/`. Nothing else: the Flutter app lives in `../fe`,
the running memory in `../docs/memory`.

- Product reference: `../docs/product.md`. Do not assume a rule it does not state.
- Current state: `../docs/memory/current.md`, always. Trust it over any date written here.
- The schema map is `../docs/be/architecture.md`; the migrations are the source of truth.

## Hosted project and how migrations reach it

One hosted Supabase project on the free tier (details and credentials in the file named by
`../docs/memory/current.md`, never here). The free tier has no Supabase branching and no
GitHub deploy integration, so:

- Migrations are append-only files under `supabase/migrations`. Never edit or delete a file
  that has been applied to hosted; write a new one. No manual edits in Studio.
- **Applying a migration to hosted is an explicit step on the owner's say-so**: either the
  Supabase MCP `apply_migration` with the file's exact name (minus `.sql`) as the version, or
  `source ~/.zshrc && npx supabase db push` from a linked checkout. Record every hosted apply
  in `../docs/memory/log.md`.
- **Ask before schema changes.** Propose new tables, columns, enums, policies or function
  signature changes and wait for approval before writing the migration.
- **Supabase MCP has full access to the hosted project** for development: read schema and
  data, logs, advisors, Edge Function and storage work, type generation. The hosted project is
  the only development database once it exists; the local stack is for pgTAP and migration
  checks only. `seed.sql` is applied to hosted only when the owner says so, and must stay
  idempotent so a re-run changes nothing.

## Commands (from `be/`; Docker Desktop + `npx supabase`)

| Purpose | Command | Notes |
|---|---|---|
| Start | `source ~/.zshrc && npx supabase start -x vector,logflare,studio` | API :56321, DB :56322, Mailpit :56324 (non-default ports in `supabase/config.toml`) |
| Rebuild | `npx supabase db reset` | Migrations + `seed.sql`, on the local check stack. |
| Tests | `npx supabase test db` | pgTAP. Must pass after any SQL change. |
| New migration | `npx supabase migration new <name>` | Produces `supabase/migrations/<timestamp>_<name>.sql` |
| Keys | `npx supabase status` | Local publishable key, if the app is ever pointed at the local stack. |
| Stop | `npx supabase stop` | |

## Non-negotiable rules

- **RLS on every table.** No table ships without row-level security and explicit policies,
  plus pgTAP tests proving a trainee can't read another trainee's data and anon gets nothing it
  is not meant to see.
- **The server decides.** Attendance records, booking state, membership state and staff rights
  change only inside functions that check `auth.uid()` and the current state. Direct writes to
  those columns are revoked from `authenticated`.
- **Mocks follow server rules.** When a rule changes here, the matching mock repository in
  `../fe` must change in the app's next package; say so in the handoff and the memory entry.
- **No secrets.** The `service_role` key and any API key live in Supabase project settings or
  Edge Function secrets, never in SQL, seed, tests, config or notes.
- **Privacy.** A trainee's phone number, attendance history and notes are readable by club
  staff and that trainee only.
- **Honest data.** Counts and streaks come from real rows.
- **Free tier limits are a design input.** Keep the schema small, avoid pg_cron-heavy jobs
  and large storage; note anything that would need a paid plan in `../docs/decisions.md`.

## Error contract

Functions fail through `private.fail(p_code, p_message)`, which raises with a custom SQLSTATE
the app maps in `fe/lib/core/supabase/supabase_errors.dart`:

| SQLSTATE | Meaning |
|---|---|
| `BXVAL` | validation: bad input, wrong state for the transition |
| `BXPRM` | permission: not staff, not the owner of the row |
| `BXNTF` | not found (or hidden by RLS) |
| `BXDUP` | duplicate: attendance already marked, slot already booked |

New errors reuse these. A new code is added only together with its mapping and UI copy in the
app, in the same plan.

## Layout

```
supabase/
  config.toml        local stack config (ports 563xx)
  migrations/        append-only
  tests/             pgTAP: 000_helpers first, then one file per area
  seed.sql           local accounts and data (idempotent)
  functions/         Edge Functions, if any
```

## SQL conventions

- Schemas: tables in `public`; helpers, security-definer internals and audit in `private`
  (not exposed through the API). `private.is_staff()`, `private.clock()`, `private.fail()`,
  `private.set_updated_at()` are the shared helpers once created; reuse them.
- Every table: `alter table ... enable row level security`, named policies
  `<table>_<verb>_<who>` (`attendance_select_staff`), `revoke` of direct writes where a
  function owns the transition, `updated_at` via `private.set_updated_at`.
- Transitions are `public.<verb>_<noun>(p_...)` functions, `security definer`, `set
  search_path`, first lines check `auth.uid()` and the current state, failures through
  `private.fail`. Read the clock through `private.clock()` so tests can pin time.
- Enums are Postgres enum types whose wire values match the app's enums; the app parses unknown
  values safely, but add enum values only with the owner's approval.
- Naming: `snake_case` everywhere, `p_` prefix on function parameters, singular column names,
  plural table names, `<table>_id` foreign keys.
- One migration per approved change, named by `supabase migration new`. Idempotent where
  Postgres allows. No destructive statement (drop, truncate, delete) without a backlog item and
  the owner's explicit approval.
- Tests: every policy and transition gets pgTAP assertions in the file for its area: the
  positive path, the denial for the other party, the anon denial, and the SQLSTATE on the
  failing path (`throws_ok` with the code). Keep `plan(n)` correct.
- Comments say why, one line, no em-dashes, no emoji, never the user's request.
- Report outcomes as they are: if `npx supabase test db` did not run (no Docker, no Node), say
  so. The CLI is always `npx supabase`, never a global install; shells start with
  `source ~/.zshrc`.

## Agent workflow

The product is worked on from the repo root, whose `.claude/CLAUDE.md` holds the tier split
(Fable as Architect, Opus `developer`, Sonnet `assistant`; Haiku never), the routing and git
rules, the agents, the `/build` skill, the `tiered-build` workflow and the handoff packages.
This file is the backend's rules and conventions and is loaded whenever work touches files here.

- The Architect gets the owner's approval for any schema change before writing a package. Any
  change under `supabase/` goes to the `developer` agent with a package (the Architect edits
  docs directly). A package names the migration file, every table and policy, the function
  signatures, the SQLSTATEs raised, the pgTAP assertions, the approval date and the app impact.
- pgTAP assertions, stack runs and `supabase test db` smoke go to the `assistant`.
- The Architect reviews `git diff -- be/supabase docs/be` against the rules above, updates
  `docs/` and `docs/memory/`, names the app-side change (`../fe`: Supabase repository and mock
  repository) the `fe` package must make, and makes the checkpoint commit.
