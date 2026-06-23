-- GoTattoo · Supabase migration — Phase 3: Bookings + Artist availability
-- Run in the Supabase SQL Editor AFTER 0002. Idempotent.

-- ───────────────────────── artist availability ─────────────────────────
create table if not exists public.artist_availability (
  artist_id uuid primary key references public.profiles (id) on delete cascade,
  weekdays int[] not null default '{1,2,3,4,5}',   -- 1=Mon .. 7=Sun
  start_hour int not null default 9,
  end_hour int not null default 18,
  updated_at timestamptz not null default now()
);

alter table public.artist_availability enable row level security;

drop policy if exists "availability_select_all" on public.artist_availability;
create policy "availability_select_all"
  on public.artist_availability for select using (true);

drop policy if exists "availability_upsert_own" on public.artist_availability;
create policy "availability_upsert_own"
  on public.artist_availability for insert with check (artist_id = auth.uid());

drop policy if exists "availability_update_own" on public.artist_availability;
create policy "availability_update_own"
  on public.artist_availability for update using (artist_id = auth.uid());

-- ───────────────────────── bookings ─────────────────────────
create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references auth.users (id) on delete cascade,
  client_name text not null default '',
  artist_id uuid not null references public.profiles (id) on delete cascade,
  product_id uuid,
  product_name text not null default '',
  product_image_url text not null default '',
  price numeric not null default 0,
  scheduled_at timestamptz not null,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

alter table public.bookings enable row level security;

-- Both sides of the appointment can see it.
drop policy if exists "bookings_select_party" on public.bookings;
create policy "bookings_select_party"
  on public.bookings for select
  using (client_id = auth.uid() or artist_id = auth.uid());

-- Clients create their own bookings.
drop policy if exists "bookings_insert_client" on public.bookings;
create policy "bookings_insert_client"
  on public.bookings for insert with check (client_id = auth.uid());

-- Either party can update status (the app controls which transitions each does).
drop policy if exists "bookings_update_party" on public.bookings;
create policy "bookings_update_party"
  on public.bookings for update
  using (client_id = auth.uid() or artist_id = auth.uid());
