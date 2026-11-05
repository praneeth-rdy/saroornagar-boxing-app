# Backlog sweep migration (be, 2026-11-05)

- `npx supabase db reset` failed with 42601 "syntax error at end of input" on a plpgsql body that
  had `if ... and v >= case p_slot when ... end then`: the CLI statement splitter seems to treat
  that `end` as closing a block. Assigning the value in a plain `if/else` first fixed it; avoid
  inline `case ... end` directly before `then` in migration function bodies.
- `book_trial` ended-batch check sits right after the past-date check, so the order is name,
  phone, slot, past date, ended batch, 30 days ahead, Sunday, ...; pgTAP proves "still open"
  without inserting rows by letting a later check (no age or DOB) fire instead.
- The fe mocks still throw `Trainee not found` / `This trainee is inactive` and their tests
  assert those strings; the fe package must change them with the history `starts_at`/`ends_at`.
