-- GoTattoo · Supabase migration — Block users (UGC safety)
-- Run AFTER 0025. Idempotent.
--
-- A user can block another; the app hides the blocked person's feed posts and
-- comments from them. Each user manages only their own block list.

create table if not exists public.user_blocks (
  blocker_id uuid not null references auth.users (id) on delete cascade,
  blocked_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id)
);

alter table public.user_blocks enable row level security;

drop policy if exists "blocks_select_own" on public.user_blocks;
create policy "blocks_select_own" on public.user_blocks
  for select using (blocker_id = auth.uid());

drop policy if exists "blocks_insert_own" on public.user_blocks;
create policy "blocks_insert_own" on public.user_blocks
  for insert with check (blocker_id = auth.uid());

drop policy if exists "blocks_delete_own" on public.user_blocks;
create policy "blocks_delete_own" on public.user_blocks
  for delete using (blocker_id = auth.uid());
