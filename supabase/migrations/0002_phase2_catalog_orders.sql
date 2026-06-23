-- GoTattoo · Supabase migration — Phase 2: Artists + Products + Orders
-- Run this in the Supabase SQL Editor AFTER 0001.
-- Idempotent: safe to run more than once.

-- ─────────────── artists are profiles with role='artist' ───────────────
alter table public.profiles add column if not exists specialty text;
alter table public.profiles add column if not exists rating numeric;

-- ───────────────────────── products ─────────────────────────
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  price numeric not null default 0,
  image_url text not null default '',
  stock int not null default 0,
  category text not null default '',
  artist_id uuid references public.profiles (id) on delete cascade,
  discount_percent int not null default 0,
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;

drop policy if exists "products_select_all" on public.products;
create policy "products_select_all" on public.products for select using (true);

drop policy if exists "products_insert_own" on public.products;
create policy "products_insert_own" on public.products
  for insert with check (artist_id = auth.uid());

drop policy if exists "products_update_own" on public.products;
create policy "products_update_own" on public.products
  for update using (artist_id = auth.uid());

drop policy if exists "products_delete_own" on public.products;
create policy "products_delete_own" on public.products
  for delete using (artist_id = auth.uid());

-- ───────────────────────── orders ─────────────────────────
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  total numeric not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_id uuid,
  product_name text not null default '',
  product_image_url text not null default '',
  artist_id uuid,
  unit_price numeric not null default 0,
  quantity int not null default 1
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

drop policy if exists "orders_select_own" on public.orders;
create policy "orders_select_own" on public.orders
  for select using (user_id = auth.uid());

drop policy if exists "orders_insert_own" on public.orders;
create policy "orders_insert_own" on public.orders
  for insert with check (user_id = auth.uid());

drop policy if exists "order_items_select_own" on public.order_items;
create policy "order_items_select_own" on public.order_items
  for select using (
    exists (select 1 from public.orders o
            where o.id = order_id and o.user_id = auth.uid())
  );

drop policy if exists "order_items_insert_own" on public.order_items;
create policy "order_items_insert_own" on public.order_items
  for insert with check (
    exists (select 1 from public.orders o
            where o.id = order_id and o.user_id = auth.uid())
  );

-- Artist sales: bypasses RLS (security definer) to return orders that include
-- the artist's tattoos, with their items, as JSON.
create or replace function public.sales_for_artist(p_artist_id uuid)
returns json
language sql
security definer set search_path = public
as $$
  select coalesce(json_agg(row_to_json(o)), '[]'::json)
  from (
    select ord.id, ord.user_id, ord.total, ord.created_at,
      (select coalesce(json_agg(row_to_json(it)), '[]'::json)
       from public.order_items it where it.order_id = ord.id) as items
    from public.orders ord
    where exists (
      select 1 from public.order_items i
      where i.order_id = ord.id and i.artist_id = p_artist_id
    )
    order by ord.created_at desc
  ) o;
$$;

-- ──────────────── seed: 5 demo artist accounts ────────────────
-- Real auth users (password: gotattoo) so you can log in as them.
-- Fixed UUIDs so the products below can reference them.
do $$
declare
  artists jsonb := '[
    {"id":"11111111-1111-1111-1111-111111111111","name":"João Silva","email":"joao@gotattoo.com","specialty":"Realista","rating":4.8,"region":"Centro","avatar":"https://images.unsplash.com/photo-1597223557154-721c1cecc4b0?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"},
    {"id":"22222222-2222-2222-2222-222222222222","name":"Ana Costa","email":"ana@gotattoo.com","specialty":"Aquarela","rating":4.9,"region":"Bela Vista","avatar":"https://images.unsplash.com/photo-1614583225154-5fcdda07019e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"},
    {"id":"33333333-3333-3333-3333-333333333333","name":"Pedro Matos","email":"pedro@gotattoo.com","specialty":"Old School","rating":4.7,"region":"Centro","avatar":"https://images.unsplash.com/photo-1584273143981-41c073dfe8f8?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"},
    {"id":"44444444-4444-4444-4444-444444444444","name":"Carla Dias","email":"carla@gotattoo.com","specialty":"Blackwork","rating":4.6,"region":"Bela Vista","avatar":"https://images.unsplash.com/photo-1542458580-9d880e2a6bdd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"},
    {"id":"55555555-5555-5555-5555-555555555555","name":"Lucas Reis","email":"lucas@gotattoo.com","specialty":"Geométrica","rating":4.5,"region":"Jardim Primavera","avatar":"https://images.unsplash.com/photo-1591190895404-20b87628ce5c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"}
  ]';
  a jsonb;
  uid uuid;
begin
  for a in select * from jsonb_array_elements(artists)
  loop
    uid := (a->>'id')::uuid;

    -- auth user
    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, created_at, updated_at,
      raw_app_meta_data, raw_user_meta_data,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) values (
      '00000000-0000-0000-0000-000000000000', uid, 'authenticated', 'authenticated',
      a->>'email', extensions.crypt('gotattoo', extensions.gen_salt('bf')),
      now(), now(), now(),
      '{"provider":"email","providers":["email"]}',
      jsonb_build_object('name', a->>'name', 'role', 'artist'),
      '', '', '', ''
    ) on conflict (id) do nothing;

    -- email identity (required for password login)
    insert into auth.identities (
      id, user_id, provider_id, identity_data, provider,
      last_sign_in_at, created_at, updated_at
    ) values (
      gen_random_uuid(), uid, a->>'email',
      jsonb_build_object('sub', uid::text, 'email', a->>'email'),
      'email', now(), now(), now()
    ) on conflict do nothing;

    -- profile (the trigger may have created a base row; fill artist fields)
    insert into public.profiles (id, name, role, specialty, rating, region, avatar_url)
    values (uid, a->>'name', 'artist', a->>'specialty',
            (a->>'rating')::numeric, a->>'region', a->>'avatar')
    on conflict (id) do update set
      name = excluded.name, role = 'artist',
      specialty = excluded.specialty, rating = excluded.rating,
      region = excluded.region, avatar_url = excluded.avatar_url;
  end loop;
