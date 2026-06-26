-- GoTattoo · Seed a test account for the Google Play review.
-- Run in the Supabase SQL Editor. Re-runnable (recreates the account).
--
-- An approved ARTIST account — it can do everything a client does (browse,
-- book, feed, chat) PLUS the artist area, so one account covers the review.
--
-- Credentials to paste into Play Console → "Detalhes do login":
--   E-mail: revisao@gotattoo.app
--   Senha : Play@Review2026
-- Login by e-mail + password on the home screen (NOT "Entrar com Google").

do $$
declare
  uid  uuid := gen_random_uuid();
  em   text := 'revisao@gotattoo.app';
  pwd  text := 'Play@Review2026';
begin
  -- Clean slate so the script can be re-run.
  delete from auth.users where email = em;

  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data
  ) values (
    '00000000-0000-0000-0000-000000000000', uid, 'authenticated',
    'authenticated', em, crypt(pwd, gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('name', 'Revisão GoTattoo', 'role', 'artist')
  );

  insert into auth.identities (
    user_id, provider_id, identity_data, provider,
    last_sign_in_at, created_at, updated_at
  ) values (
    uid, uid::text,
    jsonb_build_object('sub', uid::text, 'email', em),
    'email', now(), now(), now()
  );

  -- The sign-up trigger makes an artist a pending client; approve it so the
  -- reviewer sees the artist area.
  update public.profiles
    set role = 'artist', artist_status = 'approved'
    where id = uid;

  raise notice 'Created review account: %', em;
end $$;
