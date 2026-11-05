# Boxing club app workspace

People management app for a boxing club in Saroornagar: coaches take, view and manage the
attendance of their trainees, and people book trial sessions. Android first (Flutter), one
Supabase project (free tier) as the only backend. This folder is one git repository, a
monorepo, worked on from its root. The product requirements are being gathered in
`docs/product.md`; do not assume anything that file does not state.

| Folder | Holds | Its own rules |
|---|---|---|
| `fe/` | The Flutter app (`lib/`, `test/`, `config/`, `android/`). | `fe/CLAUDE.md` |
| `be/` | The Supabase backend: `supabase/` (migrations, RLS, functions, pgTAP, seed, local config). | `be/CLAUDE.md` |
| `docs/` | Settled knowledge (`product.md`, `fe/architecture.md`, `be/architecture.md`, `backlog.md`, `decisions.md`, `review-log.md`, design files) and the running memory under `docs/memory/` (`current.md`, `log.md`, `instructions.md`, `notes/`). | `docs/README.md` |
| `.claude/` | This file, `settings.json`, the agents, the `/build` skill, the `tiered-build` workflow and the handoff packages. | |

Settled knowledge stays in `docs/`; only what is still moving lives in `docs/memory/`.

## Start and finish every session

1. `git fetch` and fast-forward `main` when it is behind.
2. Read `docs/memory/current.md`, then the top of `docs/memory/log.md`, then
   `docs/memory/instructions.md` (the owner's standing instructions) and any
   `docs/memory/notes/` file naming the area you touch.
3. Read the `CLAUDE.md` of each area you will change (`fe/`, `be/`): it carries that area's
   non-negotiable rules, commands, conventions and code guidelines.
4. Finish by rewriting `docs/memory/current.md`, adding one `docs/memory/log.md` entry,
   updating `docs/` (architecture rows, backlog status, decisions, review log), and making the
   checkpoint commit (below).

## Owner instructions are recorded

When the owner gives a working instruction (how to work, a preference, a product or scope
decision, a correction), record it the same session in `docs/memory/instructions.md`: date,
the instruction in the owner's words or close to them, and where it was applied (which
CLAUDE.md, doc or code). Then apply it. Settled instructions are promoted into the relevant
CLAUDE.md or `docs/` file; the log entry stays as the record.

## Git rules (all tiers)

- **Work directly on the currently checked-out branch** (owner, 2026-11-05). Never create
  worktrees (no `isolation: "worktree"`, no `git worktree add`, no `EnterWorktree`), never
  create or switch branches unless the owner asks. The branch is `main` for now.
- **Commit at logical checkpoints without asking.** When a coherent piece of work is done (a
  setup step, a package landed and smoke-checked, a docs update), commit it and say so: files
  and message. `docs/memory/` is committed in the same checkpoint as the work it describes.
