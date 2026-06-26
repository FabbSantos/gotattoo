-- GoTattoo · Supabase migration — Self-service account deletion
-- Run AFTER 0026. Idempotent.
--
-- Lets a logged-in user delete their own account. Removing the auth user
-- cascades to the profile and all owned content (FKs are on delete cascade).

create or replace function public.delete_my_account()
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

grant execute on function public.delete_my_account() to authenticated;
