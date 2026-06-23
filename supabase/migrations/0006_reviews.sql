-- GoTattoo · Supabase migration — Artist reviews (+ auto-recomputed rating)
-- Run in the Supabase SQL Editor. Idempotent.

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid not null references public.profiles (id) on delete cascade,
  client_id uuid not null references auth.users (id) on delete cascade,
  client_name text not null default '',
  rating int not null check (rating between 1 and 5),
  comment text not null default '',
  created_at timestamptz not null default now()
);

alter table public.reviews enable row level security;

-- Everyone can read reviews; clients write their own.
drop policy if exists "reviews_select_all" on public.reviews;
create policy "reviews_select_all"
  on public.reviews for select using (true);

drop policy if exists "reviews_insert_own" on public.reviews;
create policy "reviews_insert_own"
  on public.reviews for insert with check (client_id = auth.uid());

-- Keep profiles.rating as the artist's average review score, so the home's
-- "most praised first" ordering reflects real feedback.
create or replace function public.recompute_artist_rating()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.profiles
  set rating = (
    select round(avg(rating)::numeric, 1)
    from public.reviews where artist_id = new.artist_id
  )
  where id = new.artist_id;
  return new;
end;
$$;

drop trigger if exists on_review_created on public.reviews;
create trigger on_review_created
  after insert on public.reviews
  for each row execute procedure public.recompute_artist_rating();
