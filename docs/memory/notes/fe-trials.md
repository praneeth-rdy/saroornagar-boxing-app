# fe Trials (2026-11-05, run 2 task-03)

- `shared_preferences` 2.5.6 was already a transitive dependency (supabase_flutter); adding it
  direct changed only the lock entry. `SharedPreferencesDeviceKeyStore` uses the legacy
  `SharedPreferences.getInstance()`, so unit tests can seed it with
  `SharedPreferences.setMockInitialValues({})`.
- Done on the booked screen goes to `/trial` as the package says. A staff member who used
  "Book for someone" then lands on the bare public form with no back arrow; only "Already
  train here? Sign in" leads back (to `/today`). Open for the Architect: Done could pop to the
  Trials tab when signed in.
- After a booking the form keeps name, phone, age/DOB and note and clears day and batch, so
  "Book another day" (a pop) is quick; Done on a staff push opens a fresh form page.
- The "Your bookings" card is hidden while `my_trial_bookings` loads or fails; the form never
  blocks on it. Riverpod retries that provider in the background.
- The form's `ListView` does not build lower fields at 800x600; widget tests need a tall
  surface or `scrollUntilVisible`. Mock keys: `mockDeviceKey` (this device), `otherDeviceKey`
  (seeded `bookings`).
- `TrialsScreen` repeats `AttendanceRepository.trialsBetween` through `TrialRepository.between`
  (same rpc); both exist because the package specified each.
