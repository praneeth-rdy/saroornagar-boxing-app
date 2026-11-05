# Saroornagar boxing club app

People management app for a boxing club in Saroornagar: coaches take, view and manage trainee
attendance, and people book trial sessions. Android app in Flutter, Supabase (free tier) as
the only backend. One repository, three areas:

| Folder | Holds |
|---|---|
| `fe/` | The Flutter app (Android). `fe/CLAUDE.md` has its rules, commands and code guidelines. |
| `be/` | The Supabase backend: `supabase/` migrations, RLS, functions, pgTAP, seed, local config. `be/CLAUDE.md` has its rules. |
| `docs/` | Product reference, architecture maps, backlog, decisions, review log, and the running memory (`docs/memory/`). `docs/README.md` has the protocol. |

Requirements are being gathered in `docs/product.md`; nothing is built beyond the scaffold
until the design direction and the first scope are settled there.

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
