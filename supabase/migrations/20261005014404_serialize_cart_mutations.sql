create function private.lock_cart_owner() returns trigger language plpgsql set search_path = '' as $$
begin
 if auth.uid() is not null then
  perform pg_advisory_xact_lock(hashtextextended(auth.uid()::text,0));
 end if;
 return null;
end $$;
create trigger cart_owner_lock before insert or update or delete on public.cart_items
for each statement execute function private.lock_cart_owner();