- **Every commit message ends with the co-author trailer** (owner, 2026-11-05: "use
  coauthoring inside commit message"):
  `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`. Subject says what changed for
  the user; body only when the subject does not say it all. No other trailers.
- **Push every checkpoint commit at once**; no confirmation is needed for `main`. Applying a
  migration to the hosted Supabase project is a separate step that happens only on the
  owner's word (see Toolchain).
- Never force-push `main`, never rewrite pushed history.

## Routing: where a change belongs

| Change | Area | Then |
|---|---|---|
| Screen, widget, provider, repository, model, test, config value | `fe/` | If it needs a server function or column that does not exist, the `be/` package comes first. |
| Table, column, enum, policy, function, SQLSTATE, seed, pgTAP, Edge Function | `be/` | The owner approves the schema change before the package is written. The package's **App impact** section becomes the `fe/` package: Supabase repository and mock repository change together. |
| Product scope, open question, work plan, review finding, design decision | `docs/` | Product direction lives once, in `docs/product.md`. |
| What is in flight, a quirk, a dead end, an owner instruction | `docs/memory/` | |

Cross-area order: backend first (approve, implement, pgTAP, commit), then the app (Supabase
repository, mock repository, screens, tests). Never let the app assume a server rule the server
does not enforce.

## Tiered model workflow

A strict three-tier split so that the expensive model never touches raw code or build logs.
The main session runs on **Claude Fable** (`.claude/settings.json`, machine-personal overrides
in the gitignored `settings.local.json`); that session is the Architect. **Haiku is never
used; Sonnet is the floor.**

| Tier | Model | Runs as | Does | Never does |
|---|---|---|---|---|
| **Architect** | Fable | this session | read memory, plan, interview the owner, get schema approvals, write handoff packages, dispatch workers, review diffs, update docs and memory, commit | write Dart or SQL, run builds or tests, read raw build output |
| **Developer** | Opus | `developer` agent (`.claude/agents/developer.md`) | implement one handoff package end-to-end in one area (Dart under `fe/lib`, SQL as a new migration under `be/supabase`), check its own work, return a compact summary | expand scope, make design decisions, dump logs |
| **Assistant** | Sonnet | `assistant` agent (`.claude/agents/assistant.md`) | unit/widget/flow tests, pgTAP assertions, fixtures, codegen, smoke runs (`flutter analyze`, `flutter test`, `supabase test db`), sweeps, log triage | non-trivial logic, design decisions |

### Routing rules for the Architect

1. **Any change under `fe/lib`, `fe/android`, `fe/test` or `be/supabase` goes to the
   `developer` agent** with a handoff package, even one-liners. You may edit `.claude/`,
   `docs/`, `README.md`, `AGENTS.md`, `fe/config/`, `fe/pubspec.yaml` metadata and
   `docs/memory/` directly.
2. **Schema changes need the owner's approval before the package is written.** Propose tables,
   columns, enums, policies and function signatures in chat; wait for a yes; record the date in
   the package.
3. **Tests, pgTAP, codegen, smoke checks, sweeps, log triage -> `assistant`.**
4. **Goals needing >= 2 packages or an implement -> test -> fix loop:** the `tiered-build`
   workflow (`.claude/workflows/tiered-build.js`; pass `root` as the absolute repo path) does
   this deterministically. The owner gave a standing opt-in on 2026-11-05 ("use /build as
   needed"), so run the Workflow tool whenever a goal qualifies, without asking them to type
   `/build`. If the Workflow tool is unavailable, run the same
   sequence with Agent calls: packages -> `developer` per package in dependency order ->
   `assistant` tests -> `assistant` smoke in each touched area -> `developer` fix round if it
   fails (max 2) -> your review.
5. Workers return **summaries, not logs**. If one returns a wall of output, ask for the 5-line
   version (SendMessage) instead of reading it.
6. **Final review is yours**: `git diff --stat`, then `git diff -- <files>`. Check the
   package's acceptance criteria and the area's non-negotiable rules. Send findings back to a
   `developer` as a follow-up package; don't patch them yourself.
7. **Screen proofs before landing.** No app run lands on test counts alone. The assistant
   renders PNG proofs of every touched screen in three states (no data, typical, heavy)
   through a screenshot harness under `fe/test/proofs/` once it exists, and the Architect looks
   at each image before the commit: no two sections show the same items, every state has a
   next action, the accent appears with intent, nothing looks tappable that is not. A run whose
   proofs show a problem gets a fix round, not a commit.
8. **Keep the Architect cheap (owner, 2026-11-05: "Opus needs to do the implementation.
   Optimise the tokens burnt on you").** The Architect reads, decides, writes packages and
   reviews; every bulk write (code, tests, long HTML or design files, large doc rewrites,
   repetitive edits) goes to an Opus `developer` or, when no judgement is needed, a Sonnet
   `assistant`. Open a source file only when the plan or the review depends on it. Never tail
   `flutter` or `supabase` output.

### Handoff packages

Template: `.claude/handoffs/TEMPLATE.md`. Write packages to
`.claude/handoffs/<YYYY-MM-DD>-<slug>/task-NN.md` (plus `plan.md`) and pass workers the
**path**. Every package names its area (`fe` or `be`). Be concrete: exact files, signatures
or SQL where they matter, acceptance criteria a test could check, an explicit out-of-scope
list, and for `be` packages the owner's approval date and the app impact.

## Toolchain

- Node is installed through nvm and is not on PATH in non-interactive shells: every shell
  command, in every tier, starts with `source ~/.zshrc`.
- The Supabase CLI is `npx supabase` run from `be/`; no global install. `db reset` and
  `test db` need Docker Desktop running. If Docker or the Flutter SDK (3.47.7+) is missing,
  checks are reported as not run, never as passed.
- The local Supabase stack uses ports 56321 (API), 56322 (DB), 56323 (Studio), 56324
  (Mailpit), 56320 (shadow), 56329 (pooler), set in `be/supabase/config.toml`, so it can run
  next to other projects' stacks.
- Credentials the Architect creates or receives (Supabase access token, DB password, test
  logins, API keys) are written to `creds.md` at the repo root, which is gitignored (owner,
  2026-11-05: "Keep it inside the repo gitignored"). Memory and docs name the file, never
  its contents. No credential goes into any committed file except the publishable Supabase
  key in `fe/config/*.json`.
- **One development database:** the hosted Supabase project is the only dev database once it
  exists. The app (`fe/config/dev.json`) and every manual test point at it. The local stack
  exists only to run `db reset` and `test db` for migration checks.
- The Supabase MCP (`.mcp.json`, machine-personal, gitignored; `.mcp.json.example` is the
  template) has full access to the hosted project for development. Schema changes are still
  migration files under `be/supabase/migrations`; applying one to the hosted project (through
  the MCP `apply_migration` with the file's exact name as its version, or `npx supabase db
  push`) happens only on the owner's say-so. The free tier has no Supabase branching and no
  deploy-on-push: the hosted apply is always an explicit step.
- Supabase skills (`supabase`, `supabase-postgres-best-practices` from
  `supabase/agent-skills`) are installed under `.claude/skills/` and `.agents/skills/` and
  gitignored; `skills-lock.json` records them. Reinstall on a new machine with the skills CLI
  (`npx skills add supabase/agent-skills`).

## House style, everywhere

No em-dashes, no emoji, plain ASCII. Comments say why, never who asked. Separate confirmed
facts, assumptions and open decisions; ask, do not invent answers to the open product
questions. Report outcomes as they are: if a check did not run, say so.
