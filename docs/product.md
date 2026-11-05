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
- Attendance is captured by a coach marking a session list: present or absent per trainee.
- One club, one location. Two sessions every day, morning and evening, except Sunday. A coach
  or staff member can add an extra session on a day when needed.
- Trial booking happens in the app, with no account needed for the visitor.
- Sign-in is phone number and password (owner, 2026-11-05), for staff and trainees alike. No
  OTP, no SMS provider.
- Roles (round 2): an owner/admin role exists above coaches, but with the same powers as a
  coach for now; the role is kept in the data, nothing is restricted yet.
- Any trainee can attend any session; the coach marks from the full roster each time.
- Fees in release 1: record only. Staff record a payment (cash or UPI, amount, date, period);
  the trainee sees their history and what is due. No money moves through the app.

## Open questions

Gathered through the requirements interview, broad to narrow. Each answer moves to the
Confirmed section with its date.

1. (answered) Users and roles: owner/admin above coaches, same powers for now.
2. (answered) Coach marks a session list.
3. (answered) One club, two sessions daily except Sunday; any trainee may attend any session. Still open: roughly how many trainees; session timings.
4. (answered) In the app, no account. Still open: who confirms a trial and how the visitor hears back; any trial fee; what the coach sees and does with a trial booking.
5. (answered) Phone number and password. Still open: who creates a trainee's account and first password (staff, or self sign-up); how a forgotten password is reset without SMS (staff reset is the free path).
6. Trainee records: what is stored (name, phone, joining date, plan, fees?).
7. (answered) Fees are record-only in release 1. Still open: the fee model (monthly amount per trainee? plans?), and what "due" means.
8. Notifications (reminders, confirmations): in scope or not; channel.
9. Reports: what the owner wants to see (per trainee, per batch, per month).
10. Hosted Supabase: which organisation, region and project name; the Android application id.

## Glossary

- Trainee: a person who trains at the club. Member is used in the same sense until the owner
  says otherwise.
- Coach / staff: the people who run sessions and manage trainees.
- Trial: a first session booked by someone who is not yet a trainee.
