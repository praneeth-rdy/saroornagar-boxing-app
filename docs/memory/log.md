# Work log

Newest first. One entry per work session: what changed, what it means for the next session.

## 2026-11-05 (second session, evening): device feedback round

- Owner's device report (double mark, 4 sessions) led to R3-03 (session selection keyed by
  date, off-day marks refused; trigger not reproduced in tests) and R3-04 (summary counts
  held sessions only).
- Product changes from the owner, all shipped: presence-only marking with confirmed unmark
  and per-session reset (`unmark_attendance`, `reset_session_attendance`); monthly
  attendance shows classes attended, tap opens the log; logs grouped by date; "Student"
  wording; student form with "Add more details"; required marks instead of "(optional)";
  app named "Saroornagar Boxing"; senior tier 800; compact payment screen.
- Hosted: three migrations applied after the owner's "retry now" (the classifier had
  blocked one apply). Build 32 on the device and in Downloads.
- Open: B-12 (server messages say trainee), B-13 (extra session time in logs), A-08..A-11,
  B-05, B-06, B-09; dashboard steps (sign-ups off, {{ .Token }} in the reset template).

## 2026-11-05 (second session, late): email sign-in, logo, compact payments

- Release build had no INTERNET permission (R3-01); fixed, app named "Boxing Club".
- Owner switched staff auth to email + password with a forgot-password code (run 3):
  profiles by email, Edge Function by email, recovery screens; a GoTrue quirk (app_metadata
  written after the insert) that silently broke every created staff member was found and
  fixed (R3-02). Hosted: phone admin deleted, two migrations applied, function v2, admin
  re-created by email.
- Logo canvas (11 artboards); owner chose L5a Classic; badge + launcher icon in the app.
- Record-payment screen rebuilt compact with a 500 / 800 choice; senior tier is 800
  (server migration written, hosted apply blocked by the permission classifier: B-11).
- Workflow quirk recorded (`notes/workflow-relayed-request.md`): direct Agent dispatch when
  the owner chats mid-run.
- Next: owner approves B-11; dashboard steps (sign-ups off, {{ .Token }} in the reset
  template); device walkthrough; backlog A-08..A-11, B-05, B-06, B-09.

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
