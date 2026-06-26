-- GoTattoo · Seed test accounts for the Google Play review.
-- Run in the Supabase SQL Editor. Re-runnable (recreates the two accounts).
--
-- Credentials to paste into Play Console → "Detalhes do login":
--   Cliente : revisao.cliente@gotattoo.app  /  Play@Review2026
--   Tatuador: revisao.tatuador@gotattoo.app /  Play@Review2026
-- Login by e-mail + password on the home screen (NOT "Entrar com Google").

do $$
declare
  client_id  uuid := gen_random_uuid();
  artist_id  uuid := gen_random_uuid();
  client_em  text := 'revisao.cliente@gotattoo.app';
  artist_em  text := 'revisao.tatuador@gotattoo.app';
  pwd        text := 'Play@Review2026';
begin
  -- Clean slate so the script can be re-run.
  delete from auth.users where email in (client_em, artist_em);

  -- ── Client account ──
  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data
  ) values (
    '00000000-0000-0000-0000-000000000000', client_id, 'authenticated',
    'authenticated', client_em, crypt(pwd, gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('name', 'Revisão Cliente', 'role', 'client')
  );
  insert into auth.identities (
    user_id, provider_id, identity_data, provider,
    last_sign_in_at, created_at, updated_at
  ) values (
    client_id, client_id::text,
    jsonb_build_object('sub', client_id::text, 'email', client_em),
    'email', now(), now(), now()
  );

  -- ── Artist account (the trigger makes it a pending client; approve it) ──
  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data
  ) values (
    '00000000-0000-0000-0000-000000000000', artist_id, 'authenticated',
    'authenticated', artist_em, crypt(pwd, gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('name', 'Revisão Tatuador', 'role', 'artist')
  );
  insert into auth.identities (
    user_id, provider_id, identity_data, provider,
    last_sign_in_at, created_at, updated_at
  ) values (
    artist_id, artist_id::text,
    jsonb_build_object('sub', artist_id::text, 'email', artist_em),
    'email', now(), now(), now()
  );

  -- Approve the artist so the reviewer sees the artist area.
  update public.profiles
    set role = 'artist', artist_status = 'approved'
    where id = artist_id;

  raise notice 'Created review accounts: % and %', client_em, artist_em;
end $$;
