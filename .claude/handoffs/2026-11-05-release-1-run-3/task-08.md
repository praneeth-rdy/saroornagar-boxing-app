# Task 08 - Senior fee tier is 800

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** be
- **Depends on:** none
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates the pgTAP assertions in the same task)
- **Schema change approved by the owner:** 2026-11-05, "Let's also have the amount as a dropdown of 500 or 800." (no table change; the tier helper's senior amount)
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_fee_tier_800.sql`
- **Owner request this serves:** the payment screen request above (2026-11-05). Other chat threads (logo) are unrelated.

## Goal
Seniors (15 and above) pay 800 a month, juniors 500; the fee status list reports 800 due.

## Context the worker needs
`be/CLAUDE.md`; migration `20261105080602_fees_reports.sql` (`private.fee_tier_amount`);
`tests/040_fees_reports.sql` (tier assertions and fee status expectations that say 1000).

## Files
- `be/supabase/migrations/<timestamp>_fee_tier_800.sql` - create - `create or replace function private.fee_tier_amount` with 800 for seniors; same signature, immutable, grants unchanged
- `be/supabase/tests/040_fees_reports.sql` - modify - every 1000 expectation that comes from the tier becomes 800 (payments recorded as 1000 in fixtures may stay as amounts)
- `docs/be/architecture.md`, `docs/product.md` (Fees lines: 800 for seniors, owner 2026-11-05) - modify

## Acceptance criteria
- [ ] Tier helper: 14y364d -> 500, 15y -> 800, null -> null (pgTAP).
- [ ] `npx supabase db reset` and `npx supabase test db` pass.

## Verification
`source ~/.zshrc && cd be && npx supabase db reset && npx supabase test db`.
