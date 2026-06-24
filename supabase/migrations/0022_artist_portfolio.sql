-- GoTattoo · Supabase migration — Artist portfolio link (shown to the owner)
-- Run AFTER 0021. Idempotent.
--
-- Artists provide a portfolio link (Instagram/site/...) at sign-up so the owner
-- has something to judge before approving.

alter table public.profiles
  add column if not exists portfolio text not null default '';

-- Recreate the sign-up handler to also store the portfolio link.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  v_requested text := coalesce(new.raw_user_meta_data ->> 'role', 'client');
  v_name text := coalesce(new.raw_user_meta_data ->> 'name', '');
  v_portfolio text := coalesce(new.raw_user_meta_data ->> 'portfolio', '');
  v_role text;
  v_status text;
begin
  if v_requested = 'artist' then
    v_role := 'client';
    v_status := 'pending';
  else
    v_role := v_requested;
    v_status := 'none';
  end if;

  insert into public.profiles (id, name, role, artist_status, portfolio)
  values (new.id, v_name, v_role, v_status, v_portfolio)
  on conflict (id) do nothing;

  if v_status = 'pending' then
    insert into public.notifications (user_id, type, title, body)
    select p.id, 'artist_request', 'Novo pedido de tatuador',
           coalesce(nullif(v_name, ''), 'Alguém') || ' quer criar conta de tatuador.'
    from public.profiles p
    where p.is_owner = true;
  end if;
  return new;
end;
$$;
