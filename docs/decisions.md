# Decisions

Newest first. Short: the decision, the reason, the alternatives considered.

## 2026-11-05

- **Logo: L5a Classic badge** (owner's pick from the logo canvas
  https://claude.ai/artifact/FL6oyLDsUSpT7RSx7hQcbb; source `docs/design/logos/project/
  L5a-Classic.dc.html`): double ring, "SAROORNAGAR BOXING" on the upper arc, three dots on
  the lower arc, a blue glove at the centre; no "Club" anywhere. The app icon and small
  uses carry only the glove emblem, because ring text is unreadable below 48 px. Masters
  live in `docs/design/logos/final/`, app copies under `fe/assets/brand/`.

- **Staff sign in by email and password; forgot password by emailed code.** Phone sign-in
  needed the hosted Phone provider and had no self-service reset; email auth is on by
  default and the recovery OTP needs no deep link. The built-in sender's free-tier rate
  limit is accepted for a club; custom SMTP is a later decision. Alternative kept out: a
  recovery link with a custom URL scheme (needs redirect allow-listing and app links).

- **Design direction A, Ivory and Graphite** (owner's pick from the canvas
  https://claude.ai/artifact/FCyab964t4z3EBViU17TeE, files in `docs/design/directions/`):
  ground #F5F5F7, surface #FFFFFF, ink #1D1D1F, muted #6E6E73, accent #0A5FD6, Inter, radii
  12 and 16, 20 px gutters, no shadows, accent only on the action and the selected state.
  Alternatives B (dark), C (editorial), D (sporty) stay on the canvas as references.

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
