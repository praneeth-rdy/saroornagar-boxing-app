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

## Open questions

Gathered through the requirements interview, broad to narrow. Each answer moves to the
Confirmed section with its date.

1. (answered) Users. Still open: is there an owner/admin role above coaches, and what can it do that a coach cannot?
2. (answered) Coach marks a session list.
3. (answered) One club, two sessions daily except Sunday. Still open: roughly how many trainees; do trainees belong to one session (morning or evening) or can they come to either; session timings.
4. (answered) In the app, no account. Still open: who confirms a trial and how the visitor hears back; any trial fee; what the coach sees and does with a trial booking.
5. (answered) Phone number and password. Still open: who creates a trainee's account and first password (staff, or self sign-up); how a forgotten password is reset without SMS (staff reset is the free path).
6. Trainee records: what is stored (name, phone, joining date, plan, fees?).
7. Fees: trainees see their fee payment updates (cash or UPI). Still open: what a fee record is (monthly? plan?), who records a payment, whether UPI is collected in the app or only recorded.
8. Notifications (reminders, confirmations): in scope or not; channel.
9. Reports: what the owner wants to see (per trainee, per batch, per month).
10. Hosted Supabase: which organisation, region and project name; the Android application id.

## Glossary

- Trainee: a person who trains at the club. Member is used in the same sense until the owner
  says otherwise.
- Coach / staff: the people who run sessions and manage trainees.
- Trial: a first session booked by someone who is not yet a trainee.
