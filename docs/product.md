# Product

The only source of requirements. Every statement here is either confirmed by the owner (with
the date) or marked as an open question. Nothing is built from an assumption.

## Confirmed (owner, 2026-11-05)

- A people management app for a boxing club in Saroornagar.
- Purposes: take, view and manage the attendance of the trainees; let people book trial
  sessions.
- Android mobile app built with Flutter; Supabase on the free tier as the only backend.
- Design: modern and classy, Apple-like, probably two colours; the owner picks from the
  design-directions canvas (see `decisions.md` once chosen).
- Users (interview round 1): coaches / club staff, trainees, and public visitors (not yet
  members) who book a trial. Trainees never check themselves in; they can see their own
  attendance and their fee payment updates (cash or UPI), among other things.
- Attendance is captured by a coach tapping the students who are present (owner,
  2026-11-05). Everyone else in a session that has at least one mark counts as absent; a
  session with no marks is ignored (class not held or attendance not taken).
- One club, one location. Two sessions every day, morning and evening, except Sunday. A coach
  or staff member can add an extra session on a day when needed.
- Trial booking happens in the app, with no account needed for the visitor.
- Sign-in is email and password for staff, with a forgot-password flow by emailed code
  (owner, 2026-11-05, replacing the earlier phone + password choice). No SMS provider.
  Visitors booking a trial still give a phone number.
- Roles: coach/staff and admin. Everything a coach can do, an admin can do too. Admin only
  (owner, 2026-11-05): manage coach/staff accounts (create, edit, remove), reset any user's
  password, block or unblock a user's access.
- Any trainee can attend any session; the coach marks from the full roster each time.
- Fees in release 1: record only. Staff record a payment (cash or UPI, amount, date, period);
  the trainee sees their history and what is due. No money moves through the app.

## Release 1 scope (owner, 2026-11-05)

Guest trial-slot booking plus the coach / staff / admin app. **No trainee view in release 1**:
trainees do not sign in; their attendance and fee records are kept by staff. The trainee
view (own attendance, fee updates) is a later release; nothing in release 1 may depend on it.

- Trainee record (round 3): name; optional photo, phone, date of birth and joining date;
  active/inactive status. No "arrived" tick on trial bookings.
- Trial booking: no confirmation step. A guest's booking only informs the coach that someone
  is arriving for that session.
- Sessions: morning generally 6:00 to 8:30 am, evening 5:30 to 8:00 pm, every day except
  Sunday; staff may add an extra session on a day.
- Staff reports in release 1: per-trainee attendance history, monthly attendance summary,
  fee status list.

- Fees (round 4): monthly. 500 per month for juniors (below 15 years), 800 per month for
  seniors (15 and above) (owner, 2026-11-05: amounts are 500 or 800). The app just records payments; no automatic due or overdue logic
  was asked for. A trainee's age therefore matters to the fee tier.
- Trial form: name, phone, date, session (morning or evening), age or date of birth, and an
  optional note.
- Design direction A, Ivory and Graphite (light, Apple-like, graphite text, one blue accent).
- Hosted Supabase project: the owner creates it and shares the project ref and publishable
  key.

## Open questions

Gathered through the requirements interview, broad to narrow. Each answer moves to the
Confirmed section with its date.

1. (answered) Users and roles: owner/admin above coaches, same powers for now.
2. (answered) Coach marks a session list.
3. (answered) One club, two sessions daily except Sunday; any trainee may attend any session. Still open: roughly how many trainees; session timings.
4. (answered) In the app, no account, no confirmation, no arrived tick. Still open: whether a slot has a capacity; whether the guest can cancel; any trial fee. Left out of release 1 until answered.
5. (answered) Phone and password; admin creates and manages staff accounts, resets passwords, blocks access. Still open: how the first admin account is created (seeded by us with a password handed over).
6. (answered) Trainee record fields.
7. (answered) Monthly fee by age tier, record only; date of birth optional on the trainee record. Still open: should the fee status list only show the last paid month, or also flag months with no payment.
8. Notifications (reminders, confirmations): in scope or not; channel.
9. (answered) Reports: per-trainee history, monthly summary, fee status list.
10. (answered) Hosted Supabase: the owner creates it. Still open: the Android application id (needs the club's name or domain); how the first admin account is created (proposal: seeded by a migration with a password the owner changes).

## Glossary

- Trainee: a person who trains at the club. Member is used in the same sense until the owner
  says otherwise.
- Coach / staff: the people who run sessions and manage trainees.
- Trial: a first session booked by someone who is not yet a trainee.
