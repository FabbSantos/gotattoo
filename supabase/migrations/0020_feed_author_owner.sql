-- GoTattoo · Supabase migration — Identify the owner in the feed
-- Run AFTER 0019 (profiles.is_owner). Idempotent.
--
-- Posts and comments also carry whether their author is the app owner, so the
-- app can badge "Dono" next to the name. Set by the same trigger so it can't
-- be faked by the client.

alter table public.tattoo_requests
  add column if not exists author_is_owner boolean not null default false;
alter table public.tattoo_request_comments
  add column if not exists author_is_owner boolean not null default false;

-- Recreate the shared trigger function to set BOTH flags.
create or replace function public.set_feed_author_role()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  new.author_is_artist := exists (
    select 1 from public.profiles
    where id = new.author_id and role = 'artist'
  );
  new.author_is_owner := exists (
    select 1 from public.profiles
    where id = new.author_id and is_owner = true
  );
  return new;
end;
$$;

-- Backfill existing rows.
update public.tattoo_requests r set author_is_owner = exists (
  select 1 from public.profiles p where p.id = r.author_id and p.is_owner = true
);
update public.tattoo_request_comments c set author_is_owner = exists (
  select 1 from public.profiles p where p.id = c.author_id and p.is_owner = true
);
