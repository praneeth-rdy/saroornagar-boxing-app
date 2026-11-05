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

## Open questions

Gathered through the requirements interview, broad to narrow. Each answer moves to the
Confirmed section with its date.

1. Who uses the app: coaches or staff only, trainees too, the public for trial booking?
2. How attendance is captured: the coach marks a list, the trainee checks in, or both?
3. One club or several branches; number of trainees and batches, roughly; batch timings.
4. Trial booking: inside the app, on a public web page, or both; who confirms a trial; any fee.
5. Sign-in: phone OTP, email, or no account for visitors; who is allowed in.
6. Trainee records: what is stored (name, phone, joining date, plan, fees?).
7. Membership and fees: in scope or not.
8. Notifications (reminders, confirmations): in scope or not; channel.
9. Reports: what the owner wants to see (per trainee, per batch, per month).
10. Hosted Supabase: which organisation, region and project name; the Android application id.

## Glossary

- Trainee: a person who trains at the club. Member is used in the same sense until the owner
  says otherwise.
- Coach / staff: the people who run sessions and manage trainees.
- Trial: a first session booked by someone who is not yet a trainee.
