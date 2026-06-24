-- GoTattoo · Supabase migration — Stripe payments (Phase 1: charge after approval)
-- Run in the Supabase SQL Editor AFTER 0003. Idempotent.
--
-- Flow: client saves a card when booking (SetupIntent, no charge). On approval
-- the artist's action charges the saved card off-session. Cancel/reject after a
-- charge triggers a refund. Funds stay on the platform (Connect/payout = phase 2).

alter table public.profiles
  add column if not exists stripe_customer_id text;

alter table public.bookings
  add column if not exists stripe_payment_method_id text,
  add column if not exists payment_intent_id text,
  -- none → saved (card on file) → paid → refunded | failed
  add column if not exists payment_status text not null default 'none';