end $$;

-- ──────────────── seed: 16 products ────────────────
insert into public.products (name, description, price, image_url, stock, category, artist_id, discount_percent) values
('Dragão Oriental','Tatuagem de dragão tradicional japonês com cores vibrantes e detalhes precisos.',1200,'https://w7.pngwing.com/pngs/265/490/png-transparent-easten-dragon-red-oriental-dragon-tattoo-thumbnail.png',5,'Old School','33333333-3333-3333-3333-333333333333',15),
('Pássaro New School','Tatuagem colorida em estilo New School de um beija-flor com elementos gráficos modernos.',850,'https://st.depositphotos.com/1052445/4100/v/450/depositphotos_41003087-stock-illustration-swallow-and-rose-old-school.jpg',3,'New School','11111111-1111-1111-1111-111111111111',0),
('Padrão Maori','Desenho tribal inspirado na cultura Maori, com linhas precisas e simetria perfeita.',780,'https://img.lovepik.com/png/20231029/Maori-tribal-style-tattoo-pattern-black-sea-turtle-black-and_405507_wh860.png',8,'Tribal','44444444-4444-4444-4444-444444444444',0),
('Retrato Realista','Retrato hiperrealista com sombreamento detalhado. Perfeito para homenagear alguém especial.',1500,'https://desenhosrealistas.com.br/wp-content/uploads/2018/08/tatuagem-realista.jpg',2,'Realista','11111111-1111-1111-1111-111111111111',0),
('Mandala Geométrica','Mandala com padrões geométricos precisos e simetria perfeita.',650,'https://static.vecteezy.com/ti/vetor-gratis/p1/9751732-contorno-geometrico-mandala-elemento-vetor.jpg',10,'Geométrica','55555555-5555-5555-5555-555555555555',0),
('Blackwork Floral','Composição floral em estilo blackwork com linhas bem definidas e contraste intenso.',700,'https://www.dubuddha.org/wp-content/uploads/2017/05/Blackwork-Flowers-Tattoo-Sleeve-by-Jakob-Holst-Rasmussen.jpg',6,'Blackwork','44444444-4444-4444-4444-444444444444',0),
('Aquarela Abstrata','Composição colorida em estilo aquarela com respingos e gradientes suaves.',950,'https://img.freepik.com/fotos-premium/pintura-de-aquarela-abstrata-ondas-coloridas-e-vibrantes_14117-102861.jpg',4,'Aquarela','22222222-2222-2222-2222-222222222222',0),
('Linhas Minimalistas','Design minimalista com poucas linhas, elegante e discreto.',350,'https://i.pinimg.com/564x/15/78/6d/15786d30f21ee6b9e691edbbfada1675.jpg',15,'Minimalista','55555555-5555-5555-5555-555555555555',20),
('Rosa Old School','Clássica rosa no estilo tradicional americano com linhas grossas e cores vivas.',550,'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRVkIMf0OIDAJY4y45SflZb-HuV3r1lfrRJDw&s',7,'Old School','33333333-3333-3333-3333-333333333333',0),
('Lobo Realista','Tatuagem hiperrealista de lobo com detalhes impressionantes nos pelos e expressão.',1350,'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQLF2EFlusTGAZ_ZqaEYQ4yXcADvnY3QptwJA&s',3,'Realista','11111111-1111-1111-1111-111111111111',0),
('Peixe Aquarela','Peixe koi em estilo aquarela com salpicos coloridos e traços leves.',880,'https://i.pinimg.com/564x/a7/ff/0e/a7ff0eee947438b0289c544c87c64a0f.jpg',5,'Aquarela','22222222-2222-2222-2222-222222222222',0),
('Padrão Geométrico','Composição de formas geométricas com precisão matemática e equilíbrio perfeito.',750,'https://blog.tattoo2me.com/wp-content/uploads/2023/06/IMG_1076.jpeg',9,'Geométrica','55555555-5555-5555-5555-555555555555',0),
('Carta de Baralho','Tatuagem de carta de baralho no estilo New School com cores vibrantes.',600,'https://i.pinimg.com/564x/39/66/f3/3966f3bcdfb9051e966b9851dee01983.jpg',6,'New School','22222222-2222-2222-2222-222222222222',0),
('Braceletes Tribais','Conjunto de linhas tribais formando um bracelete completo para o braço.',900,'https://i.pinimg.com/564x/96/46/85/9646850b49afab7eb4f3c688a4b7033b.jpg',4,'Tribal','33333333-3333-3333-3333-333333333333',0),
('Blackwork Ornamental','Padrões ornamentais em blackwork com inspiração em arquitetura gótica e mandalas.',820,'https://cdntattoofilter.com/tattoo/393832/l.jpg',5,'Blackwork','44444444-4444-4444-4444-444444444444',0),
('Linha Fina Minimalista','Pequeno desenho com linhas finíssimas e detalhes delicados.',300,'https://psychodolltattoo.com/wp-content/uploads/2022/09/psycho-doll-tattoo-studio-mallorca5-TATUAJES-768x1592.jpg',20,'Minimalista','11111111-1111-1111-1111-111111111111',0)
on conflict do nothing;
