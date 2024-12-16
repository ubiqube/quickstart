
do $$
begin
  create user mano_nfvo  with encrypted password 'mano';
    exception when duplicate_object then raise notice 'not creating user mano_nfvo -- it already exists';
end
$$;

select 'create database mano_nfvo owner mano_nfvo' where not exists (select FROM pg_database WHERE datname = 'mano_nfvo')\gexec
grant all privileges on database mano_nfvo to mano_nfvo;

do $$
begin
  create user mano_vnfm  with encrypted password 'mano';
    exception when duplicate_object then raise notice 'not creating user mano_vnfm -- it already exists';
end
$$;
select 'create database mano_vnfm owner mano_vnfm' where not exists (select FROM pg_database WHERE datname = 'mano_vnfm')\gexec
grant all privileges on database mano_nfvo to mano_vnfm;

do $$
begin
  create user mano_mon  with encrypted password 'mano';
    exception when duplicate_object then raise notice 'not creating user mano_mon -- it already exists';
end
$$;
select 'create database mano_mon owner mano_mon' where not exists (select FROM pg_database WHERE datname = 'mano_mon')\gexec
grant all privileges on database mano_mon to mano_mon;

do $$
begin
  create user mano_alarm  with encrypted password 'mano';
    exception when duplicate_object then raise notice 'not creating user mano_alarm -- it already exists';
end
$$;
select 'create database mano_alarm owner mano_alarm' where not exists (select FROM pg_database WHERE datname = 'mano_alarm')\gexec
grant all privileges on database mano_alarm to mano_alarm;

do $$
begin
  create user keycloak with encrypted password 'keycloak';
    exception when duplicate_object then raise notice 'not creating user keycloak -- it already exists';
end
$$;
select 'create database keycloak owner keycloak' where not exists (select FROM pg_database WHERE datname = 'keycloak')\gexec
grant all privileges on database keycloak to keycloak;

