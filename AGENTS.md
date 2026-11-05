# Working on the boxing club app

Applies to any assistant (Claude Code, Codex, an editor agent) and to humans.

## Read before you start

1. `README.md`: what the app is, how to run it, the three areas.
2. `docs/memory/current.md`, then the top of `docs/memory/log.md`: where the work stands.
3. `docs/product.md`, then `docs/fe/architecture.md` and `docs/be/architecture.md`.
4. `docs/backlog.md` and `docs/review-log.md`: what is planned and what is known broken.
5. `.claude/CLAUDE.md` (workspace rules), then `fe/CLAUDE.md` or `be/CLAUDE.md` for the area
   you touch: the non-negotiable rules, commands and code guidelines. They apply whatever tool
   you use; only the tiered agent workflow is Claude Code specific.
6. Any `docs/memory/notes/` file naming the area you are about to touch.

## Write before you stop

`docs/README.md` has the protocol. In short: rewrite `docs/memory/current.md`, add a dated
entry to `docs/memory/log.md`, add a `docs/memory/notes/<slug>.md` for anything a later
reader would otherwise rediscover, update the architecture map if the structure changed, and
mark the backlog item done.

## Standing rules

- Work on the checked-out branch; no worktrees or new branches. Commit at logical checkpoints
  with the trailer `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>` and push.
- Record every working instruction the owner gives in `docs/memory/instructions.md` the same
  session, then apply it.
- No new dependencies without the owner agreeing to one by name and version.
- Schema changes are proposed and approved before a migration is written; migrations are
  append-only; applying one to the hosted project is the owner's call.
- No secrets in the repo. Only the Supabase anon/publishable key may appear in
  `fe/config/*.json`.
- Do not hallucinate: ask when a product fact is missing; `docs/product.md` is the only source
  of requirements.
