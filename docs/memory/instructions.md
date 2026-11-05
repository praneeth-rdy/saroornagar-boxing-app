# Owner instructions

A dated record of the working instructions the owner gives, close to their words, with where
each was applied. Newest first. Settled instructions are promoted into the relevant
`CLAUDE.md` or `docs/` file; the entry here stays as the record.

## 2026-11-05

| Instruction (owner's words, condensed) | Applied in |
|---|---|
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
