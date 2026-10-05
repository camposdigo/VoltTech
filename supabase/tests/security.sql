-- Run with the database owner against a seeded test database.
-- Every fixture and stock change is rolled back, including on assertion failure.
begin;
insert into auth.users(id,email,raw_user_meta_data) values
 ('10000000-0000-4000-8000-000000000001','rls-one@example.test','{"name":"RLS One"}'),
 ('10000000-0000-4000-8000-000000000002','rls-two@example.test','{"name":"RLS Two"}');
set local role anon;
do $$ begin
 if (select count(*) from public.products) < 15 then raise exception 'Public catalog unavailable'; end if;
 begin
  perform * from public.profiles;
  raise exception 'Anonymous private access was allowed';
 exception when insufficient_privilege then null; end;
end $$;
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000001',true);
insert into public.favorites(user_id,product_id) values(auth.uid(),'volt-book-study');
insert into public.cart_items(user_id,product_id,quantity) values(auth.uid(),'volt-book-study',1);
do $$ begin
 if (select count(*) from public.profiles)<>1 then raise exception 'Profile isolation failed'; end if;
 begin
  insert into public.favorites(user_id,product_id) values('10000000-0000-4000-8000-000000000002','volt-photo');
  raise exception 'Foreign owner insert was allowed';
 exception when insufficient_privilege then null; end;
 begin
  update public.favorites set user_id='10000000-0000-4000-8000-000000000002';
  raise exception 'Ownership reassignment was allowed';
 exception when insufficient_privilege then null; end;
 begin
  update public.cart_items set quantity=0;
  raise exception 'Invalid quantity was allowed';
 exception when check_violation then null; end;
end $$;
select public.checkout('10000000-0000-4000-8000-000000000003','Teste SQL','test@example.test','Endereço fictício, 123','Pix');
select public.checkout('10000000-0000-4000-8000-000000000003','Teste SQL','test@example.test','Endereço fictício, 123','Pix');
do $$ begin
 if (select count(*) from public.orders)<>1 then raise exception 'Idempotency failed'; end if;
 if (select total from public.orders)<>2499 then raise exception 'Server pricing failed'; end if;
 if (select count(*) from public.order_items)<>1 then raise exception 'Order items missing'; end if;
 if exists(select 1 from public.cart_items) then raise exception 'Cart was not cleared'; end if;
end $$;
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000002',true);
do $$ begin
 if exists(select 1 from public.favorites) or exists(select 1 from public.orders)
 or exists(select 1 from public.order_items) or exists(select 1 from public.cart_items) then
 raise exception 'Private data visible across users'; end if;
end $$;
reset role;
rollback;
select 'PASS: catalog, RLS, ownership, constraints, checkout, idempotency and rollback' as result;
