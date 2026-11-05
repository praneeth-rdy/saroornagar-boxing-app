# Owner instructions

A dated record of the working instructions the owner gives, close to their words, with where
each was applied. Newest first. Settled instructions are promoted into the relevant
`CLAUDE.md` or `docs/` file; the entry here stays as the record.

## 2026-11-05

| Instruction (owner's words, condensed) | Applied in |
|---|---|
| "I need production grade quality please." | Handoff packages: full validation, RLS proofs, error paths, proofs before landing; `.claude/CLAUDE.md` routing rule 7 and area rules already demand it. |
| "Be optimal on your tokens while not overdoing or compromising on the quality." / "I don't want you to waste your precious tokens. You are the mind here ... while Opus subagents implement." | Reaffirms routing rule 8: the Architect writes decisions (plan, packages, reviews) tightly; every bulk write goes to Opus or Sonnet. |
| "Use /build wherever needed - take this as a standing instruction" | Standing opt-in confirmed; `.claude/CLAUDE.md` routing rule 4 (already recorded 2026-11-05). |
| "I've chosen A. Ivory & Graphite option" | `docs/decisions.md` (design A), `docs/backlog.md` D-01; applied in the fe theme package (run 1b task-06). |
| "Consider my approval. Proceed with the implementation." (release 1 schema proposal) | `.claude/handoffs/2026-11-05-release-1-run-1/plan.md` and every be package (approval date 2026-11-05). |
| "We don't need arrived tick. Yes, DOB is optional." | `docs/product.md` Confirmed (trainee record, trial bookings). |
| "Keep it inside the repo gitignored" (the credentials file) | `creds.md` at the repo root, listed in `.gitignore`; `.claude/CLAUDE.md` Toolchain. |
| Round 4 answers: "Monthly fee. 500 per month for juniors below the age of 15 and 1000 per month for seniors >= age 15. Just record the payments."; trial form = name, phone, date, session, age/DOB, optional note; design A; owner creates the Supabase project. | `docs/product.md`, `docs/decisions.md` (A), `docs/backlog.md` D-01, D-03, S-04. |
| "Let the admin user have the ability to reset password of any user, block access, etc and also be able to manage the coaches/staff accounts" | `docs/product.md` Confirmed (Roles); replaces the earlier "same powers for now". |
| Round 3 answers: trainee fields (name, optional photo/phone/joining date, active/inactive); trials have no confirmation, the slot only informs the coach; morning 6:00-8:30 am, evening 5:30-8:00 pm; reports: per-trainee history, monthly summary, fee status list. | `docs/product.md` Confirmed. |
| "Let's not have trainees view for now. Let's only build for guest slot booking and coach/staff/admin." | `docs/product.md` Release 1 scope; trainee view deferred; backlog D-02 settled. |
| "Let's have phone-number & password login" (after a chat on free phone OTP options) | `docs/product.md` Confirmed: phone + password for staff and trainees, no SMS provider. |
| "use /build as needed" | Standing opt-in: the Architect runs the `tiered-build` workflow whenever a goal needs several packages or an implement-test-fix loop. `.claude/CLAUDE.md` routing rule 4. |
| "You are the main architect & the brain behind the work. Opus needs to do the implementation. Optimise the tokens burnt on you." | `.claude/CLAUDE.md` routing rule 8: the Architect plans, packages and reviews; all bulk writing goes to Opus (or Sonnet for mechanical work). First applied to the design canvas: directions B, C, D written by an Opus worker. |
| "Empty repo ... would work as a mono repo for a boxing club people management app that's flutter mobile app (android) with supabase free tier project/organisation. To take, view & manage attendance of the trainees & let people book trial sessions." | `docs/product.md` (Confirmed), `README.md`, `.claude/CLAUDE.md`. |
| "Create separate directories for FE, BE & docs." | `fe/`, `be/`, `docs/` (running memory under `docs/memory/`). |
| "Setup .claude with a tiered build workflow similar to how we have it on Brutal. Take all the instructions on coding, development practices, guidelines, etc from the Brutal project into this including the setup of Supabase MCP & the writing the code directly on the branch & that to use coauthoring inside commit message." | `.claude/CLAUDE.md`, `agents/`, `skills/build`, `workflows/tiered-build.js`, `handoffs/TEMPLATE.md`, `fe/CLAUDE.md`, `be/CLAUDE.md`, `.mcp.json(.example)`. Git rules: checked-out branch, checkpoint commits with `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`, push at once. |
| "Instantiate a flutter app inside FE & supabase project on BE." | `fe/` via `flutter create --empty --platforms android`; `be/` via `npx supabase init`. The hosted Supabase project waits on the organisation, region and login (backlog S-04). |
| "Interview me on the requirements starting with broader & narrowing down as we go. Do not hallucinate." | `docs/product.md` Open questions; interview rounds in chat; nothing assumed. |
| "Before building anything - let's create some artifacts to see the design options. I want the design to be modern & classy. Apple like theme with two colors probably - but please provide me with other options too." | Design-directions canvas (four directions); decision D-01 in `docs/backlog.md`. |
