# Decisions

Newest first. Short: the decision, the reason, the alternatives considered.

## 2026-11-05

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
