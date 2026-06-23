-- GoTattoo · Supabase migration — Categories (DB-driven, no app release needed)
-- Run in the Supabase SQL Editor. Idempotent.

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

alter table public.categories enable row level security;

-- Everyone can read; manage rows from the Supabase dashboard (or service role).
drop policy if exists "categories_select_all" on public.categories;
create policy "categories_select_all"
  on public.categories for select using (true);

-- Seed the existing categories (add more anytime via the dashboard).
insert into public.categories (name, sort_order) values
  ('Old School', 1),
  ('New School', 2),
  ('Tribal', 3),
  ('Realista', 4),
  ('Geométrica', 5),
  ('Blackwork', 6),
  ('Aquarela', 7),
  ('Minimalista', 8),
  ('Lettering', 9),
  ('Fineline', 10),
  ('Floral', 11),
  ('Flash', 12),
  ('Outros', 13)
on conflict (name) do nothing;

-- Keep "Outros" last even when re-seeding over an older order.
update public.categories set sort_order = 13 where name = 'Outros';
