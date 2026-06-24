-- GoTattoo · Supabase migration — Lock privileged profile columns
-- Run in the Supabase SQL Editor. Idempotent.
--
-- RLS lets a user update their OWN profile, but can't restrict WHICH columns.
-- Without this, a user could self-promote: set role='artist' (fake the
-- "Tatuador" badge / appear as an artist) or featured=true (free promotion).
--
-- This BEFORE UPDATE trigger preserves `role` and `featured` whenever the update
-- comes from a logged-in user (auth.uid() is set). Admin/manual changes from the
-- SQL Editor or Edge Functions (service role → auth.uid() is null) still work.

create or replace function public.protect_profile_privileges()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if auth.uid() is not null then
    new.role := old.role;
    new.featured := old.featured;
  end if;
  return new;
end;
$$;

drop trigger if exists protect_profile_privileges on public.profiles;
create trigger protect_profile_privileges
  before update on public.profiles
  for each row execute procedure public.protect_profile_privileges();
