# fe proof sweep fixes (2026-11-05, run 2 task-08)

- Staff list (R2-01): with the compact `Blocked` chip first on the subtitle line, a 12-digit
  phone (`Coach · +91 98040 00011`) still ellipsizes at 390 px by about 14 px; row height
  matches the others. Keeping the whole phone needs the chip on the name line instead, or the
  role dropped on blocked rows: a design call left open.
- Today (R2-05): the bulk-absent bar now floats over the roster (`Stack`, ground-coloured
  background) and the list's bottom padding is bar height (sm + controlHeight + md) + lg. The
  `today_mark_error` proof captures mid-scroll, so the bar edge still cuts a row there.
- R2-03: the detail screen never had `maxLines`; the mid-word cut came from the fixture
  `substring(0, 500)`. `longNotesTrainee` now holds 7 whole sentences (489 chars).
- `fixtureTrials(date)` is unchanged (single-day tests assert its names); the proofs use the
  new `fixtureTrialDays(from, days:)` for distinct visitors, no Sundays, 3/1/2 per day.
