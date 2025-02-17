create or replace function get_last_user_login()
returns varchar
language plpgsql
as
$$
declare
last_user_id bigint;
    last_user_login varchar;
begin

select id
into last_user_id
from public.users
order by created desc
    limit 1;

if last_user_id is not null then
select login
into last_user_login
from public.user_credentials
where user_id = last_user_id;

return last_user_login;
else
        return null;
end if;
end;
$$;
