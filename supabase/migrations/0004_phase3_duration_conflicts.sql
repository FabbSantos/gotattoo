-- GoTattoo · Supabase migration — Phase 3b: tattoo duration + no double-booking
-- Run in the Supabase SQL Editor AFTER 0003. Idempotent.

-- Service duration (hours) per tattoo and per booking.
alter table public.products add column if not exists duration_hours int not null default 2;
alter table public.bookings add column if not exists duration_hours int not null default 2;

-- Hours already taken for an artist on a given day, expanding each OPEN booking
-- by its duration. Security definer so a client can see an artist's busy slots
-- (only the hours, not who booked) despite RLS hiding other clients' bookings.
create or replace function public.occupied_hours(p_artist_id uuid, p_day date)
returns int[]
language sql
security definer set search_path = public
as $$
  select coalesce(array_agg(distinct h), '{}')
  from public.bookings b
  cross join lateral generate_series(
    extract(hour from b.scheduled_at)::int,
    extract(hour from b.scheduled_at)::int + b.duration_hours - 1
  ) as h
  where b.artist_id = p_artist_id
    and (b.scheduled_at at time zone 'UTC')::date = p_day
    and b.status in ('pending','confirmed','awaitingConfirmation','disputed');
$$;
