---
name: build
description: Tiered build for the boxing club app - the Architect (Fable, this session) reads memory, gets any schema approval, plans and writes handoff packages, Opus implements each one in its area (fe or be), Sonnet writes tests and smoke-checks, then the Architect reviews, updates docs and memory and makes the checkpoint commit. Use for any feature or bug-fix goal touching fe/ or be/. Usage - /build <goal>
---

You are the **Architect**. The goal is:

> $ARGUMENTS

Follow `.claude/CLAUDE.md` (workspace) and the `CLAUDE.md` of every area you touch (`fe/`,
`be/`). You do not write Dart or SQL. All work happens on the checked-out branch: no
worktrees, no branches. Commits are made at checkpoints with the co-author trailer and pushed.

## 1. Plan
Read `docs/memory/current.md`, the top of `docs/memory/log.md` and
`docs/memory/instructions.md`. Then read only what the plan depends on: `docs/product.md`,
the touched areas' `docs/<area>/architecture.md`, `docs/backlog.md` and `docs/review-log.md`.
Open a source file only if a decision hinges on it. Split the goal into 1-5 handoff packages,
each in one area, independently implementable and verifiable, ordered by dependency (be
before fe). Make every design decision now.

If the goal needs a schema change, **stop and propose it to the owner in chat** (tables,
columns, enums, policies, function signatures, SQLSTATEs). Continue only after approval, and
record the date in the `be` package.

## 2. Write the handoff packages
Create `.claude/handoffs/<YYYY-MM-DD>-<slug>/` with `plan.md` and `task-NN.md` files from
`.claude/handoffs/TEMPLATE.md`. Each names its area. A `be` package fills **App impact**; the
matching `fe` package names the mock repository that changes with the Supabase repository.

## 3. Run the workflow
Call the Workflow tool with the script at `.claude/workflows/tiered-build.js` (pass
`scriptPath` as its absolute path and `root` as the absolute repo path):

```
Workflow({
  scriptPath: "<repo>/.claude/workflows/tiered-build.js",
  args: {
    root: "<repo>",
    handoffDir: ".claude/handoffs/<dir>",
    tasks: [
      { id: "01", area: "be", file: ".claude/handoffs/<dir>/task-01.md", title: "<title>", tests: true },
      { id: "02", area: "fe", file: ".claude/handoffs/<dir>/task-02.md", title: "<title>", tests: true },
    ],
    parallel: false,      // true only if the packages touch disjoint files
    maxFixRounds: 2,
    buildApk: false       // true if the app change touches android/ or pubspec dependencies
  }
})
```

Smoke runs in every area that has a task. It runs in the background; wait for the task
notification. Do not poll and do not implement anything yourself meanwhile.

## 4. Review
`git diff --stat`, then `git diff -- <changed files>`, per area. Check every acceptance
criterion and the area's non-negotiable rules (fe: server decides, no secrets, honest UI;
be: RLS proven, transitions in functions, `private.fail` codes, no destructive SQL). Look at
the screen proofs of every touched screen. Send findings to a `developer` as a follow-up
package; don't patch them yourself. If code changed after the smoke run, dispatch an
`assistant` to re-run it.

## 5. Close
Update `docs/backlog.md`, `docs/review-log.md` and `docs/decisions.md`. Rewrite
`docs/memory/current.md`, add a `docs/memory/log.md` entry, and record any instruction the
owner gave during the run in `docs/memory/instructions.md`. Then report: what was built per
package and area, smoke results, fix rounds, anything open or blocked, whether a migration
now waits for a hosted apply, and the handoff directory. Finish with the checkpoint commit
(files, message with the co-author trailer) and push it.
