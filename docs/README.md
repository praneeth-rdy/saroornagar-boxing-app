# Knowledge base

Two layers, and the difference matters:

- **`docs/` (this folder, except `memory/`) is long-term memory.** Curated, reviewed, true for
  as long as it is not corrected. Nothing lands here until it has stopped changing.
- **`docs/memory/` is running memory.** Where the work stands today, what was tried, toolchain
  quirks, open questions, the owner's instructions. Anyone may write to it; entries are
  promoted into a settled file or deleted.

Both layers are tool-agnostic: written for a human, for Claude Code, for Codex, for any
assistant. Claude Code wiring (agents, handoff packages, the tiered workflow) lives in
`.claude/`.

| File | What it holds | Who updates it, when |
|---|---|---|
| `product.md` | What the product is for, who it is for, roles, flows, scope, open product questions. The only source of requirements. | Architect when the owner decides something. |
| `fe/architecture.md` | Layout, module map per feature, routes, data flow, error boundary of the Flutter app. | Whoever changes structure. Developer agents update it in the same task. |
| `be/architecture.md` | Schema map: tables, policies, functions, SQLSTATEs, Edge Functions, what is applied on hosted. | Whoever changes the schema, in the same task. |
| `backlog.md` | Prioritised list of work with status, plus open decisions. | Architect at planning and review time. |
| `review-log.md` | Dated review findings with status and a pointer to the fix. | Architect after each review round. Never re-report an item already listed. |
| `decisions.md` | Short design decisions and the reason, newest first. | Architect when a choice is made that a later reader might question. |
| `memory/current.md` | The live snapshot: what is in flight, the next step, what is blocked and on whom. | Overwritten at the end of every session. Keep it under one screen. |
| `memory/log.md` | Dated entries, newest first: what happened in a session and what it means for the next. | Appended at the top. Five to ten lines per entry. |
| `memory/instructions.md` | The owner's working instructions, dated, close to their words, with where each was applied. | Appended the same session an instruction is given. |
| `memory/notes/<slug>.md` | One topic per file: a gotcha, a toolchain or Supabase behaviour, a dead end, an open question. | Created and deleted freely. Delete when promoted or no longer true. |

## Promotion: memory is temporary, docs are permanent

| When a note becomes | It belongs in |
|---|---|
| a fact about how the app is put together | `fe/architecture.md` |
| a fact about the schema, a policy, a function or the hosted apply | `be/architecture.md` |
| a design call a later reader might question | `decisions.md` |
| a piece of work to schedule | `backlog.md` |
| a review finding | `review-log.md` |
| product direction or scope | `product.md` |
| a working rule for assistants | `.claude/CLAUDE.md` or the area's `CLAUDE.md` (the `instructions.md` entry stays) |

A fact lives in exactly one place. When something moves from memory to docs, delete the
memory copy.

## Rules

- Facts and pointers, not narrative. File paths and IDs (`A-03`, `R1-05`), not prose.
- No raw build or test output. Summarise as `file:line - message`, five lines at most.
- No secrets: no keys (not even the anon key), no passwords, no personal data of real people.
- Record what was verified and how, and what was only assumed.
- House style: no em-dashes, no emoji, plain ASCII.
- When memory and a settled file disagree, the settled file wins. Fix whichever one is wrong
  in that same session.
