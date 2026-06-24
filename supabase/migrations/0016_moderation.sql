-- GoTattoo · Supabase migration — Light content moderation
-- Run in the Supabase SQL Editor AFTER 0013. Idempotent.
--
-- Two cheap layers: posters can flag their own image as sensitive (blurred with
-- tap-to-reveal), and anyone can report content for manual review/removal.

alter table public.tattoo_requests
  add column if not exists sensitive boolean not null default false;

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users (id) on delete cascade,
  target_type text not null,        -- 'request' | 'comment' | 'product' | 'profile'
  target_id uuid not null,
  reason text not null default '',
  created_at timestamptz not null default now()
);

create index if not exists reports_created_idx
  on public.reports (created_at desc);

alter table public.reports enable row level security;

-- Authenticated users can file reports. There's NO select policy on purpose:
-- users can't read the reports queue — you review it from the SQL Editor.
drop policy if exists "reports_insert_auth" on public.reports;
create policy "reports_insert_auth"
  on public.reports for insert with check (reporter_id = auth.uid());
