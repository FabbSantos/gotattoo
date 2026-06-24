-- GoTattoo · Supabase migration — Artist signup approval (owner-gated)
-- Run AFTER 0019/0020. Idempotent.
--
-- Anyone can ASK to be an artist at sign-up, but they join as a client with
-- artist_status='pending'. The owner gets a notification and approves/rejects.
-- Only after approval does role become 'artist'.

alter table public.profiles
  add column if not exists artist_status text not null default 'none';
  -- 'none' | 'pending' | 'approved' | 'rejected'

-- ── Sign-up: gate the artist role, notify the owner ──
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  v_requested text := coalesce(new.raw_user_meta_data ->> 'role', 'client');
  v_name text := coalesce(new.raw_user_meta_data ->> 'name', '');
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

  insert into public.profiles (id, name, role, artist_status)
  values (new.id, v_name, v_role, v_status)
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

-- ── Let owners change role/featured (so approval works); others stay frozen ──
create or replace function public.protect_profile_privileges()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if auth.uid() is not null
     and not exists (
       select 1 from public.profiles where id = auth.uid() and is_owner = true
     ) then
    new.role := old.role;
    new.featured := old.featured;
  end if;
  return new;
end;
$$;

-- ── Owner-only approve / reject RPCs ──
create or replace function public.approve_artist(p_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  if not exists (
    select 1 from public.profiles where id = auth.uid() and is_owner = true
  ) then
    raise exception 'Not allowed';
  end if;
  update public.profiles
    set role = 'artist', artist_status = 'approved'
    where id = p_id;
  insert into public.notifications (user_id, type, title, body)
  values (p_id, 'artist_approved', 'Cadastro aprovado!',
          'Sua conta de tatuador foi aprovada. Bem-vindo!');
end;
$$;

create or replace function public.reject_artist(p_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  if not exists (
    select 1 from public.profiles where id = auth.uid() and is_owner = true
  ) then
    raise exception 'Not allowed';
  end if;
  update public.profiles set artist_status = 'rejected' where id = p_id;
  insert into public.notifications (user_id, type, title, body)
  values (p_id, 'artist_rejected', 'Cadastro não aprovado',
          'Seu pedido de conta de tatuador não foi aprovado desta vez.');
end;
$$;

grant execute on function public.approve_artist(uuid) to authenticated;
grant execute on function public.reject_artist(uuid) to authenticated;
