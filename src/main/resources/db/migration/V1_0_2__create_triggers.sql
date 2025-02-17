create table public.logs
(
    id bigserial primary key,
    user_id bigint not null,
    action varchar(50) not null,
    action_timestamp timestamp(6) not null default now(),
    old_data jsonb,
    new_data jsonb
);

create or replace function log_user_update()
returns trigger as
$$
begin
insert into public.logs (user_id, action, action_timestamp, old_data, new_data)
values (
           NEW.id,
           'UPDATE',
           now(),
           row_to_json(OLD),
           row_to_json(NEW)
       );
return NEW;
end;
$$
language plpgsql;

create or replace function log_user_delete()
returns trigger as
$$
begin
insert into public.logs (user_id, action, action_timestamp, old_data, new_data)
values (
           OLD.id,
           'DELETE',
           now(),
           row_to_json(OLD),
           null
       );
return OLD;
end;
$$
language plpgsql;

create trigger trigger_user_update
    before update on public.users
    for each row
    execute function log_user_update();

create trigger trigger_user_delete
    before delete on public.users
    for each row
    execute function log_user_delete();
