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

1. Design direction (D-01) from the canvas.
2. Interview answers (product.md, Open questions 1 to 10).
3. Hosted Supabase project: organisation, region, name (D-03); then `supabase login` in an
   interactive shell or the MCP OAuth, and the project ref into `.mcp.json`.
4. The file outside the repo where credentials are kept (the other project uses a plain
   `creds.md` in the workspace folder).

## Resume checklist

1. Read `docs/product.md`; move answered questions to Confirmed.
2. Record the chosen direction in `docs/decisions.md` and the theme tokens plan.
3. Propose the first schema (trainees, batches, attendance, trial bookings) in chat for
   approval, then the first `/build` run.
