-- GoTattoo · DESTRUCTIVE reset.
-- Wipes EVERYTHING except the owner account (fabriciobs2000@gmail.com):
-- all other users/profiles, products, bookings, chats, feed, notifications.
-- Irreversible. Run in the Supabase SQL Editor.

do $$
declare
  owner_id uuid;
  t text;
  -- Child/content tables first, parents last (FK-safe order).
  content_tables text[] := array[
    'request_likes',
    'tattoo_request_comments',
    'reports',
    'tattoo_requests',
    'notifications',
    'device_tokens',
    'reviews',
    'messages',
    'conversations',
    'bookings',
    'products'
  ];
begin
  select id into owner_id from auth.users
  where email = 'fabriciobs2000@gmail.com';

  if owner_id is null then
    raise exception 'Owner account not found — aborting to avoid wiping everything.';
  end if;

  -- 1) Full wipe of content tables (skip any that don't exist).
  foreach t in array content_tables loop
    begin
      execute format('delete from public.%I', t);
    exception
      when undefined_table then raise notice 'skip missing table %', t;
    end;
  end loop;

  -- 2) Everyone except the owner.
  delete from public.profiles where id <> owner_id;

  -- 3) Auth users except the owner (cascades to any remaining child rows).
  begin
    delete from auth.users where id <> owner_id;
  exception
    when foreign_key_violation then
      raise notice 'Some auth.users could not be deleted (lingering FKs).';
  end;

  raise notice 'Done. Kept owner %', owner_id;
end $$;
