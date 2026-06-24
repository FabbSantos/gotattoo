-- GoTattoo · Supabase migration — Tattoo requests feed ("Mural de ideias")
-- Run in the Supabase SQL Editor AFTER 0008 + 0010. Idempotent.
--
-- Any user posts a tattoo idea they want done; artists comment and can open a
-- chat to negotiate. Public feed (everyone reads), authored writes.

create table if not exists public.tattoo_requests (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references auth.users (id) on delete cascade,
  author_name text not null default '',
  title text not null,
  description text not null default '',
  image_url text,
  placement text,                 -- local do corpo (ex.: "antebraço")
  budget numeric,                 -- orçamento estimado (opcional)
  status text not null default 'open',  -- open | closed
  created_at timestamptz not null default now()
);

create index if not exists tattoo_requests_created_idx
  on public.tattoo_requests (created_at desc);

create table if not exists public.tattoo_request_comments (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.tattoo_requests (id) on delete cascade,
  author_id uuid not null references auth.users (id) on delete cascade,
  author_name text not null default '',
  author_avatar text,
  body text not null,
  created_at timestamptz not null default now()
);

create index if not exists trc_request_idx
  on public.tattoo_request_comments (request_id, created_at);

alter table public.tattoo_requests enable row level security;
alter table public.tattoo_request_comments enable row level security;

-- Feed is public; users manage their own posts.
drop policy if exists "requests_select_all" on public.tattoo_requests;
create policy "requests_select_all"
  on public.tattoo_requests for select using (true);

drop policy if exists "requests_insert_own" on public.tattoo_requests;
create policy "requests_insert_own"
  on public.tattoo_requests for insert with check (author_id = auth.uid());

drop policy if exists "requests_update_own" on public.tattoo_requests;
create policy "requests_update_own"
  on public.tattoo_requests for update using (author_id = auth.uid());

drop policy if exists "requests_delete_own" on public.tattoo_requests;
create policy "requests_delete_own"
  on public.tattoo_requests for delete using (author_id = auth.uid());

-- Comments are public to read; authored writes.
drop policy if exists "comments_select_all" on public.tattoo_request_comments;
create policy "comments_select_all"
  on public.tattoo_request_comments for select using (true);

drop policy if exists "comments_insert_own" on public.tattoo_request_comments;
create policy "comments_insert_own"
  on public.tattoo_request_comments for insert with check (author_id = auth.uid());

-- Artist-side counterpart of get_or_create_conversation: the caller (artist)
-- opens/reuses a thread with a client (e.g. the author of a request).
create or replace function public.get_or_create_conversation_as_artist(
  p_client_id uuid
)
returns uuid
language plpgsql
security definer set search_path = public
as $$
declare
  v_id uuid;
  v_artist uuid := auth.uid();
begin
  select id into v_id
  from public.conversations
  where client_id = p_client_id and artist_id = v_artist;

  if v_id is null then
    insert into public.conversations (client_id, artist_id)
    values (p_client_id, v_artist)
    returning id into v_id;
  end if;
  return v_id;
end;
$$;

-- A new comment notifies the request's author (reuses notifications → push),
-- unless the author is commenting on their own post.
create or replace function public.notify_on_request_comment()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  v_author uuid;
  v_title text;
begin
  select author_id, title into v_author, v_title
  from public.tattoo_requests where id = new.request_id;

  if v_author is not null and v_author <> new.author_id then
    insert into public.notifications (user_id, type, title, body)
    values (
      v_author,
      'request_comment',
      'Novo interesse no seu pedido',
      coalesce(nullif(new.author_name, ''), 'Um tatuador') ||
        ' comentou em "' || coalesce(nullif(v_title, ''), 'seu pedido') || '".'
    );
  end if;
  return new;
end;
$$;

drop trigger if exists on_request_comment on public.tattoo_request_comments;
create trigger on_request_comment
  after insert on public.tattoo_request_comments
  for each row execute procedure public.notify_on_request_comment();
