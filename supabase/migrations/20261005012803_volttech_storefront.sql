create schema if not exists private;
revoke all on schema private from public;
create table public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 name text not null default '', email text not null default '', avatar_url text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.categories (
 id text primary key, name text not null unique, slug text not null unique,
 icon text not null, description text not null, active boolean not null default true
);
create table public.products (
 id text primary key, category_id text not null references public.categories(id),
 name text not null, slug text not null unique, brand text not null,
 short_description text not null, description text not null,
 price numeric(12,2) not null check(price > 0),
 old_price numeric(12,2) check(old_price >= price),
 image_url text not null, stock integer not null check(stock >= 0),
 rating numeric(2,1) not null default 0 check(rating between 0 and 5),
 active boolean not null default true,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index products_category_idx on public.products(category_id);
create table public.product_specs (
 id bigint generated always as identity primary key,
 product_id text not null references public.products(id) on delete cascade,
 label text not null, value text not null, sort_order integer not null default 0,
 unique(product_id,label)
);
create table public.product_explanations (
 product_id text primary key references public.products(id) on delete cascade,
 ideal_for text not null, good_for text[] not null, not_recommended_for text[] not null,
 performance_explanation text not null, battery_explanation text not null,
 display_explanation text not null, pros text[] not null, attention_points text[] not null,
 why_buy text not null, user_profile text not null
);
create table public.product_use_cases (
 id bigint generated always as identity primary key,
 product_id text not null references public.products(id) on delete cascade,
 use_case text not null, score integer not null check(score between 1 and 5),
 unique(product_id,use_case)
);
create table public.favorites (
 id bigint generated always as identity primary key,
 user_id uuid not null references auth.users(id) on delete cascade,
 product_id text not null references public.products(id) on delete cascade,
 created_at timestamptz not null default now(), unique(user_id,product_id)
);
create index favorites_product_idx on public.favorites(product_id);
create table public.cart_items (
 id bigint generated always as identity primary key,
 user_id uuid not null references auth.users(id) on delete cascade,
 product_id text not null references public.products(id) on delete cascade,
 quantity integer not null check(quantity between 1 and 99),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(user_id,product_id)
);
create index cart_product_idx on public.cart_items(product_id);
create table public.orders (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 request_id uuid not null, status text not null default 'Confirmado (simulação)' check(status = 'Confirmado (simulação)'),
 customer_name text not null, email text not null, address text not null,
 payment_method text not null check(payment_method in ('Pix','Cartão','Boleto')),
 subtotal numeric(12,2) not null check(subtotal > 0),
 total numeric(12,2) not null check(total = subtotal),
 created_at timestamptz not null default now(), unique(user_id,request_id)
);
create index orders_user_date_idx on public.orders(user_id,created_at desc);
create table public.order_items (
 id bigint generated always as identity primary key,
 order_id uuid not null references public.orders(id) on delete cascade,
 product_id text not null references public.products(id),
 product_name text not null, unit_price numeric(12,2) not null check(unit_price > 0),
 quantity integer not null check(quantity between 1 and 99)
);
create index order_items_order_idx on public.order_items(order_id);
create index order_items_product_idx on public.order_items(product_id);
create table public.reviews (
 id bigint generated always as identity primary key,
 user_id uuid not null references auth.users(id) on delete cascade,
 product_id text not null references public.products(id) on delete cascade,
 rating integer not null check(rating between 1 and 5), comment text not null check(length(comment) between 1 and 2000),
 created_at timestamptz not null default now(), unique(user_id,product_id)
);
create index reviews_product_idx on public.reviews(product_id);
create table public.recommendation_sessions (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 category text not null references public.categories(id), use_case text not null,
 budget_min numeric not null check(budget_min >= 0), budget_max numeric not null check(budget_max >= budget_min),
 priority text not null, created_at timestamptz not null default now()
);
create index recommendations_user_idx on public.recommendation_sessions(user_id);
create index recommendations_category_idx on public.recommendation_sessions(category);

create function private.touch_updated_at() returns trigger language plpgsql set search_path = '' as $$
begin new.updated_at = now(); return new; end $$;
create trigger products_updated before update on public.products for each row execute function private.touch_updated_at();
create trigger profiles_updated before update on public.profiles for each row execute function private.touch_updated_at();
create trigger cart_updated before update on public.cart_items for each row execute function private.touch_updated_at();

create function private.create_profile() returns trigger language plpgsql security definer set search_path = '' as $$
begin
 insert into public.profiles(id,name,email) values(new.id,coalesce(new.raw_user_meta_data->>'name',''),coalesce(new.email,''));
 return new;
end $$;
revoke all on function private.create_profile() from public;
create trigger auth_profile after insert on auth.users for each row execute function private.create_profile();

do $$
declare t text;
begin
 foreach t in array array['profiles','categories','products','product_specs','product_explanations','product_use_cases','favorites','cart_items','orders','order_items','reviews','recommendation_sessions'] loop
 execute format('alter table public.%I enable row level security',t);
 end loop;
end $$;
create policy categories_read on public.categories for select to anon,authenticated using(active);
create policy products_read on public.products for select to anon,authenticated using(active and exists(select 1 from public.categories c where c.id=category_id and c.active));
do $$
declare t text;
begin
 foreach t in array array['product_specs','product_explanations','product_use_cases'] loop
 execute format('create policy catalog_read on public.%I for select to anon,authenticated using(exists(select 1 from public.products p where p.id=product_id and p.active))',t);
 end loop;
 foreach t in array array['favorites','cart_items','recommendation_sessions'] loop
 execute format('create policy owner_access on public.%I for all to authenticated using((select auth.uid())=user_id) with check((select auth.uid())=user_id)',t);
 end loop;
end $$;
create policy profile_read on public.profiles for select to authenticated using((select auth.uid())=id);
create policy profile_update on public.profiles for update to authenticated using((select auth.uid())=id) with check((select auth.uid())=id);
create policy orders_read on public.orders for select to authenticated using((select auth.uid())=user_id);
create policy items_read on public.order_items for select to authenticated using(exists(select 1 from public.orders o where o.id=order_id and o.user_id=(select auth.uid())));
create policy reviews_read on public.reviews for select to anon,authenticated using(exists(select 1 from public.products p where p.id=product_id and p.active));
create policy reviews_insert on public.reviews for insert to authenticated with check((select auth.uid())=user_id);
create policy reviews_update on public.reviews for update to authenticated using((select auth.uid())=user_id) with check((select auth.uid())=user_id);
create policy reviews_delete on public.reviews for delete to authenticated using((select auth.uid())=user_id);

revoke all on all tables in schema public from anon,authenticated;
grant usage on schema public to anon,authenticated;
grant select on public.categories,public.products,public.product_specs,public.product_explanations,public.product_use_cases,public.reviews to anon,authenticated;
grant select on public.profiles,public.orders,public.order_items to authenticated;
grant update(name,avatar_url) on public.profiles to authenticated;
grant select,insert,update,delete on public.favorites,public.cart_items,public.recommendation_sessions to authenticated;
grant insert,update,delete on public.reviews to authenticated;
grant usage,select on all sequences in schema public to authenticated;

-- Only this private, authenticated transaction may write orders or stock.
create function private.checkout(p_request_id uuid,p_name text,p_email text,p_address text,p_payment text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare uid uuid := auth.uid(); oid uuid; amount numeric(12,2); item record;
begin
 if uid is null then raise exception 'Entre na sua conta para continuar.'; end if;
 perform pg_advisory_xact_lock(hashtextextended(uid::text,0));
 select id into oid from public.orders where user_id=uid and request_id=p_request_id;
 if oid is not null then return oid; end if;
 if p_request_id is null or length(trim(p_name)) < 2 or p_email not like '%@%.%' or length(trim(p_address)) < 8 or p_payment not in ('Pix','Cartão','Boleto') then
 raise exception 'Confira os dados de entrega e pagamento.'; end if;
 perform 1 from public.cart_items where user_id=uid order by product_id for update;
 if not exists(select 1 from public.cart_items where user_id=uid) then raise exception 'Seu carrinho está vazio.'; end if;
 for item in select p.id,p.stock,p.active,c.quantity,cat.active as category_active from public.cart_items c join public.products p on p.id=c.product_id join public.categories cat on cat.id=p.category_id where c.user_id=uid order by p.id for update of p loop
 if not item.active or not item.category_active or item.stock < item.quantity then raise exception 'Estoque insuficiente. Atualize seu carrinho.'; end if;
 end loop;
 select sum(p.price*c.quantity) into amount from public.cart_items c join public.products p on p.id=c.product_id where c.user_id=uid;
 insert into public.orders(user_id,request_id,customer_name,email,address,payment_method,subtotal,total)
 values(uid,p_request_id,trim(p_name),trim(p_email),trim(p_address),p_payment,amount,amount) returning id into oid;
 insert into public.order_items(order_id,product_id,product_name,unit_price,quantity)
 select oid,p.id,p.name,p.price,c.quantity from public.cart_items c join public.products p on p.id=c.product_id where c.user_id=uid;
 update public.products p set stock=p.stock-c.quantity from public.cart_items c where c.user_id=uid and c.product_id=p.id;
 delete from public.cart_items where user_id=uid;
 return oid;
end $$;
revoke all on function private.checkout(uuid,text,text,text,text) from public;
grant usage on schema private to authenticated;
grant execute on function private.checkout(uuid,text,text,text,text) to authenticated;
create function public.checkout(p_request_id uuid,p_name text,p_email text,p_address text,p_payment text)
returns uuid language sql security invoker set search_path = '' as $$
 select private.checkout(p_request_id,p_name,p_email,p_address,p_payment);
$$;
revoke all on function public.checkout(uuid,text,text,text,text) from public,anon;
grant execute on function public.checkout(uuid,text,text,text,text) to authenticated;
