-- GoTattoo · Supabase migration — Author avatar on feed posts
-- Run in the Supabase SQL Editor AFTER 0013. Idempotent.
--
-- Denormalized like author_name, so the feed shows the poster's photo
-- (Facebook-style) without an extra join.

alter table public.tattoo_requests
  add column if not exists author_avatar text;

-- Backfill existing posts from the author's profile.
update public.tattoo_requests r
set author_avatar = p.avatar_url
from public.profiles p
where p.id = r.author_id and r.author_avatar is null;
