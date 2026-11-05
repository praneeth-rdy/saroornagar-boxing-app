# Work log

Newest first. One entry per work session: what changed, what it means for the next session.

## 2026-11-05 (second session): release 1 built, applied to hosted, installed on the device

- Owner approved the release 1 schema; design A confirmed; standing /build opt-in and
  "Opus implements, Architect plans" reaffirmed (`instructions.md`).
- Backend (run 1a + task-08): 5 migrations, 501 pgTAP assertions, Edge Function
  `admin-staff`. Review R1-01 (self sign-up could become staff) fixed before the hosted apply.
- App (run 1b + run 2): theme A kit, config, errors, sign-in, shell, Today, Trainees, Trials,
  Fees and reports, Staff admin; 321 tests; 47 proofs reviewed (R2-01..R2-07 fixed).
- Hosted: all 5 migrations applied through the MCP (versions are MCP timestamps, B-10),
  `admin-staff` deployed (v1), first admin user created (login in `creds.md`). Advisors:
  no RLS gaps; notes in `notes/hosted-advisors-2026-11-05.md`.
- Device: upload keystore generated (gitignored, passwords in `creds.md`), release signing
  wired, signed APK (build 19) installed on the owner's phone (model I2214).
- Still with the owner: hosted dashboard steps (Phone provider on, sign-ups off), the
  Android application id (D-04), B-05/B-06 product calls, product.md open question 7.
- Next session: device walkthrough against hosted with the admin login, then the follow-ups
  A-08..A-11, B-05, B-06, B-09.

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
- Requirements interview rounds 1 to 4 done and recorded in `docs/product.md` (release 1 =
  guest trial booking + staff app, no trainee view; phone + password sign-in; admin manages
  staff; monthly fee tiers by age, record only; design direction A).
- Hosted Supabase project `qgqmnaxdxuezjlexlfpw` created by the owner; publishable key in
  `fe/config/*.json`; CLI logged in and `be/` linked. `creds.md` (gitignored) holds the
  details. MCP needs a relaunch and OAuth.
- Next session: get the schema yes (`notes/schema-proposal-release-1.md`) and the DB
  password, then write the run-1 packages and start `tiered-build`.
