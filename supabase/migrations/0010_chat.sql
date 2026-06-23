-- GoTattoo · Supabase migration — Chat (1 thread per client↔artist pair)
-- Run in the Supabase SQL Editor AFTER 0008 (uses the notifications table).
-- Idempotent.

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references auth.users (id) on delete cascade,
  artist_id uuid not null references public.profiles (id) on delete cascade,
  last_message text not null default '',
  last_message_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (client_id, artist_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_id uuid not null references auth.users (id) on delete cascade,
  body text not null,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists messages_conversation_idx
  on public.messages (conversation_id, created_at);

alter table public.conversations enable row level security;
alter table public.messages enable row level security;

-- Only the two parties can see/act on a conversation.
drop policy if exists "conversations_party" on public.conversations;
create policy "conversations_party"
  on public.conversations for all
  using (client_id = auth.uid() or artist_id = auth.uid())
  with check (client_id = auth.uid() or artist_id = auth.uid());

drop policy if exists "messages_select_party" on public.messages;
create policy "messages_select_party"
  on public.messages for select using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.client_id = auth.uid() or c.artist_id = auth.uid())
    )
  );

drop policy if exists "messages_insert_party" on public.messages;
create policy "messages_insert_party"
  on public.messages for insert with check (
    sender_id = auth.uid() and exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.client_id = auth.uid() or c.artist_id = auth.uid())
    )
  );

drop policy if exists "messages_update_party" on public.messages;
create policy "messages_update_party"
  on public.messages for update using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.client_id = auth.uid() or c.artist_id = auth.uid())
    )
  );

-- Keep the conversation's last-message preview/timestamp fresh.
create or replace function public.bump_conversation()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.conversations
  set last_message = new.body, last_message_at = new.created_at
  where id = new.conversation_id;
  return new;
end;
$$;

drop trigger if exists on_message_insert on public.messages;
create trigger on_message_insert
  after insert on public.messages
  for each row execute procedure public.bump_conversation();

-- Client opens (or reuses) their thread with an artist.
create or replace function public.get_or_create_conversation(p_artist_id uuid)
returns uuid
language plpgsql
security definer set search_path = public
as $$
declare
  v_id uuid;
  v_client uuid := auth.uid();
begin
  select id into v_id
  from public.conversations
  where client_id = v_client and artist_id = p_artist_id;

  if v_id is null then
    insert into public.conversations (client_id, artist_id)
    values (v_client, p_artist_id)
    returning id into v_id;
  end if;
  return v_id;
end;
$$;

-- The current user's conversations, enriched: other party, last message, unread
-- count, and a priority flag (artist viewing a client who has an open booking).
create or replace function public.conversation_list()
returns table (
  id uuid,
  other_id uuid,
  other_name text,
  other_avatar text,
  last_message text,
  last_message_at timestamptz,
  unread int,
  is_priority boolean
)
language sql
security definer set search_path = public
as $$
  select
    c.id,
    case when c.client_id = auth.uid() then c.artist_id else c.client_id end as other_id,
    p.name,
    p.avatar_url,
    c.last_message,
    c.last_message_at,
    (
      select count(*) from public.messages m
      where m.conversation_id = c.id
        and m.sender_id <> auth.uid()
        and not m.read
    )::int as unread,
    (
      c.artist_id = auth.uid() and exists (
        select 1 from public.bookings b
        where b.artist_id = c.artist_id
          and b.client_id = c.client_id
          and b.status in ('pending','confirmed','awaitingConfirmation','disputed')
      )
    ) as is_priority
  from public.conversations c
  join public.profiles p
    on p.id = (case when c.client_id = auth.uid() then c.artist_id else c.client_id end)
  where c.client_id = auth.uid() or c.artist_id = auth.uid()
  order by is_priority desc, c.last_message_at desc;
$$;

-- A new message notifies the recipient (reuses the notifications pipeline →
-- the send-push webhook → FCM), and shows up in the bell too.
create or replace function public.notify_on_message()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  v_conv public.conversations;
  v_recipient uuid;
  v_sender_name text;
begin
  select * into v_conv from public.conversations where id = new.conversation_id;
  v_recipient := case
    when new.sender_id = v_conv.client_id then v_conv.artist_id
    else v_conv.client_id
  end;
  select coalesce(nullif(name, ''), 'Nova mensagem') into v_sender_name
  from public.profiles where id = new.sender_id;

  insert into public.notifications (user_id, type, title, body)
  values (v_recipient, 'message', v_sender_name, left(new.body, 140));
  return new;
end;
$$;

drop trigger if exists on_message_notify on public.messages;
create trigger on_message_notify
  after insert on public.messages
  for each row execute procedure public.notify_on_message();

-- Stream new messages to the app in realtime.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'messages'
  ) then
    alter publication supabase_realtime add table public.messages;
  end if;
end $$;
