-- GoTattoo · Supabase migration — Geolocation (nearby artists by distance)
-- Run in the Supabase SQL Editor. Idempotent.

alter table public.profiles add column if not exists latitude double precision;
alter table public.profiles add column if not exists longitude double precision;

-- Give the demo artists real Rio de Janeiro coordinates (and matching regions)
-- so the "tatuadores por perto" distance filter works for RJ users.
update public.profiles set latitude = -22.9711, longitude = -43.1822, region = 'Copacabana, Rio de Janeiro'
  where id = '11111111-1111-1111-1111-111111111111'; -- João · Copacabana
update public.profiles set latitude = -22.9026, longitude = -43.2787, region = 'Méier, Rio de Janeiro'
  where id = '22222222-2222-2222-2222-222222222222'; -- Ana · Méier
update public.profiles set latitude = -22.9133, longitude = -43.1797, region = 'Lapa, Rio de Janeiro'
  where id = '33333333-3333-3333-3333-333333333333'; -- Pedro · Lapa
update public.profiles set latitude = -22.9519, longitude = -43.1843, region = 'Botafogo, Rio de Janeiro'
  where id = '44444444-4444-4444-4444-444444444444'; -- Carla · Botafogo
update public.profiles set latitude = -22.9376, longitude = -43.3576, region = 'Pechincha, Rio de Janeiro'
  where id = '55555555-5555-5555-5555-555555555555'; -- Lucas · Pechincha
