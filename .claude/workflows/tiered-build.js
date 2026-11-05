export const meta = {
  name: 'tiered-build',
  description: 'Opus implements each handoff package in its area (fe or be), Sonnet writes tests and smoke-checks every touched area, Opus repairs failures; returns a compact report for the Architect to review',
  whenToUse: 'Invoked by /build after the Architect has written handoff packages under .claude/handoffs/<run>/. Not for planning or review - those stay with Fable in the main session.',
  phases: [
    { title: 'Implement', detail: 'developer (Opus) - one agent per handoff package, in its area', model: 'opus' },
    { title: 'Test', detail: 'assistant (Sonnet) - tests per package where tests: true', model: 'sonnet' },
    { title: 'Smoke', detail: 'assistant (Sonnet) - flutter analyze + test / supabase test db per touched area', model: 'sonnet' },
    { title: 'Fix', detail: 'developer (Opus) - repair smoke failures, bounded rounds', model: 'opus' },
  ],
}

// args: {
//   handoffDir: string,
//   tasks: [{ id: string, area: 'fe' | 'be', file: string, title: string, tests?: boolean }],
//   parallel?: boolean,      // default false - packages usually depend on each other (be before fe)
//   maxFixRounds?: number,   // default 2
//   buildApk?: boolean,      // default false - adds `flutter build apk --debug` to the fe smoke
//   root?: string,           // default '.' - the repo root, so paths resolve when the session cwd is a subfolder
// }

const AREAS = ['fe', 'be']
const SHELL = 'Start every shell command with `source ~/.zshrc` so nvm\'s Node is on PATH.'

const DEV_SCHEMA = {
  type: 'object',
  properties: {
    status: { type: 'string', enum: ['DONE', 'PARTIAL', 'BLOCKED'] },
    area: { type: 'string' },
    files: { type: 'array', items: { type: 'object', properties: { path: { type: 'string' }, change: { type: 'string' } }, required: ['path', 'change'] } },
    acceptance: { type: 'array', items: { type: 'object', properties: { criterion: { type: 'string' }, ok: { type: 'boolean' }, note: { type: 'string' } }, required: ['criterion', 'ok'] } },
    checks: { type: 'string' },
    appImpact: { type: 'string' },
    notes: { type: 'string' },
  },
  required: ['status', 'files', 'acceptance', 'checks'],
}

const CHECK_SCHEMA = {
  type: 'object',
  properties: {
    status: { type: 'string', enum: ['PASS', 'FAIL', 'DONE', 'BLOCKED'] },
    area: { type: 'string' },
    ran: { type: 'array', items: { type: 'string' } },
    result: { type: 'string' },
    failures: { type: 'array', items: { type: 'object', properties: { file: { type: 'string' }, line: { type: 'integer' }, message: { type: 'string' } }, required: ['message'] } },
    files: { type: 'array', items: { type: 'string' } },
    notes: { type: 'string' },
  },
  required: ['status', 'ran', 'result', 'failures'],
}

const handoffDir = args?.handoffDir
const tasks = Array.isArray(args?.tasks) ? args.tasks : []
const parallel = Boolean(args?.parallel)
const maxFixRounds = Number.isInteger(args?.maxFixRounds) ? args.maxFixRounds : 2
const buildApk = Boolean(args?.buildApk)
const root = (args?.root || '.').replace(/\/$/, '')

if (!handoffDir || tasks.length === 0) {
  throw new Error('tiered-build needs args.handoffDir and a non-empty args.tasks array (see .claude/skills/build/SKILL.md)')
}
for (const t of tasks) {
  if (!AREAS.includes(t.area)) throw new Error(`task ${t.id}: area must be one of ${AREAS.join(', ')}`)
}

const areaRules = (area) => `${root}/${area}/CLAUDE.md`
const areaArch = (area) => `${root}/docs/${area}/architecture.md`

