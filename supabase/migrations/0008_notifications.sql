-- GoTattoo · Supabase migration — Notifications (booking lifecycle events)
-- Run in the Supabase SQL Editor AFTER 0003. Idempotent.

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  type text not null,
  title text not null,
  body text not null default '',
  booking_id uuid references public.bookings (id) on delete cascade,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_idx
  on public.notifications (user_id, created_at desc);

alter table public.notifications enable row level security;

-- Recipients read and mark their own notifications. Rows are created only by the
-- security-definer trigger below (no insert policy on purpose).
drop policy if exists "notifications_select_own" on public.notifications;
create policy "notifications_select_own"
  on public.notifications for select using (user_id = auth.uid());

drop policy if exists "notifications_update_own" on public.notifications;
create policy "notifications_update_own"
  on public.notifications for update using (user_id = auth.uid());

-- One notification per relevant booking event, sent to the counterparty.
create or replace function public.notify_on_booking()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  v_recipient uuid;
  v_type text;
  v_title text;
  v_body text;
  v_product text := coalesce(nullif(new.product_name, ''), 'a tatuagem');
  v_client text := coalesce(nullif(new.client_name, ''), 'Um cliente');
begin
  if (tg_op = 'INSERT') then
    v_recipient := new.artist_id;
    v_type := 'booking_requested';
    v_title := 'Novo agendamento';
    v_body := v_client || ' quer agendar ' || v_product || '.';
  elsif (tg_op = 'UPDATE' and new.status is distinct from old.status) then
    case new.status
      when 'confirmed' then
        v_recipient := new.client_id; v_type := 'booking_confirmed';
        v_title := 'Agendamento aprovado';
        v_body := 'Seu agendamento de ' || v_product || ' foi aprovado.';
      when 'rejected' then
        v_recipient := new.client_id; v_type := 'booking_rejected';
        v_title := 'Agendamento recusado';
        v_body := 'Seu agendamento de ' || v_product || ' foi recusado. Reembolso a caminho.';
      when 'awaitingConfirmation' then
        v_recipient := new.client_id; v_type := 'booking_awaiting';
        v_title := 'Confirme a conclusão';
        v_body := 'O tatuador marcou ' || v_product || ' como concluída. Confirme pra liberar o pagamento.';
      when 'completed' then
        v_recipient := new.artist_id; v_type := 'booking_completed';
        v_title := 'Sessão concluída';
        v_body := v_client || ' confirmou a conclusão. Pagamento liberado.';
      when 'cancelled' then
        v_recipient := new.artist_id; v_type := 'booking_cancelled';
        v_title := 'Agendamento cancelado';
        v_body := 'Um agendamento de ' || v_product || ' foi cancelado.';
      else
        return new;
    end case;
  else
    return new;
  end if;

  insert into public.notifications (user_id, type, title, body, booking_id)
  values (v_recipient, v_type, v_title, v_body, new.id);
  return new;
end;
$$;

drop trigger if exists on_booking_notify on public.bookings;
create trigger on_booking_notify
  after insert or update on public.bookings
  for each row execute procedure public.notify_on_booking();

-- Stream new notifications to the app in realtime.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'notifications'
  ) then
    alter publication supabase_realtime add table public.notifications;
  end if;
end $$;
