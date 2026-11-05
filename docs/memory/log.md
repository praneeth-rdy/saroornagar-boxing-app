# Work log

Newest first. One entry per work session: what changed, what it means for the next session.

## 2026-11-05: scaffold, workflow wiring, design canvas, interview started

- Repo scaffolded as a monorepo: `fe/` (Flutter empty template, Android only), `be/`
  (`supabase init`, ports 563xx), `docs/` with the protocol and empty maps, `.claude/` with
  the workspace rules, agents, `/build`, `tiered-build.js` and the handoff template, adapted
  from the owner's other project with two differences: co-author trailer on commits, no
  deploy-on-push (free tier).
- Supabase skills copied into `.claude/skills/` and `.agents/skills/` (gitignored;
  `skills-lock.json` committed). `.mcp.json` written without a project ref (gitignored;
  `.mcp.json.example` committed).
- Design-directions canvas published (four directions, each with a palette card, a Today
  attendance screen and a Book-a-trial screen).
- Requirements interview opened with the broad questions; answers go to `docs/product.md`.
