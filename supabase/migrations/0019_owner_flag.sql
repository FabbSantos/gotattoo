-- GoTattoo · Supabase migration — Owner flag (cosmetic "Dono" badge)
-- Run in the Supabase SQL Editor. Idempotent.

alter table public.profiles
  add column if not exists is_owner boolean not null default false;

-- Mark the owner account (cosmetic only — grants no privileges).
update public.profiles set is_owner = true
where id in (
  select id from auth.users where email = 'fabriciobs2000@gmail.com'
);