const areaGuidance = (area) =>
  area === 'be'
    ? `SQL goes in a NEW migration file, never an edit to an existing one; RLS, named policies, private.fail codes and pgTAP assertions as the package specifies. Stop with STATUS: BLOCKED if the package lacks the owner's approval date for a schema change. ${SHELL} Run npx supabase db reset and npx supabase test db from ${root}/be (never a global supabase binary); if Docker or Node is unavailable, say so.`
    : 'If the package says a server rule changed, change the matching mock repository in the same task. Stop with STATUS: BLOCKED if it needs a server function or column that does not exist yet under be/supabase/migrations. Run flutter analyze and dart format on touched files; run build_runner if you edited freezed/json models.'

const implementPrompt = (t) => `Implement the handoff package at ${root}/${t.file} ("${t.title}") in the area ${t.area} (${root}/${t.area}).
Read ${root}/.claude/CLAUDE.md, then ${areaRules(t.area)} and ${areaArch(t.area)}, then the package, then only the files it lists. Run commands from ${root}/${t.area}/.
${areaGuidance(t.area)}
If you add, remove or rename a file, provider, route, table, policy, function or SQLSTATE, update the matching row in ${areaArch(t.area)}.
Do exactly what the package specifies. Do not write tests unless the package assigns them to you.
Work on the currently checked-out branch: no worktrees, no branches, no git add/commit/stash/push.`

const testPrompt = (t, dev) => `Write tests for the change described in the handoff package at ${root}/${t.file} ("${t.title}") in the area ${t.area} (${root}/${t.area}).
The developer reports these files changed: ${dev.files.map((f) => f.path).join(', ') || '(none listed)'}.
Read ${root}/.claude/CLAUDE.md, ${areaRules(t.area)} (tests section) and the package's Acceptance criteria + Verification sections; test those behaviours.
${t.area === 'be'
    ? `Add pgTAP assertions to the area's file under supabase/tests (positive path, other party denied, anon denied, SQLSTATE on failure), keep plan(n) correct, ${SHELL} run npx supabase test db from ${root}/be. Never modify supabase/migrations.`
    : 'Unit tests mirror lib/ paths under test/; flow tests use the app harness under test/helpers/. Override providers through ProviderScope and the mock scenario switch; never modify lib/. Run flutter test on the files you wrote.'}
