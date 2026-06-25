-- GoTattoo · Supabase migration — In-app support (mural)
-- Run AFTER 0023. Idempotent.
--
-- One thread per user. The user sees only their own messages; the owner sees
-- and replies to everyone. Notifications fire to the owner (new message) and
-- to the user (owner reply).

create table if not exists public.support_messages (
  id uuid primary key default gen_random_uuid(),
  thread_user_id uuid not null references auth.users (id) on delete cascade,
  author_id uuid not null references auth.users (id) on delete cascade,
  from_owner boolean not null default false,
  body text not null,
  created_at timestamptz not null default now()
);

create index if not exists support_messages_thread_idx
  on public.support_messages (thread_user_id, created_at);

alter table public.support_messages enable row level security;

-- Read: your own thread, or everything if you're the owner.
drop policy if exists "support_select" on public.support_messages;
create policy "support_select" on public.support_messages for select using (
  thread_user_id = auth.uid()
  or exists (select 1 from public.profiles where id = auth.uid() and is_owner = true)
);

-- Write: a user posts into their own thread (from_owner = false); the owner
-- posts into any thread (from_owner = true). Author must be the caller.
drop policy if exists "support_insert" on public.support_messages;
create policy "support_insert" on public.support_messages for insert with check (
  author_id = auth.uid()
  and (
    (thread_user_id = auth.uid() and from_owner = false)
    or (
      from_owner = true
      and exists (select 1 from public.profiles where id = auth.uid() and is_owner = true)
    )
  )
);

-- Owner inbox: latest message per thread + the user's name/avatar.
-- security_invoker so the owner-only RLS above still applies through the view.
create or replace view public.support_threads
  with (security_invoker = true) as
select distinct on (m.thread_user_id)
  m.thread_user_id as user_id,
  p.name as user_name,
  p.avatar_url as user_avatar,
  m.body as last_body,
  m.from_owner as last_from_owner,
  m.created_at as last_at
from public.support_messages m
left join public.profiles p on p.id = m.thread_user_id
order by m.thread_user_id, m.created_at desc;

-- Notify the counterpart on each new message.
create or replace function public.notify_on_support()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.from_owner then
    -- Owner replied → notify the user who owns the thread.
    insert into public.notifications (user_id, type, title, body)
    values (new.thread_user_id, 'support_reply', 'Resposta do suporte',
            left(new.body, 120));
  else
    -- User wrote → notify the owner(s).
    insert into public.notifications (user_id, type, title, body)
    select p.id, 'support_message', 'Nova mensagem de suporte', left(new.body, 120)
    from public.profiles p
    where p.is_owner = true;
  end if;
  return new;
end;
$$;

drop trigger if exists on_support_notify on public.support_messages;
create trigger on_support_notify
  after insert on public.support_messages
  for each row execute procedure public.notify_on_support();

-- Realtime so threads update live.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'support_messages'
  ) then
    alter publication supabase_realtime add table public.support_messages;
  end if;
end $$;
