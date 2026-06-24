-- GoTattoo · Supabase migration — Artist re-request + rejection reason
-- Run AFTER 0022. Idempotent.
--
-- - A client (incl. a rejected one) can re-ask to become an artist in-app.
-- - The owner gives a reason when rejecting; the applicant sees it.

alter table public.profiles
  add column if not exists reject_reason text not null default '';

-- Request (or re-request) artist; clears any previous rejection reason.
create or replace function public.request_artist(p_portfolio text)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  v_name text;
begin
  if exists (
    select 1 from public.profiles where id = auth.uid() and role = 'artist'
  ) then
    raise exception 'Already an artist';
  end if;

  update public.profiles
    set artist_status = 'pending',
        portfolio = coalesce(nullif(p_portfolio, ''), portfolio),
        reject_reason = ''
    where id = auth.uid();

  select name into v_name from public.profiles where id = auth.uid();

  insert into public.notifications (user_id, type, title, body)
  select p.id, 'artist_request', 'Novo pedido de tatuador',
         coalesce(nullif(v_name, ''), 'Alguém') || ' quer criar conta de tatuador.'
  from public.profiles p
  where p.is_owner = true;
end;
$$;

-- Reject with a reason (replaces the no-reason version from 0021).
drop function if exists public.reject_artist(uuid);
create or replace function public.reject_artist(p_id uuid, p_reason text default '')
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
    set artist_status = 'rejected', reject_reason = coalesce(p_reason, '')
    where id = p_id;

  insert into public.notifications (user_id, type, title, body)
  values (
    p_id, 'artist_rejected', 'Cadastro não aprovado',
    case when coalesce(p_reason, '') = ''
      then 'Seu pedido de conta de tatuador não foi aprovado desta vez.'
      else 'Seu pedido não foi aprovado: ' || p_reason
    end
  );
end;
$$;

grant execute on function public.request_artist(text) to authenticated;
grant execute on function public.reject_artist(uuid, text) to authenticated;
