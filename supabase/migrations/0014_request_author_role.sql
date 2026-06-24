-- GoTattoo · Supabase migration — Identify artists in the feed
-- Run in the Supabase SQL Editor AFTER 0013. Idempotent.
--
-- Posts and comments carry whether their author is a tattoo artist, so the app
-- can badge "Tatuador". Set by a trigger (from profiles.role) so the client
-- can't fake it.

alter table public.tattoo_requests
  add column if not exists author_is_artist boolean not null default false;
alter table public.tattoo_request_comments
  add column if not exists author_is_artist boolean not null default false;

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
  return new;
end;
$$;

drop trigger if exists on_request_set_role on public.tattoo_requests;
create trigger on_request_set_role
  before insert on public.tattoo_requests
  for each row execute procedure public.set_feed_author_role();

drop trigger if exists on_comment_set_role on public.tattoo_request_comments;
create trigger on_comment_set_role
  before insert on public.tattoo_request_comments
  for each row execute procedure public.set_feed_author_role();

-- Backfill existing rows.
update public.tattoo_requests r set author_is_artist = exists (
  select 1 from public.profiles p where p.id = r.author_id and p.role = 'artist'
);
update public.tattoo_request_comments c set author_is_artist = exists (
  select 1 from public.profiles p where p.id = c.author_id and p.role = 'artist'
);
