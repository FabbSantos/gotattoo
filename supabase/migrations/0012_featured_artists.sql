-- GoTattoo · Supabase migration — Featured ("Destaque") artists
-- Run in the Supabase SQL Editor. Idempotent.
--
-- A promoted artist is sorted first in the catalog and badged in the app. This
-- is the product foundation for paid "impulsionamento" (monetization) — the flag
-- is set manually for now; billing/self-serve comes later.

alter table public.profiles
  add column if not exists featured boolean not null default false;

-- Promote one demo artist so the badge/sort is visible while testing.
update public.profiles set featured = true
  where id = '11111111-1111-1111-1111-111111111111'; -- João · Copacabana