No worktrees, no branches, no git add/commit/stash/push.`

const smokeCommands = (area) =>
  area === 'be'
    ? `${SHELL} npx supabase db reset; npx supabase test db (start the stack with npx supabase start -x vector,logflare,studio if it is not running; Docker Desktop must be running; never a global supabase binary)`
    : `flutter analyze; flutter test${buildApk ? '; flutter build apk --debug' : ''}`

const smokePrompt = (area) => `Smoke-check the working tree of the area ${area} (run from ${root}/${area}/).
Run, in order: ${smokeCommands(area)}.
Compare against the baseline recorded in ${root}/docs/memory/current.md (pre-existing issues are NOT failures; new ones are).
Report PASS only if everything passes. If the toolchain itself is broken (SDK mismatch, pub resolution failure, no Docker or Supabase CLI), report BLOCKED with the one-line cause instead of a pass. List at most 5 failures as file:line - message. Do not edit any files, do not touch git.`

const fixPrompt = (area, smoke, round) => `Fix round ${round} in the area ${area}: the smoke check failed on the current working tree.
Failures reported by the assistant:
${smoke.failures.map((f) => `- ${f.file || '?'}${f.line ? ':' + f.line : ''} - ${f.message}`).join('\n')}
Assistant notes: ${smoke.notes || '(none)'}
The change being built is described by the handoff packages in ${root}/${handoffDir}/ (read plan.md and the task files for ${area}). The area is at ${root}/${area}.
Fix only what is needed to make these failures pass, within the scope of those packages. ${area === 'be' ? `A SQL fix is a new migration file, never an edit to an existing one; ${SHELL} run npx supabase test db yourself.` : 'Run flutter analyze and flutter test yourself before returning.'} No worktrees, no branches, no git add/commit/stash/push.`

// ---- Implement (+ per-package tests), sequential by default ----------------------------------
phase('Implement')
log(`${tasks.length} handoff package(s) in ${handoffDir}${parallel ? ' - parallel' : ' - sequential'}`)

const implementOne = (t) =>
  agent(implementPrompt(t), { label: `dev:${t.id} ${t.title}`, phase: 'Implement', agentType: 'developer', model: 'opus', schema: DEV_SCHEMA })

const testOne = (t, dev) =>
  agent(testPrompt(t, dev), { label: `test:${t.id} ${t.title}`, phase: 'Test', agentType: 'assistant', model: 'sonnet', schema: CHECK_SCHEMA })

const results = []
if (parallel) {
  const out = await pipeline(
    tasks,
    (t) => implementOne(t),
    async (dev, t) => {
      if (!dev) return { task: t, dev: null, tests: null }
      const tests = dev.status === 'DONE' && t.tests ? await testOne(t, dev) : null
      return { task: t, dev, tests }
    },
  )
  results.push(...out.filter(Boolean))
} else {
  for (const t of tasks) {
    const dev = await implementOne(t)
    if (!dev) { results.push({ task: t, dev: null, tests: null }); continue }
    log(`dev:${t.id} (${t.area}) -> ${dev.status} (${dev.files.length} file(s))`)
    if (dev.status === 'BLOCKED') {
      results.push({ task: t, dev, tests: null })
      log(`stopping: task ${t.id} is BLOCKED - ${dev.notes || 'see acceptance'}`)
      break
    }
    const tests = dev.status === 'DONE' && t.tests ? await testOne(t, dev) : null
    if (tests) log(`test:${t.id} -> ${tests.status} - ${tests.result}`)
    results.push({ task: t, dev, tests })
  }
}

const blocked = results.filter((r) => !r.dev || r.dev.status === 'BLOCKED')
if (blocked.length === results.length) {
  return { outcome: 'BLOCKED', handoffDir, tasks: results, smoke: {}, fixRounds: 0 }
}

// ---- Smoke -> fix loop, per touched area ------------------------------------------------------
phase('Smoke')
const touchedAreas = [...new Set(results.filter((r) => r.dev && r.dev.status !== 'BLOCKED').map((r) => r.task.area))]
const smoke = {}
let fixRounds = 0
for (const area of touchedAreas) {
  let s = await agent(smokePrompt(area), { label: `smoke:${area}:0`, phase: 'Smoke', agentType: 'assistant', model: 'sonnet', schema: CHECK_SCHEMA })
  let rounds = 0
  while (s && s.status === 'FAIL' && rounds < maxFixRounds) {
    rounds += 1
    fixRounds += 1
    log(`smoke FAIL in ${area} (${s.failures.length} failure(s)) - fix round ${rounds}/${maxFixRounds}`)
    await agent(fixPrompt(area, s, rounds), { label: `fix:${area}:${rounds}`, phase: 'Fix', agentType: 'developer', model: 'opus', schema: DEV_SCHEMA })
    s = await agent(smokePrompt(area), { label: `smoke:${area}:${rounds}`, phase: 'Smoke', agentType: 'assistant', model: 'sonnet', schema: CHECK_SCHEMA })
  }
  if (s && s.status === 'FAIL') log(`${area} still failing after ${maxFixRounds} fix round(s) - handing back to the Architect`)
  smoke[area] = s
}

const statuses = Object.values(smoke).map((s) => (s ? s.status : 'UNKNOWN'))
const outcome = statuses.includes('FAIL') ? 'FAIL'
  : statuses.includes('BLOCKED') ? 'BLOCKED'
    : statuses.includes('UNKNOWN') ? 'UNKNOWN'
      : blocked.length ? 'PARTIAL' : 'PASS'

return { outcome, handoffDir, tasks: results, smoke, fixRounds }
