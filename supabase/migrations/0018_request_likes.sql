-- GoTattoo · Supabase migration — Likes + comment counts on feed posts
-- Run in the Supabase SQL Editor AFTER 0013. Idempotent.

alter table public.tattoo_requests
  add column if not exists like_count int not null default 0;
alter table public.tattoo_requests
  add column if not exists comment_count int not null default 0;

create table if not exists public.request_likes (
  request_id uuid not null references public.tattoo_requests (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (request_id, user_id)
);

alter table public.request_likes enable row level security;

-- Users only see/manage their own likes (the public like_count lives on the
-- post). This keeps "who liked" private.
drop policy if exists "likes_select_own" on public.request_likes;
create policy "likes_select_own"
  on public.request_likes for select using (user_id = auth.uid());

drop policy if exists "likes_insert_own" on public.request_likes;
create policy "likes_insert_own"
  on public.request_likes for insert with check (user_id = auth.uid());

drop policy if exists "likes_delete_own" on public.request_likes;
create policy "likes_delete_own"
  on public.request_likes for delete using (user_id = auth.uid());

-- Keep like_count in sync.
create or replace function public.bump_like_count()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' then
    update public.tattoo_requests set like_count = like_count + 1
      where id = new.request_id;
  elsif tg_op = 'DELETE' then
    update public.tattoo_requests set like_count = greatest(0, like_count - 1)
      where id = old.request_id;
  end if;
  return null;
end; $$;

drop trigger if exists on_request_like on public.request_likes;
create trigger on_request_like
  after insert or delete on public.request_likes
  for each row execute procedure public.bump_like_count();

-- Keep comment_count in sync.
create or replace function public.bump_comment_count()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' then
    update public.tattoo_requests set comment_count = comment_count + 1
      where id = new.request_id;
  elsif tg_op = 'DELETE' then
    update public.tattoo_requests set comment_count = greatest(0, comment_count - 1)
      where id = old.request_id;
  end if;
  return null;
end; $$;

drop trigger if exists on_request_comment_count on public.tattoo_request_comments;
create trigger on_request_comment_count
  after insert or delete on public.tattoo_request_comments
  for each row execute procedure public.bump_comment_count();

-- Backfill current counts.
update public.tattoo_requests r set
  comment_count = (select count(*) from public.tattoo_request_comments c where c.request_id = r.id),
  like_count = (select count(*) from public.request_likes l where l.request_id = r.id);
